import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/call_controller.dart';
import 'dart:ui';
import 'texture_video_renderer.dart';

class CallView extends GetView<CallController> {
  const CallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B15),
      body: Obx(() {
        if (controller.isIncoming.value && !controller.isConnected.value) {
          return _buildIncomingCallView();
        }
        return _buildActiveCallView();
      }),
    );
  }

  Widget _buildIncomingCallView() {
    return Stack(
      children: [
        // Blurred background of caller image
        if (controller.callerImage.value != null)
          Positioned.fill(
            child: Image.network(
              controller.callerImage.value!,
              fit: BoxFit.cover,
            ),
          ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.black.withValues(alpha: 0.6)),
          ),
        ),
        
        // Content
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              CircleAvatar(
                radius: 60,
                backgroundImage: controller.callerImage.value != null 
                    ? NetworkImage(controller.callerImage.value!) 
                    : null,
                child: controller.callerImage.value == null 
                    ? const Icon(Icons.person, size: 60, color: Colors.white) 
                    : null,
              ),
              const SizedBox(height: 24),
              Text(
                controller.callerName.value,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Incoming ${controller.callType.value == 'video' ? 'Video' : 'Audio'} Call...",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCallButton(
                      icon: Icons.close,
                      color: Colors.redAccent,
                      onTap: controller.rejectCall,
                      label: "Decline",
                    ),
                    _buildCallButton(
                      icon: controller.callType.value == 'video' ? Icons.videocam : Icons.call,
                      color: Colors.greenAccent,
                      onTap: controller.acceptCall,
                      label: "Accept",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCallView() {
    return Stack(
      children: [
        // Remote Video (Background)
        if (controller.callType.value == "video" && controller.remoteVideoTrack.value != null)
          Positioned.fill(
            child: TextureVideoRenderer(track: controller.remoteVideoTrack.value!),
          )
        else
          _buildAudioCallBackground(),

        // Local Video (Overlay)
        if (controller.callType.value == "video" && controller.localVideoTrack.value != null)
          Obx(() => Positioned(
            top: controller.localVideoPosition.value.dy,
            right: controller.localVideoPosition.value.dx,
            child: GestureDetector(
              onPanUpdate: (details) {
                 controller.localVideoPosition.value = Offset(
                    controller.localVideoPosition.value.dx - details.delta.dx,
                    controller.localVideoPosition.value.dy + details.delta.dy,
                 );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: 120,
                  height: 180,
                  child: TextureVideoRenderer(track: controller.localVideoTrack.value!),
                ),
              ),
            ),
          )),

        // Controls
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: controller.isSpeakerphoneOn.value ? Icons.volume_up : Icons.volume_down,
                  onTap: controller.toggleSpeakerphone,
                  isActive: controller.isSpeakerphoneOn.value,
                ),
                _buildControlButton(
                  icon: controller.isMicEnabled.value ? Icons.mic : Icons.mic_off,
                  onTap: controller.toggleMic,
                  isActive: controller.isMicEnabled.value,
                ),
                _buildControlButton(
                  icon: Icons.call_end,
                  color: Colors.redAccent,
                  onTap: controller.endCall,
                  size: 70,
                ),
                if (controller.callType.value == "video") ...[
                  _buildControlButton(
                    icon: controller.isCameraEnabled.value ? Icons.videocam : Icons.videocam_off,
                    onTap: controller.toggleCamera,
                    isActive: controller.isCameraEnabled.value,
                  ),
                  _buildControlButton(
                    icon: Icons.flip_camera_ios,
                    onTap: controller.switchCamera,
                  ),
                ],
              ],
            ),
          ),
        ),
        
        // Caller Info (for audio calls)
        if (controller.callType.value == "audio" || controller.remoteVideoTrack.value == null)
            Positioned(
                top: 150,
                left: 0,
                right: 0,
                child: Column(
                    children: [
                         CircleAvatar(
                            radius: 50,
                            backgroundImage: controller.callerImage.value != null 
                                ? NetworkImage(controller.callerImage.value!) 
                                : null,
                          ),
                          const SizedBox(height: 20),
                          Text(controller.callerName.value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          const Text("Connected", style: TextStyle(color: Colors.greenAccent, fontSize: 16)),
                    ],
                )
            )
      ],
    );
  }

  Widget _buildAudioCallBackground() {
     return Container(
         color: const Color(0xFF1A1B28),
         child: Center(
             child: Opacity(
                 opacity: 0.1,
                 child: Icon(Icons.call, size: 200, color: Colors.white),
             ),
         ),
     );
  }

  Widget _buildCallButton({required IconData icon, required Color color, required VoidCallback onTap, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onTap, bool isActive = true, Color? color, double size = 56}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? (isActive ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05)),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.white38, size: size * 0.5),
      ),
    );
  }
}
