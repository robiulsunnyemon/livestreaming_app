import 'package:get/get.dart';
import '../../../data/services/streaming_service.dart';
import 'package:flutter/material.dart';

import '../../../routes/app_pages.dart';

class StartLiveController extends GetxController {
  final StreamingService _streamingService = StreamingService();

  final isPremium = false.obs;
  final TextEditingController entryFeeController = TextEditingController(text: "0");
  final TextEditingController titleController = TextEditingController();
  final selectedCategory = "Just fun".obs;
  
  final List<String> categories = [
    "Just fun",
    "Fitness",
    "Health",
    "Fashion",
    "Cultural",
    "Travels",
  ];

  final isLoading = false.obs;

  @override
  void onClose() {
    entryFeeController.dispose();
    titleController.dispose();
    super.onClose();
  }

  Future<void> startLive() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar("Error", "Please enter a stream title");
      return;
    }

    try {
      isLoading.value = true;
      double fee = double.tryParse(entryFeeController.text) ?? 0;
      
      final result = await _streamingService.startStream(
        isPremium: isPremium.value,
        entryFee: fee,
        title: title,
        category: selectedCategory.value,
      );
      
      Get.toNamed(Routes.LIVE_STREAMING, arguments: {
        "token": result['livekit_token'],
        "room_name": result['channel_name'], 
        "is_host": true,
        "session_id": result['live_id'],
        "title": title,
        "category": selectedCategory.value,
        "is_premium": isPremium.value,
        "has_paid": true,
        "entry_fee": result['entry_fee'] ?? 0.0,
      });

    } catch (e) {
      Get.snackbar("Error", "Failed to start live: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
