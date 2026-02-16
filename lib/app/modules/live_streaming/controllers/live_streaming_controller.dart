import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/streaming_service.dart';
import '../../../data/services/social_service.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../views/stream_review_dialog.dart';

class LiveStreamingController extends GetxController {
  final StreamingService _streamingService = StreamingService();
  final SocialService _socialService = SocialService();
  
  Room? room;
  EventsListener<RoomEvent>? listener;
  
  final isConnected = false.obs;
  final errorMessage = "".obs;
  final isMicEnabled = true.obs;
  final isCameraEnabled = true.obs;
  final localVideoTrack = Rxn<LocalVideoTrack>();
  final remoteVideoTracks = <VideoTrack>[].obs;
  
  // Interactions State
  final comments = <Map<String, dynamic>>[].obs;
  final totalLikes = 0.obs;
  final currentUser = Rxn<UserModel>();

  // Follow State
  final isFollowing = false.obs;
  final hostShady = 0.0.obs;
  final hostLegit = 100.0.obs;
  
  final TextEditingController commentController = TextEditingController();

  // Premium Preview State
  final isPremium = false.obs;
  final hasPaid = false.obs;
  final isPreviewMode = false.obs;
  final countdown = 3.obs;
  final entryFee = 0.obs;
  
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
  String hostId = "";
  final hostFullName = "".obs;
  final hostProfileImage = "".obs;
  String streamTitle = "";
  String streamCategory = "";
  
