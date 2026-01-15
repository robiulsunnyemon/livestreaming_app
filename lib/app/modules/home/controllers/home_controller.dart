import 'package:get/get.dart';
import '../../../data/models/live_stream_model.dart';
import '../../../data/services/streaming_service.dart';


class HomeController extends GetxController {
  final StreamingService _streamingService = StreamingService();
  final streams = <LiveStreamModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStreams();
  }

  Future<void> fetchStreams() async {
    isLoading.value = true;
    try {
      final result = await _streamingService.getAllLiveStreams();
      streams.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinStream(LiveStreamModel stream) async {
    if (stream.id == null) return;
    try {
        // Show loading/snackbar?
        // Using `startStream` returns token, joinStream also returns token + balance.
        final result = await _streamingService.joinStream(stream.id!);
        
        Get.toNamed('/live-streaming', arguments: {
            "token": result['livekit_token'],
            "room_name": result['room_name'],
            "is_host": false,
            "session_id": stream.id,
            "title": stream.title,
            "category": stream.category,
        });
    } catch (e) {
        Get.snackbar("Error", "Could not join stream: $e");
    }
  }
}
