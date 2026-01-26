import 'package:get/get.dart';
import '../../../data/models/live_stream_model.dart';
import '../../../data/services/streaming_service.dart';
import 'package:flutter/material.dart';


class ExploreController extends GetxController {
  final StreamingService _streamingService = Get.put(StreamingService());

  final RxString selectedCategory = "All".obs;
  final RxList<LiveStreamModel> streams = <LiveStreamModel>[].obs;
  final RxBool isLoading = false.obs;

  final List<String> categories = ["All", "Just fun", "Fitness", "Health"];
  
  final isSearching = false.obs;
  final searchController = TextEditingController();

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
        "is_premium": result['is_premium'] ?? false,
        "has_paid": result['has_paid'] ?? false,
        "entry_fee": result['entry_fee'] ?? 0.0,
      });
    } catch (e) {
      Get.snackbar("Error", "Could not join stream: $e");
    }
  }

  Future<void> onSearch(String query) async {
    if (query.isEmpty) {
      fetchStreams();
      return;
    }
    isLoading.value = true;
    try {
      final result = await _streamingService.searchStreams(query);
      streams.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }
}
