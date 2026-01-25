import 'package:get/get.dart';
import '../../../data/models/live_stream_model.dart';
import '../../../data/services/streaming_service.dart';

class ExploreController extends GetxController {
  final StreamingService _streamingService = Get.put(StreamingService());

  final RxString selectedCategory = "All".obs;
  final RxList<LiveStreamModel> streams = <LiveStreamModel>[].obs;
  final RxBool isLoading = false.obs;

  final List<String> categories = ["All", "Just fun", "Fitness", "Health"];

  @override
  void onInit() {
    super.onInit();
    fetchStreams();
  }

  void selectCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    fetchStreams();
  }

  Future<void> fetchStreams() async {
    isLoading.value = true;
    try {
      List<LiveStreamModel> fetchedStreams;
      if (selectedCategory.value == "All") {
        fetchedStreams = await _streamingService.getAllLiveStreams();
      } else {
        // Map UI category to API parameter logic if needed (e.g. lowercase)
        // Adjusting casing as per requirement: "fun", "fitness", "health"
        String apiCategory = selectedCategory.value;
        if (apiCategory == "Just fun") apiCategory = "fun";
        
        fetchedStreams = await _streamingService.getActiveStreamsByCategory(apiCategory.toLowerCase());
      }
      streams.assignAll(fetchedStreams);
    } catch (e) {
      print("Error in ExploreController: $e");
      streams.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinStream(LiveStreamModel stream) async {
    if (stream.id == null) return;
    try {
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
