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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Stream Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller.titleController,
                decoration: InputDecoration(
                  labelText: 'Stream Title',
                  hintText: 'e.g. My Amazing Live Session',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: controller.selectedCategory.value,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: controller.categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) controller.selectedCategory.value = val;
                },
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text("Premium Stream", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Viewers pay coins to join", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  value: controller.isPremium.value,
                  onChanged: (val) => controller.isPremium.value = val,
                ),
              ),
              if (controller.isPremium.value) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: controller.entryFeeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Entry Fee (Coins)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.monetization_on, color: Colors.amber),
                  ),
                ),
              ],
              const SizedBox(height: 40),
              controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                      onPressed: controller.startLive,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: const Text('Start Live Stream', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    )),
            ],
          )),
        ),
      ),
    );
  }
}
