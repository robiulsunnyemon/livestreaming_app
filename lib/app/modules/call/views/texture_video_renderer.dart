import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';

class TextureVideoRenderer extends StatefulWidget {
  final VideoTrack track;
  final BoxFit fit;

  const TextureVideoRenderer({
    super.key,
    required this.track,
    this.fit = BoxFit.cover,
  });

  @override
  State<TextureVideoRenderer> createState() => _TextureVideoRendererState();
}

class _TextureVideoRendererState extends State<TextureVideoRenderer> {
  final _renderer = RTCVideoRenderer();
  bool _rendererReady = false;

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  Future<void> _initRenderer() async {
    await _renderer.initialize();
    _renderer.srcObject = widget.track.mediaStream;
    if (mounted) {
      setState(() {
        _rendererReady = true;
      });
    }
  }

  @override
  void didUpdateWidget(covariant TextureVideoRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.track != oldWidget.track) {
      _renderer.srcObject = widget.track.mediaStream;
    }
  }

  @override
  void dispose() {
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_rendererReady) {
      return const SizedBox();
    }
    
    // If we have a textureId, we can use the Texture widget directly!
    // This allows the video to be composited by Flutter, making screenshots work.
    if (_renderer.textureId != null) {
      return SizedBox.expand(
        child: Texture(
          textureId: _renderer.textureId!,
          filterQuality: FilterQuality.low,
        ),
      );
    }

    // Fallback if textureId is null (should normally not happen on Android if configured right, but good fallback)
    return RTCVideoView(
      _renderer,
      objectFit: widget.fit == BoxFit.cover ? RTCVideoViewObjectFit.RTCVideoViewObjectFitCover : RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    );
  }
}
