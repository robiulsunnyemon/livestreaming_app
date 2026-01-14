import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/start_live_controller.dart';

class StartLiveView extends GetView<StartLiveController> {
  const StartLiveView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Live'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             TextField(
              controller: controller.roomNameController,
              decoration: const InputDecoration(
                labelText: 'Room Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: controller.startLive,
                    child: const Text('Start Live Stream'),
                  )),
          ],
        ),
      ),
    );
  }
}