  bool _isExiting = false;
  bool _isReconnecting = false;
  bool _isExitHandled = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    debugPrint("LiveStreaming: onInit with args: $args");
    if (args != null) {
      token = (args['token'] ?? "").toString().trim();
      roomName = args['room_name'] ?? "";
      isHost = args['is_host'] ?? false;
      sessionId = args['session_id'] ?? ""; 
      hostId = args['host_id'] ?? "";
      hostFullName.value = args['host_name'] ?? "";
      hostProfileImage.value = args['host_image'] ?? "";
      streamTitle = args['title'] ?? "";
      streamCategory = args['category'] ?? "";
      
      isPremium.value = args['is_premium'] ?? false;
      hasPaid.value = args['has_paid'] ?? false;
      entryFee.value = (args['entry_fee'] ?? 0).toInt();
      
      hostShady.value = (args['host_shady'] ?? 0).toDouble();
      hostLegit.value = 100.0 - hostShady.value;
      
      debugPrint("LiveStreaming Initialized: isHost=$isHost, isPremium=${isPremium.value}, hasPaid=${hasPaid.value}");
    }
    connect();
    _fetchCurrentUser();
    _startPreviewTimer();
    _checkFollowStatus();
  }

  void _fetchCurrentUser() async {
    if (!AuthService.to.isLoggedIn) return;
    debugPrint("LiveStreaming: Fetching current user profile...");
    try {
      final user = await AuthService.to.getMyProfile();
      if (user != null) {
        currentUser.value = user;
        debugPrint("LiveStreaming: Profile fetched for ${user.fullName}");
        if (isHost) {
          hostFullName.value = user.fullName;
          hostProfileImage.value = user.profileImage ?? "";
          hostShady.value = user.shady ;
          hostLegit.value = 100.0 - hostShady.value;
        }
      }
    } catch (e) {
      debugPrint("LiveStreaming Error fetching profile: $e");
    }
  }

  Future<void> _checkFollowStatus() async {
    if (isHost || hostId.isEmpty) {
      debugPrint("LiveStreaming: Skipping follow check (Host or HostId empty)");
      return;
    }
    
    try {
      debugPrint("LiveStreaming: Checking follow status for host: $hostId");
      isFollowing.value = await _socialService.isFollowing(hostId);
      debugPrint("LiveStreaming: Follow status: ${isFollowing.value}");
    } catch (e) {
      debugPrint("LiveStreaming Error checking follow status: $e");
    }
  }

  Future<void> toggleFollow() async {
    if (hostId.isEmpty) {
      debugPrint("LiveStreaming Error: Cannot toggle follow, hostId is empty");
      return;
    }
    
    try {
      debugPrint("LiveStreaming Action: Toggling Follow. Current: ${isFollowing.value}");
      bool success;
      if (isFollowing.value) {
        success = await _socialService.unfollowUser(hostId);
        if (success) {
          isFollowing.value = false;
          debugPrint("LiveStreaming: Unfollowed successfully");
          SnackbarHelper.showNotice("Social", "Unfollowed successfully");
        } else {
          debugPrint("LiveStreaming Error: Unfollow failed");
          isFollowing.value = await _socialService.isFollowing(hostId);
        }
      } else {
        success = await _socialService.followUser(hostId);
        if (success) {
          isFollowing.value = true;
          debugPrint("LiveStreaming: Followed successfully");
          SnackbarHelper.showSuccess("Social", "Following successfully");
        } else {
          debugPrint("LiveStreaming Error: Follow failed");
          isFollowing.value = await _socialService.isFollowing(hostId);
        }
      }
    } catch (e) {
      debugPrint("LiveStreaming Toggle Follow Exception: $e");
      SnackbarHelper.showError("Error", "Action failed: $e");
    }
  }

  void _startPreviewTimer() {
    bool isGuest = !AuthService.to.isLoggedIn;
    
    // Guests get preview on ANY stream (free or premium)
    // Registered users get preview only on PREMIUM streams they haven't paid for
    bool needsPreview = isGuest || (!isHost && isPremium.value && !hasPaid.value);

    if (isHost || !needsPreview) {
      debugPrint("LiveStreaming: Skipping preview timer");
      isPreviewMode.value = false;
      return;
    }

    isPreviewMode.value = true;
    countdown.value = 3;
    
    debugPrint("LiveStreaming: Starting 3s preview timer for ${isGuest ? 'Guest' : 'User'}...");
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (countdown.value > 1) {
        countdown.value--;
        debugPrint("LiveStreaming: Preview Countdown: ${countdown.value}");
        return true;
      } else {
        countdown.value = 0;
        isPreviewMode.value = false;
        debugPrint("LiveStreaming: Preview ended. Content is now locked.");
        return false;
      }
    });
  }

  Future<void> payEntryFee() async {
    if (sessionId.isEmpty) return;
    
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final response = await _streamingService.payStreamFee(sessionId);
      Get.back(); // Close loading

      if ((response['message'] == "Payment successful" || response['message'] == "Already paid")) {
        debugPrint("LiveStreaming: Payment Successful. Message: ${response['message']}");
        hasPaid.value = true;
        
        // Update token and reconnect if provided (required for LiveKit subscription permissions)
        if (response['livekit_token'] != null) {
          debugPrint("LiveStreaming: Received NEW token. Forcing reconnection for subscription permissions...");
          token = response['livekit_token'];
          
          _isReconnecting = true; // Set flag to prevent exit dialog
          
          // Disconnect and DISPOSE current room properly to kill old listeners
          debugPrint("LiveStreaming: Disposing current session for re-auth...");
          if (room != null) {
            await room!.disconnect();
            await room!.dispose();
            room = null;
            listener = null;
          }
          
          isConnected.value = false;
          remoteVideoTracks.clear();
          
          // Small delay to ensure event loop clears old disconnect events
          await Future.delayed(const Duration(milliseconds: 300));
          
          // Reconnect with new token
          debugPrint("LiveStreaming: Reconnecting with elevated permissions...");
          await connect();
          
          // Keep flag true for a bit longer to catch late events
          await Future.delayed(const Duration(milliseconds: 500));
          _isReconnecting = false;
        }
        
        SnackbarHelper.showSuccess("Success", "Stream unlocked successfully!");
      } else {
        SnackbarHelper.showError("Error", "Payment failed. Please try again.");
      }
    } catch (e) {
      Get.back();
      _isReconnecting = false;
      debugPrint("LiveStreaming: Payment Error: $e");
      SnackbarHelper.showError("Error", "Insufficient coins or payment failed.");
    }
  }


  Future<void> connect() async {
    debugPrint("LiveStreaming: Requesting permissions...");
    await [Permission.camera, Permission.microphone].request();

    try {
      debugPrint("LiveStreaming: Initializing Room and Listeners...");
      
      // Safety: Ensure old room is gone
      if (room != null) {
        await room!.disconnect();
        await room!.dispose();
      }

      room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        )
      );
      listener = room!.createListener();
      
      // 1. Set up listeners BEFORE connecting
      _setUpListeners();

      if (token.isEmpty) {
        debugPrint("LiveStreaming Error: Token is EMPTY");
        throw Exception("LiveKit Token is empty");
      }

      debugPrint("LiveStreaming: Connecting to $_liveKitUrl with token: ${token.substring(0, 10)}...");
      await room!.connect(_liveKitUrl, token);
      debugPrint("LiveStreaming: Connected successfully to ${room!.name}");
      
      isConnected.value = true;

      // 2. Check for tracks already in the room (just in case they were subscribed during connect)
      for (var participant in room!.remoteParticipants.values) {
        debugPrint("LiveStreaming: Checking participant: ${participant.identity}");
        for (var trackPub in participant.videoTrackPublications) {
          if (trackPub.subscribed && trackPub.track is VideoTrack) {
            debugPrint("LiveStreaming: Found existing track from ${participant.identity}");
            if (!remoteVideoTracks.contains(trackPub.track)) {
              remoteVideoTracks.add(trackPub.track as VideoTrack);
            }
          }
        }
      }

      if (isHost) {
        debugPrint("LiveStreaming: Publishing host tracks...");
        var localVideo = await LocalVideoTrack.createCameraTrack();
        await room!.localParticipant?.publishVideoTrack(localVideo);
        localVideoTrack.value = localVideo;
        
        await room!.localParticipant?.setMicrophoneEnabled(true);
      }
    } catch (e) {
      debugPrint("LiveStreaming Error: Failed to connect: $e");
      errorMessage.value = "Failed to connect: $e";
      SnackbarHelper.showError("Error", "Failed to connect to room: $e");
    }
  }

  void _setUpListeners() {
    debugPrint("LiveStreaming: Setting up LiveKit listeners...");
    listener?.on<TrackSubscribedEvent>((event) {
       debugPrint("LiveStreaming Event: Track Subscribed: ${event.track.sid} from ${event.participant.identity} (Type: ${event.track.kind})");
       if (event.track is VideoTrack) {
         if (!remoteVideoTracks.contains(event.track)) {
           debugPrint("LiveStreaming: Adding remote video track to UI list.");
           remoteVideoTracks.add(event.track as VideoTrack);
         }
       }
    });

    listener?.on<TrackUnsubscribedEvent>((event) {
      debugPrint("LiveStreaming Event: Track Unsubscribed: ${event.track.sid}");
      if (event.track is VideoTrack) {
        remoteVideoTracks.remove(event.track);
      }
    });

    listener?.on<ParticipantConnectedEvent>((event) {
      debugPrint("LiveStreaming Event: Participant Connected: ${event.participant.identity}");
    });

    listener?.on<ParticipantDisconnectedEvent>((event) {
      debugPrint("LiveStreaming Event: Participant Disconnected: ${event.participant.identity}");
    });

    // Listen for room disconnection (e.g., host ends stream)
    listener?.on<RoomDisconnectedEvent>((event) {
      debugPrint("LiveStreaming Event: Room Disconnected. Reason: ${event.reason}");
      if (!_isReconnecting) {
        _handleExitScenario();
      } else {
        debugPrint("LiveStreaming: Ignoring disconnect event (Reason: Reconnecting for Auth)");
      }
    });

    // Listen for Data Messages (Chat, Likes, Gifts)
    listener?.on<DataReceivedEvent>((event) {
       try {
         final String data = utf8.decode(event.data);
         final Map<String, dynamic> payload = jsonDecode(data);
         
         final type = payload['type'];
         debugPrint("LiveStreaming: Data Received Type: $type");
         
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
              SnackbarHelper.showNotice(
                "Like!", 
                "${payload['name']} liked the stream!",
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
            SnackbarHelper.showNotice(
              "Gift Received!", 
              "${payload['sender_name']} sent ${payload['amount']} coins!",
            );
          }
       } catch (e) {
         debugPrint("LiveStreaming Error parsing data message: $e");
       }
    });
  }

  // --- Actions ---

  Future<void> sendComment() async {
    final text = commentController.text.trim();
    debugPrint("LiveStreaming Action: Sending Comment: $text");
    if (text.isEmpty) return;
    
    // Check payment status
    if (!isHost && isPremium.value && !hasPaid.value) {
      SnackbarHelper.showNotice("Notice", "Unlock to chat");
      return;
    }
    
    // 1. Call API
    // If sessionId is missing, we can't call API effectively unless we assume roomName is unique enough or lookup
    if (sessionId.isNotEmpty) {
        try {
            await _streamingService.sendComment(sessionId, text);
        } catch(e) {
            debugPrint("LiveStreaming Error: API Comment Error: $e");
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
    debugPrint("LiveStreaming Action: Sending Like...");
    // Check payment status
    if (!isHost && isPremium.value && !hasPaid.value) {
      SnackbarHelper.showNotice("Notice", "Please unlock the stream to like");
      return;
    }

    if (sessionId.isNotEmpty) {
       try {
          await _streamingService.sendLike(sessionId);
       } catch(e){
         debugPrint("LiveStreaming Error: API Like Error: $e");
       }
    }
    
    final payload = jsonEncode({
      'type': 'like',
      'name': currentUser.value?.fullName ?? 'Someone',
    });
    await _publishData(payload);
    totalLikes.value += 1;
  }

  Future<void> sendGift(int amount) async {
    debugPrint("LiveStreaming Action: Sending Gift: $amount coins...");
    // Check payment status
    if (!isHost && isPremium.value && !hasPaid.value) {
      SnackbarHelper.showNotice("Notice", "Please unlock the stream to send gifts");
      return;
    }

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
      SnackbarHelper.showSuccess("Success", "Gift sent successfully!");
    } catch (e) {
      SnackbarHelper.showError("Error", "Failed to send gift: $e");
    }
  }
  Future<void> _publishData(String data) async {
    if (room == null) {
      debugPrint("LiveStreaming Error: Cannot publish data, room is NULL");
      return;
    }
    debugPrint("LiveStreaming: Publishing data to LiveKit: ${data.substring(0, data.length > 50 ? 50 : data.length)}...");
    final bytes = utf8.encode(data);
    await room!.localParticipant?.publishData(bytes);
  }

  Future<void> reportStream(String category, String description) async {
    debugPrint("LiveStreaming Action: Reporting Stream. Category: $category");
    if (sessionId.isEmpty) return;
    try {
      await _streamingService.reportStream(sessionId, category, description: description);
    } catch (e) {
      debugPrint("LiveStreaming Error: Report Error: $e");
    }
  }

  @override
  void onClose() {
    debugPrint("LiveStreaming: onClose. Disposing resources...");
    room?.disconnect();
    room?.dispose();
    commentController.dispose();
    super.onClose();
  }
  
  void toggleMic() async {
    if (room != null && room!.localParticipant != null) {
       bool isEnabled = room!.localParticipant!.isMicrophoneEnabled();
       debugPrint("LiveStreaming Action: Toggling Mic. Current state: $isEnabled");
       await room!.localParticipant!.setMicrophoneEnabled(!isEnabled);
       isMicEnabled.value = !isEnabled;
    }
  }

  void toggleCamera() async {
    if (room != null && room!.localParticipant != null) {
       bool isCurrentlyEnabled = room!.localParticipant!.isCameraEnabled();
       bool shouldEnable = !isCurrentlyEnabled;
       debugPrint("LiveStreaming Action: Toggling Camera. Should enable: $shouldEnable");
       
       await room!.localParticipant!.setCameraEnabled(shouldEnable);
       isCameraEnabled.value = shouldEnable;
       
       if (shouldEnable) {
         // Give LiveKit a moment to publish/unmute
         // Then find the video track
         var track = room!.localParticipant!.videoTrackPublications
             .firstWhereOrNull((pub) => pub.track is LocalVideoTrack)
             ?.track;
             
         if (track != null) {
            localVideoTrack.value = track;
         } else {
             // Fallback: create listener or wait? 
             // Usually setCameraEnabled returns when done.
             // Try fetching again after small delay if needed or rely on listener?
             // Actually, for local, we might need to grab it explicitly if it was newly created.
         }
       } else {
         localVideoTrack.value = null;
       }
    }
  }
  
  void leaveRoom() async {
    if (_isExiting) return;
    _isExiting = true;
    
    debugPrint("LiveStreaming Action: Leaving Room...");
    try {
      if (isHost && sessionId.isNotEmpty) {
        debugPrint("LiveStreaming: Stopping stream on backend...");
        await _streamingService.stopStream(sessionId);
      }

      await room?.disconnect();
      await room?.dispose();
      room = null;
      isConnected.value = false;
      
      debugPrint("LiveStreaming: Disconnected from LiveKit room");
      _handleExitScenario();
    } catch (e) {
      isConnected.value = false;
      debugPrint("LiveStreaming Error: during leaveRoom: $e");
      _handleExitScenario();
    }
  }

  void _handleExitScenario() {
    // 1. If we are reconnecting (e.g. during payment), ignore everything
    if (_isReconnecting) {
      debugPrint("LiveStreaming: Ignoring exit scenario during reconnection");
      return;
    }

    // 2. Prevent multiple calls to the exit UI
    if (_isExitHandled) return;
    _isExitHandled = true;

    // 3. If it's the host or we don't have a session, just go back
    if (isHost || sessionId.isEmpty) {
      Get.back();
      return;
    }

    // 4. Guests NEVER see the review dialog, go straight to Dashboard
    if (!AuthService.to.isLoggedIn) {
      Get.offAllNamed(Routes.DASHBOARD);
      return;
    }

    // 5. SECURE GATING: If user is in Preview OR is looking at Blurred content (Premium Unpaid)
    // NEVER show the review dialog.
    bool hasAccess = !isPremium.value || hasPaid.value;
    if (isPreviewMode.value || !hasAccess) {
      debugPrint("LiveStreaming: Exiting without review (Preview/Locked content)");
      Get.back();
      return;
    }

    // 6. Registered users who have Paid OR are on Free streams
    // Show review dialog and then pop the screen when it's closed
    Get.bottomSheet(
      StreamReviewDialog(controller: this),
      isScrollControlled: true,
      barrierColor: Colors.black54,
    ).then((_) {
      // Once the bottom sheet is closed (by user or programmatic back),
      // we must pop the LiveStreamingView itself.
      if (Get.currentRoute == Routes.LIVE_STREAMING || Get.currentRoute.contains('live-streaming')) {
        Get.back();
      }
    });
  }
}
