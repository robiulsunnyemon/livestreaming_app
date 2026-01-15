import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/streaming_service.dart';

class LiveStreamingController extends GetxController {
  final StreamingService _streamingService = StreamingService();
  
  Room? room;
  late final EventsListener<RoomEvent> listener;
  
  final isConnected = false.obs;
  final localVideoTrack = Rxn<LocalVideoTrack>();
  final remoteVideoTracks = <VideoTrack>[].obs;
  
  // Interactions State
  final comments = <Map<String, dynamic>>[].obs;
  final totalLikes = 0.obs;
  final currentUser = Rxn<UserModel>();
  
  final TextEditingController commentController = TextEditingController();

  // TODO: Replace with your actual LiveKit Server URL
  final String _liveKitUrl = "wss://liveworld-l78cuzu0.livekit.cloud";

  String token = "";
  String roomName = "";
  bool isHost = false;
  
  // We need session_id for API calls. Assuming roomName or another arg provides it, 
  // currently using roomName as session_id for simplicity or pass it via args.
  // In the startLive/join response, we might not have passed session ID directly.
  // Let's assume Room Name IS the channel name which acts as ID or we need to pass ID explicitly.
  // Backend: valid IDs are MongoDB ObjectIds. Channel name is "live_ID_TIMESTAMP"
  // So we probably need to pass the real Mongo ID (session_id) in arguments.
  String sessionId = "";
  String streamTitle = "";
  String streamCategory = "";

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      token = args['token'] ?? "";
      roomName = args['room_name'] ?? "";
      isHost = args['is_host'] ?? false;
      sessionId = args['session_id'] ?? ""; 
      streamTitle = args['title'] ?? "";
      streamCategory = args['category'] ?? "";
    }
    connect();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final profile = await AuthService.to.getMyProfile();
      currentUser.value = profile;
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> connect() async {
    await [Permission.camera, Permission.microphone].request();

    try {
      room = Room();
      listener = room!.createListener();
      
      // 1. Set up listeners BEFORE connecting
      _setUpListeners();

      print("Connecting to LiveKit: $_liveKitUrl");
      await room!.connect(_liveKitUrl, token);
      print("Connected to room: ${room!.name}");
      
      isConnected.value = true;

      // 2. Check for tracks already in the room (just in case they were subscribed during connect)
      for (var participant in room!.remoteParticipants.values) {
        print("Checking participant: ${participant.identity}");
        for (var trackPub in participant.videoTrackPublications) {
          if (trackPub.subscribed && trackPub.track is VideoTrack) {
            print("Found existing track from ${participant.identity}");
            if (!remoteVideoTracks.contains(trackPub.track)) {
              remoteVideoTracks.add(trackPub.track as VideoTrack);
            }
          }
        }
      }

      if (isHost) {
        print("Publishing host tracks...");
        var localVideo = await LocalVideoTrack.createCameraTrack();
        await room!.localParticipant?.publishVideoTrack(localVideo);
        localVideoTrack.value = localVideo;
        
        await room!.localParticipant?.setMicrophoneEnabled(true);
      }
    } catch (e) {
      print("Failed to connect: $e");
      Get.snackbar("Error", "Failed to connect to room: $e");
    }
  }

  void _setUpListeners() {
    print("Setting up LiveKit listeners...");
    listener.on<TrackSubscribedEvent>((event) {
       print("Track Subscribed: ${event.track.sid} from ${event.participant.identity}");
       if (event.track is VideoTrack) {
         if (!remoteVideoTracks.contains(event.track)) {
           remoteVideoTracks.add(event.track as VideoTrack);
         }
       }
    });

    listener.on<TrackUnsubscribedEvent>((event) {
      print("Track Unsubscribed: ${event.track.sid}");
      if (event.track is VideoTrack) {
        remoteVideoTracks.remove(event.track);
      }
    });

    listener.on<ParticipantConnectedEvent>((event) {
      print("Participant Connected: ${event.participant.identity}");
    });

    listener.on<ParticipantDisconnectedEvent>((event) {
      print("Participant Disconnected: ${event.participant.identity}");
    });

    // Listen for Data Messages (Chat, Likes, Gifts)
    listener.on<DataReceivedEvent>((event) {
       try {
         final String data = utf8.decode(event.data);
         final Map<String, dynamic> payload = jsonDecode(data);
         
         final type = payload['type'];
         
         if (type == 'comment') {
           comments.add({
             'name': payload['name'], 
             'message': payload['message'],
             'is_host': payload['is_host'] ?? false,
             'image': payload['profile_image'],
           });
         } else if (type == 'like') {
           totalLikes.value += 1;
           if (payload['name'] != null) {
              Get.snackbar(
                "Like!", 
                "${payload['name']} liked the stream!",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.pinkAccent.withOpacity(0.7),
                colorText: Colors.white,
                duration: const Duration(seconds: 1),
              );
            }
         } else if (type == 'gift') {
           comments.add({
              'name': payload['sender_name'],
              'message': "sent a gift: ${payload['amount']} coins!",
              'is_host': false,
              'image': payload['profile_image'],
              'is_gift': true,
            });
           Get.snackbar(
             "Gift Received!", 
             "${payload['sender_name']} sent ${payload['amount']} coins!",
             backgroundColor: Colors.amber, colorText: Colors.black
           );
         }
       } catch (e) {
         print("Error parsing data message: $e");
       }
    });
  }

  // --- Actions ---

  Future<void> sendComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;
    
    // 1. Call API
    // If sessionId is missing, we can't call API effectively unless we assume roomName is unique enough or lookup
    if (sessionId.isNotEmpty) {
        try {
            await _streamingService.sendComment(sessionId, text);
        } catch(e) {
            print("API Comment Error: $e");
            // Optional: Continue to show locally even if API fails? Better to fail.
        }
    }

    // 2. Publish Data to LiveKit
    final payload = jsonEncode({
      'type': 'comment',
      'name': currentUser.value?.fullName ?? 'Guest',
      'message': text,
      'is_host': isHost,
      'profile_image': currentUser.value?.profileImage,
    });
    
    await _publishData(payload);
    
    // Add locally
    comments.add({
      'name': currentUser.value?.fullName ?? 'Me', 
      'message': text, 
      'is_host': isHost,
      'image': currentUser.value?.profileImage,
    });
    commentController.clear();
  }

  Future<void> sendLike() async {
    if (sessionId.isNotEmpty) {
       try {
          await _streamingService.sendLike(sessionId);
       } catch(e){
         print("API Like Error: $e");
       }
    }
    
    final payload = jsonEncode({
      'type': 'like',
      'name': currentUser.value?.fullName ?? 'Someone',
    });
    await _publishData(payload);
    totalLikes.value += 1;
  }

  Future<void> sendGift(double amount) async {
    if (sessionId.isEmpty) return;
    
    try {
      await _streamingService.sendGift(sessionId, amount);
      
      final payload = jsonEncode({
        'type': 'gift',
        'sender_name': currentUser.value?.fullName ?? 'A Fan',
        'amount': amount,
        'profile_image': currentUser.value?.profileImage,
      });
      await _publishData(payload);
      
      Get.back(); // Close Gift Sheet
      Get.snackbar("Success", "Gift sent successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to send gift: $e");
    }
  }

  Future<void> _publishData(String data) async {
    if (room == null) return;
    final bytes = utf8.encode(data);
    await room!.localParticipant?.publishData(bytes);
  }

  @override
  void onClose() {
    room?.disconnect();
    room?.dispose();
    commentController.dispose();
    super.onClose();
  }
  
  void toggleMic() async {
    if (room != null && room!.localParticipant != null) {
       bool isEnabled = room!.localParticipant!.isMicrophoneEnabled();
       await room!.localParticipant!.setMicrophoneEnabled(!isEnabled);
    }
  }
  
  void leaveRoom() async {
    try {
      if (isHost && sessionId.isNotEmpty) {
        // If host, notify backend to end the stream
        await _streamingService.stopStream(sessionId);
      }

      // Explicitly disconnect from LiveKit
      await room?.disconnect();
      print("Disconnected from LiveKit room");
    } catch (e) {
      print("Error during leaveRoom: $e");
    } finally {
      Get.back();
    }
  }
}
