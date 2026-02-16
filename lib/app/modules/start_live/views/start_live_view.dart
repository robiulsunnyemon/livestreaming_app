import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/start_live_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../data/services/auth_service.dart';

class StartLiveView extends GetView<StartLiveController> {
  const StartLiveView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false, // Prevent background from resizing when keyboard opens
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background (Camera Placeholder)
          // In a real app, this would be the CameraPreview widget
          Obx(() {
            final user = profileController.user.value;
            final coverUrl = (user?.coverImage != null && user!.coverImage!.isNotEmpty)
                ? AuthService.getFullUrl(user.coverImage!)
                : "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1964&auto=format&fit=crop";
                
            return Image.network(
              coverUrl, 
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade900),
            );
          }),
          
          // Overlay Gradient for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // 2. Top Bar Controls
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close Button
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: CircleAvatar(
                        backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
                        radius: 18,
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                    
                    // "Not Live" Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.circle, color: Colors.pinkAccent, size: 8),
                          SizedBox(width: 6),
                          Text("Not Live", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),

                    // Camera Switch Button (Placeholder action)
                    CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.4),
                      radius: 18,
                      child: const Icon(Icons.cameraswitch_outlined, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Bottom Controls Area
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.95), // Dark background matching design
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Handles/Indicator
                   Center(
                     child: Container(
                       width: 40,
                       height: 4,
                       decoration: BoxDecoration(
                         color: Colors.grey.shade700,
                         borderRadius: BorderRadius.circular(2),
                       ),
                     ),
                   ),
                   const SizedBox(height: 24),

                  // Stream Title Input
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade700),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         const SizedBox(height: 8),
                         Text("Stream Title", style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                        TextField(
                          controller: controller.titleController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: "What are you streaming today?",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(bottom: 8, top: 4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Selector
                  GestureDetector(
                    onTap: () {
                      _showCategoryPicker(context);
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text("Stream Category", style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                           const SizedBox(height: 4),
                           Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(controller.selectedCategory.value, style: const TextStyle(color: Colors.white, fontSize: 14)),
                              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                            ],
                          ),
                         ]
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mode Toggle (Public / Paid Entry)
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.isPremium.value = false,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: !controller.isPremium.value ? AppColors.secondaryPrimary : Colors.transparent, // Blue when selected
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.public, color: !controller.isPremium.value ? Colors.white : Colors.grey, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Public", 
                                      style: TextStyle(
                                        color: !controller.isPremium.value ? Colors.white : Colors.grey,
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.isPremium.value = true,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: controller.isPremium.value ? AppColors.warning : Colors.transparent, // Gold when selected
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock_outline, color: controller.isPremium.value ? Colors.black : Colors.grey, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Paid Entry", 
                                      style: TextStyle(
                                        color: controller.isPremium.value ? Colors.black : Colors.grey,
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Entry Fee Input (Conditional)
                  if (controller.isPremium.value) ...[
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                       child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           const SizedBox(height: 8),
                           Row(
                             children: [
                               Text("Entry Fee", style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                               const Spacer(),
                             ],
                           ),
                           Row(
                             children: [
                               const Icon(Icons.diamond_outlined, color: Colors.white, size: 18), // Coin icon
                               const SizedBox(width: 8),
                               Expanded(
                                 child: TextField(
                                  controller: controller.entryFeeController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(bottom: 8, top: 4),
                                  ),
                                                         ),
                               ),
                               Column(
                                 children: [
                                    Icon(Icons.keyboard_arrow_up, color: Colors.grey, size: 16),
                                    Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
                                 ]
                               )
                             ],
                           ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Viewers get a 3-second preview before paying.", 
                      style: TextStyle(color: Colors.grey, fontSize: 10)
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Go Live Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.startLive,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isPremium.value ? AppColors.warning : AppColors.secondaryPrimary,
                        foregroundColor: controller.isPremium.value ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 8,
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Go Live", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Category", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: controller.categories.length,
                separatorBuilder: (_, _) => Divider(color: Colors.grey.shade800),
                itemBuilder: (context, index) {
                  final cat = controller.categories[index];
                  return ListTile(
                    title: Text(cat, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      controller.selectedCategory.value = cat;
                      Get.back();
                    },
                    trailing: controller.selectedCategory.value == cat ? const Icon(Icons.check, color: AppColors.primary) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    ).then((_) {
        // Handle closure if needed
    });
  }
}
