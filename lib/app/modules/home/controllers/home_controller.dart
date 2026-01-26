import 'package:get/get.dart';
import '../../../data/models/live_stream_model.dart';
import '../../../data/services/streaming_service.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  final StreamingService _streamingService = StreamingService();
  final streams = <LiveStreamModel>[].obs;
  final isLoading = false.obs;
  
  final selectedFilter = "All".obs;
  final filters = ["All", "Free", "Paid"];
  
  final isSearching = false.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchStreams();
  }

  void onChangeFilter(String filter) {
    if (selectedFilter.value == filter) return;
    selectedFilter.value = filter;
    fetchStreams();
  }

  Future<void> fetchStreams() async {
    isLoading.value = true;
    try {
      List<LiveStreamModel> result;
      
      switch (selectedFilter.value) {
        case "Free":
           result = await _streamingService.getFreeLiveStreams();
           break;
        case "Paid":
           result = await _streamingService.getPremiumLiveStreams();
           break;
        case "All":
        default:
           result = await _streamingService.getAllLiveStreams();
           break;
      }
      
      streams.assignAll(result);
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
