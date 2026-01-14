import 'package:get/get.dart';
import '../../../data/services/streaming_service.dart';
import 'package:flutter/material.dart';

import '../../../routes/app_pages.dart';

class StartLiveController extends GetxController {
  final TextEditingController roomNameController = TextEditingController();
  final StreamingService _streamingService = StreamingService();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    roomNameController.dispose();
    super.onClose();
  }

  Future<void> startLive() async {
    if (roomNameController.text.isEmpty) {
      Get.snackbar("Error", "Please enter a room name");
      return;
    }

    try {
      isLoading.value = true;
      String token = await _streamingService.getToken(
        roomName: roomNameController.text,
        participantName: "Host", // Assuming user is host or getting name from profile
        isHost: true,
      );
      
      Get.toNamed(Routes.LIVE_STREAMING, arguments: {
        "token": token,
        "room_name": roomNameController.text,
        "is_host": true,
      });

    } catch (e) {
      Get.snackbar("Error", "Failed to start live: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
