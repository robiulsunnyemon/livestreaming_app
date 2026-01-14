import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

class LiveStreamingController extends GetxController {
  Room? room;
  late final EventsListener<RoomEvent> listener;
  
  final isConnected = false.obs;
  final localVideoTrack = Rxn<LocalVideoTrack>();
  final remoteVideoTracks = <VideoTrack>[].obs;
  
  // TODO: Replace with your actual LiveKit Server URL
  final String _liveKitUrl = "wss://liveworld-l78cuzu0.livekit.cloud";

  String token = "";
  String roomName = "";
  bool isHost = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      token = args['token'] ?? "";
      roomName = args['room_name'] ?? "";
      isHost = args['is_host'] ?? false;
    }
    connect();
  }

  Future<void> connect() async {
    // Request permissions
    await [Permission.camera, Permission.microphone].request();

    try {
      room = Room();
      listener = room!.createListener();

      await room!.connect(_liveKitUrl, token);
      isConnected.value = true;

      _setUpListeners();

      if (isHost) {
        // Publish video and audio
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
    listener.on<TrackSubscribedEvent>((event) {
       if (event.track is VideoTrack) {
         remoteVideoTracks.add(event.track as VideoTrack);
       }
    });

    listener.on<TrackUnsubscribedEvent>((event) {
      if (event.track is VideoTrack) {
        remoteVideoTracks.remove(event.track);
      }
    });
  }

  @override
  void onClose() {
    room?.disconnect();
    room?.dispose();
    super.onClose();
  }
  
  void toggleMic() async {
    if (room != null && room!.localParticipant != null) {
       bool isEnabled = room!.localParticipant!.isMicrophoneEnabled();
       await room!.localParticipant!.setMicrophoneEnabled(!isEnabled);
    }
  }
  
  void leaveRoom() async {
    await room?.disconnect();
    Get.back();
  }
}
