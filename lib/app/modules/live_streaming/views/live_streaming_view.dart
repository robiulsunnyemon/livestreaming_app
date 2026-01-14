import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

import '../controllers/live_streaming_controller.dart';

class LiveStreamingView extends GetView<LiveStreamingController> {
  const LiveStreamingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stream'),
        automaticallyImplyLeading: false, // Handle back manually
      ),
      body: Stack(
        children: [
          // Video Grid
          Obx(() {
            if (!controller.isConnected.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // Show Local Video if Host, or Remote Video(s)
            List<Widget> videoViews = [];
            
            if (controller.isHost && controller.localVideoTrack.value != null) {
               videoViews.add(
                 VideoTrackRenderer(
                   controller.localVideoTrack.value!,
                   fit: VideoViewFit.cover,
                 )
               );
            }
            
            for (var track in controller.remoteVideoTracks) {
               videoViews.add(
                 VideoTrackRenderer(
                   track,
                   fit: VideoViewFit.cover,
                 )
               );
            }

            if (videoViews.isEmpty) {
              return const Center(child: Text("Waiting for video..."));
            }

            // Simple Grid for now
            return GridView.count(
              crossAxisCount: videoViews.length > 1 ? 2 : 1,
              children: videoViews,
            );
          }),

          // Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: "mic",
                  onPressed: controller.toggleMic,
                  child: const Icon(Icons.mic),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: "leave",
                  backgroundColor: Colors.red,
                  onPressed: controller.leaveRoom,
                  child: const Icon(Icons.call_end),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
