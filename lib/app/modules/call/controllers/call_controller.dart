import 'dart:async';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/services/call_service.dart';
import '../../../data/services/chat_socket_service.dart';

class CallController extends GetxController {
  final CallService _callService = CallService();
  final ChatSocketService _socketService = Get.find<ChatSocketService>();

  Room? room;
  final isConnected = false.obs;
  final isIncoming = false.obs;
  final callType = "audio".obs; // "audio" or "video"
  
  final callerId = "".obs;
  final callerName = "".obs;
  final callerImage = RxnString();
  final roomName = "".obs;

  final localVideoTrack = Rxn<LocalVideoTrack>();
  final remoteVideoTrack = Rxn<VideoTrack>();
  
  final isMicEnabled = true.obs;
  final isCameraEnabled = true.obs;
  
  StreamSubscription? _socketSubscription;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      roomName.value = args['room_name'] ?? "";
      callerId.value = args['caller_id'] ?? "";
      callerName.value = args['caller_name'] ?? "User";
      callerImage.value = args['caller_image'];
      callType.value = args['call_type'] ?? "audio";
      isIncoming.value = args['is_incoming'] ?? false;
      
      if (!isIncoming.value) {
        // We are the caller, initiate automatically
        Future.delayed(Duration.zero, () => initiateCall(callerId.value, callType.value));
      }
    }
    
    _listenToSignals();
  }

  void _listenToSignals() {
    _socketSubscription = _socketService.messages.listen((payload) {
      if (payload['type'] == 'call_accepted' && payload['room_name'] == roomName.value) {
        _connectToRoom(payload['token'] ?? ""); // Caller gets token here maybe? 
        // No, caller gets token from initiateCall. Receiver gets it from respondToCall.
        // Wait, my backend initiate/respond logic:
        // initiate -> returns token for caller.
        // respond(accept) -> returns token for receiver.
        // So caller already has token.
      } else if (payload['type'] == 'call_rejected' && payload['room_name'] == roomName.value) {
        Get.back();
        Get.snackbar("Call Rejected", "${callerName.value} rejected the call");
      } else if (payload['type'] == 'call_ended' && payload['room_name'] == roomName.value) {
        _cleanup();
        Get.back();
      }
    });
  }

  Future<void> initiateCall(String receiverId, String type) async {
    callType.value = type;
    callerId.value = receiverId;
    isIncoming.value = false;
    
    try {
      final result = await _callService.initiateCall(receiverId, type);
      roomName.value = result['room_name'];
      final token = result['token'];
      
      // Connect to room immediately but wait for remote
      await _connectToRoom(token);
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Failed to start call: $e");
    }
  }

  Future<void> acceptCall() async {
    try {
      final result = await _callService.respondToCall(roomName.value, callerId.value, "accept");
      final token = result['token'];
      isIncoming.value = false; // Transition to active call
      await _connectToRoom(token);
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Failed to accept call: $e");
    }
  }

  Future<void> rejectCall() async {
    try {
      await _callService.respondToCall(roomName.value, callerId.value, "reject");
      Get.back();
    } catch (e) {
      Get.back();
    }
  }

  Future<void> _connectToRoom(String token) async {
    if (token.isEmpty) return;
    
    await [Permission.camera, Permission.microphone].request();
    
    try {
      room = Room();
      final listener = room!.createListener();
      
      listener.on<TrackSubscribedEvent>((event) {
        if (event.track is VideoTrack) {
          remoteVideoTrack.value = event.track as VideoTrack;
        }
      });
      
      listener.on<TrackUnsubscribedEvent>((event) {
        if (event.track is VideoTrack) {
          remoteVideoTrack.value = null;
        }
      });

      await room!.connect("wss://liveworld-l78cuzu0.livekit.cloud", token);
      isConnected.value = true;

      // Publish local tracks
      if (callType.value == "video") {
        var localVideo = await LocalVideoTrack.createCameraTrack();
        await room!.localParticipant?.publishVideoTrack(localVideo);
        localVideoTrack.value = localVideo;
      }
      
      await room!.localParticipant?.setMicrophoneEnabled(true);
      
    } catch (e) {
      print("Call Connection Error: $e");
      Get.snackbar("Error", "Connection failed");
    }
  }

  void toggleMic() async {
    if (room?.localParticipant != null) {
      bool enabled = !isMicEnabled.value;
      await room!.localParticipant!.setMicrophoneEnabled(enabled);
      isMicEnabled.value = enabled;
    }
  }

  void toggleCamera() async {
    if (room?.localParticipant != null) {
      bool enabled = !isCameraEnabled.value;
      await room!.localParticipant!.setCameraEnabled(enabled);
      isCameraEnabled.value = enabled;
      
      if (!enabled) {
        localVideoTrack.value = null;
      } else {
         // Re-fetch local video track
         for (var pub in room!.localParticipant!.videoTrackPublications) {
           if (pub.track is LocalVideoTrack) {
             localVideoTrack.value = pub.track as LocalVideoTrack;
           }
         }
      }
    }
  }

  void endCall() {
    _callService.endCall(callerId.value, roomName.value);
    _cleanup();
    Get.back();
  }

  void _cleanup() {
    room?.disconnect();
    room?.dispose();
    _socketSubscription?.cancel();
  }

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }
}
