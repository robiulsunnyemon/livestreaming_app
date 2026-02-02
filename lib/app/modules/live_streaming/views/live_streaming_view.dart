import 'dart:ui';
import 'package:instalive/app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/live_streaming_controller.dart';

class LiveStreamingView extends GetView<LiveStreamingController> {
  const LiveStreamingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for video
      body: Stack(
        children: [
          // 1. Video Layer
          Positioned.fill(
            child: Obx(() {
              if (!controller.isConnected.value) {
                if (controller.errorMessage.isNotEmpty) {
                    return Center(child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                    ));
                }
                return const Center(child: CircularProgressIndicator());
              }

              // Logic: specific to Bigo-like apps. 
              // Usually there is 1 MAIN HOST video covering the screen.
              
              VideoTrack? mainTrack;
              
              if (controller.isHost) {
                 mainTrack = controller.localVideoTrack.value;
              } else if (controller.remoteVideoTracks.isNotEmpty) {
                 // Usually the first remote track is the host
                 mainTrack = controller.remoteVideoTracks.first;
              }

              if (mainTrack == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       // If host, show profile pic or "Camera Off"
                       // If viewer, show "Waiting for host..."
                       if (controller.isHost)
                         Column(
                           children: [
                             CircleAvatar(
                               radius: 50,
                               backgroundColor: Colors.grey.shade800,
                               backgroundImage: controller.currentUser.value?.profileImage != null 
                                 ? NetworkImage(controller.currentUser.value!.profileImage!) 
                                 : null,
                               child: const Icon(Icons.videocam_off, size: 40, color: Colors.white),
                             ),
                             const SizedBox(height: 10),
                             const Text("Camera Off", style: TextStyle(color: Colors.white)),
                           ],
                         )
                       else
                         const Text(
                          "Waiting for host...", 
                          style: TextStyle(color: Colors.white)
                        )
                    ],
                  )
                );
              }

              return Obx(() {
                 bool isGuest = !AuthService.to.isLoggedIn;
                 bool shouldBlur = (controller.isPremium.value && 
                                   !controller.hasPaid.value && 
                                   !controller.isPreviewMode.value && 
                                   !controller.isHost) || isGuest;
                                  
                 return ImageFiltered(
                   imageFilter: ImageFilter.blur(
                     sigmaX: shouldBlur ? 15 : 0, 
                     sigmaY: shouldBlur ? 15 : 0
                   ),
                   child: VideoTrackRenderer(
                     mainTrack!,
                     fit: VideoViewFit.cover,
                   ),
                 );
              });
            }),
          ),

          // 2. Overlay Layer (Chat, Hearts, Controls)
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // Top Bar (Close button, Host info)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        if (AuthService.to.isLoggedIn)
                          // Host Profile Card (Glassmorphism)
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor: AppColors.tertiary,
                                          child: CircleAvatar(
                                            radius: 13,
                                            backgroundColor: Colors.grey,
                                            backgroundImage: controller.hostProfileImage.value.isNotEmpty
                                                ? NetworkImage(AuthService.getFullUrl(controller.hostProfileImage.value))
                                                : null,
                                            child: controller.hostProfileImage.value.isEmpty
                                                ? const Icon(Icons.person, color: Colors.white, size: 20)
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                controller.hostFullName.value,
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              const SizedBox(height: 2),
                                              // Dynamic Progress Bar
                                              Container(
                                                width: 70,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(2),
                                                  color: AppColors.tertiary,// Shady part
                                                ),
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Container(
                                                    width: 70 * (controller.hostLegit.value / (controller.hostLegit.value + controller.hostShady.value == 0 ? 100 : controller.hostLegit.value + controller.hostShady.value)),
                                                    height: 4,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(3),
                                                      color: Colors.greenAccent, // Legit part
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        // Follow/Unfollow Button
                                        if (!controller.isHost)
                                          GestureDetector(
                                            onTap: controller.toggleFollow,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: AppColors.tertiary,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                controller.isFollowing.value ? "Unfollow" : "Follow",
                                                style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 4),
                                      ],
                                    ),
                                  )),
                                ),
                                const SizedBox(width: 8),
                                // 3s Preview Countdown Badge
                                Obx(() {
                                   final isPreview = controller.isPreviewMode.value;
                                   final time = controller.countdown.value;
                                   if (isPreview) {
                                     return Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                       decoration: BoxDecoration(
                                         color: Colors.yellowAccent,
                                         borderRadius: BorderRadius.circular(20),
                                       ),
                                       child: Text(
                                         "Preview ${time}s",
                                         style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                                       ),
                                     );
                                   }
                                   return const SizedBox.shrink();
                                }),
                                const Spacer(),
                              ],
                            ),
                          )
                        else 
                          const Spacer(),

                        CircleAvatar(
                          radius: 15,
                          backgroundColor: AppColors.tertiary,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close, color: Colors.white, size: 16),
                            onPressed: controller.leaveRoom,
                          ),
                        )
                      ],
                    ),
                  ),

                  const Spacer(),
                  
                  // 3. User Specific Area (Payment & Comments)
                  if (AuthService.to.isLoggedIn) ...[
                    // Payment Overlay (When blurred)
                    Obx(() {
                      final premium = controller.isPremium.value;
                      final paid = controller.hasPaid.value;
                      final preview = controller.isPreviewMode.value;
                      final isHost = controller.isHost;

                      bool showPayment = premium && !paid && !preview && !isHost;
                      
                      if (!showPayment) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white24)
                                ),
                                child: const Text(
                                  "Gift token",
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: controller.payEntryFee,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white10)
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.purpleAccent.withOpacity(0.2),
                                      child: const Icon(Icons.bolt, color: Colors.purpleAccent, size: 24),
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      "${controller.entryFee.value.toInt()}",
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Comments and Input Area
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Messages List
                            Expanded(
                              child: Obx(() => ListView.builder(
                                reverse: true,
                                itemCount: controller.comments.length,
                                itemBuilder: (context, index) {
                                  final comment = controller.comments[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.grey,
                                          backgroundImage: comment['image'] != null && comment['image'].toString().isNotEmpty
                                              ? NetworkImage(comment['image'])
                                              : null,
                                          child: comment['image'] == null || comment['image'].toString().isEmpty
                                              ? const Icon(Icons.person, size: 14, color: Colors.white)
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "${comment['name']}: ",
                                                  style: TextStyle(
                                                    color: comment['is_host'] == true ? Colors.redAccent : Colors.yellowAccent, 
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14
                                                  )
                                                ),
                                                TextSpan(
                                                  text: comment['message'],
                                                  style: TextStyle(
                                                    color: comment['is_gift'] == true ? Colors.amber : Colors.white, 
                                                    fontSize: 14
                                                  )
                                                ),
                                              ]
                                            )
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )),
                            ),
                            
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(() {
                                    final premium = controller.isPremium.value;
                                    final paid = controller.hasPaid.value;
                                    bool isLocked = !controller.isHost && premium && !paid;
                                    return TextField(
                                      controller: controller.commentController,
                                      readOnly: isLocked,
                                      onTap: isLocked ? controller.payEntryFee : null,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: isLocked ? "Unlock to chat" : "Say hi...",
                                        hintStyle: const TextStyle(color: Colors.white70),
                                        filled: true,
                                        fillColor: Colors.black45,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: const BorderSide(color: Colors.white)
                                        ),
                                        suffixIcon: GestureDetector(
                                          onTap: isLocked ? controller.payEntryFee : controller.sendComment,
                                          child: Icon(
                                            isLocked ? Icons.lock : Icons.send, 
                                            color: isLocked ? Colors.amber : Colors.blueAccent
                                          ),
                                        )
                                      ),
                                      onSubmitted: isLocked ? (val) => controller.payEntryFee() : (_) => controller.sendComment(),
                                    );
                                  }),
                                ),
                                const SizedBox(width: 8),
                                if (!controller.isHost) ...[
                                  GestureDetector(
                                    onTap: () => _showGiftSheet(context),
                                    child: const CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.purpleAccent,
                                      child: Icon(Icons.card_giftcard, color: Colors.white, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: controller.sendLike,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.pinkAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.favorite, color: Colors.white, size: 20),
                                          Obx(() => Text(
                                            "${controller.totalLikes}", 
                                            style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)
                                          ))
                                        ],
                                      )
                                    )
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (controller.isHost) ...[
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Obx(() => _buildControlBtn(
                                icon: controller.isCameraEnabled.value ? Icons.videocam : Icons.videocam_off,
                                onTap: controller.toggleCamera,
                                isActive: controller.isCameraEnabled.value
                              )),
                              const SizedBox(width: 20),
                              Obx(() => _buildControlBtn(
                                icon: controller.isMicEnabled.value ? Icons.mic : Icons.mic_off,
                                onTap: controller.toggleMic,
                                isActive: controller.isMicEnabled.value
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ] else ...[
                    // 4. Guest Specific Area (Sign-in Prompt)
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Text(
                              "Sign in to join the chat",
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: 200,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => Get.toNamed(Routes.LOGIN),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryPrimary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Sign in to Chat", style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Icons.send, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
        ),
      );
  }

  void _showGiftSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            children: [
              const Text("Send a Gift", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    _buildGiftItem("Rose", "🌹", 10),
                    _buildGiftItem("Heart", "❤️", 50),
                    _buildGiftItem("Diamond", "💎", 100),
                    _buildGiftItem("Car", "🏎️", 500),
                    _buildGiftItem("Rocket", "🚀", 1000),
                    _buildGiftItem("Crown", "👑", 5000),
                  ],
                ),
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildGiftItem(String name, String icon, double price) {
    return InkWell(
      onTap: () => controller.sendGift(price),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text("$price Coins", style: const TextStyle(color: Colors.amber, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBtn({required IconData icon, required VoidCallback onTap, required bool isActive}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? Colors.black : Colors.red, size: 24),
      ),
    );
  }
}
