import 'package:erron_live_app/app/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';
import '../../../core/theme/app_colors.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Dark background
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final user = controller.user.value;
        if (user == null) {
          return Center(child: TextButton(onPressed: controller.fetchProfile, child: const Text("Retry"))); 
        }
        final shady=user.shady;
        final double legit=100- shady;

        return SingleChildScrollView(
          child: Column(
            children: [
              // 1. Cover + Profile Header Stack
              SizedBox(
                height: 380, // Approximate height for header section
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Cover Image
                    GestureDetector(
                     // onTap: () => controller.pickAndUploadImage(false),
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              user.coverImage != null && user.coverImage!.isNotEmpty
                               ? user.coverImage! 
                               : "https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=2029&auto=format&fit=crop"
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        // child: Container(
                        //   decoration: BoxDecoration(
                        //     gradient: LinearGradient(
                        //       begin: Alignment.topCenter,
                        //       end: Alignment.bottomCenter,
                        //       colors: [Colors.black.withOpacity(0.1), AppColors.background],
                        //     ),
                        //   ),
                        //   child: Align(
                        //     alignment: Alignment.topRight,
                        //     child: SafeArea(
                        //       child: Padding(
                        //         padding: const EdgeInsets.only(top: 10, right: 60), // Avoid more_vert
                        //         child: CircleAvatar(
                        //           backgroundColor: Colors.black45,
                        //           radius: 18,
                        //           child: IconButton(
                        //             icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        //             onPressed: () => controller.pickAndUploadImage(false),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ),
                    ),
                    
                    // Profile Content Card Overlay
                    Positioned(
                      top: 150, // Overlap cover
                      child: Column(
                        children: [
                          // Profile Stack
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              GestureDetector(
                             //   onTap: () => controller.pickAndUploadImage(true),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.accent, width: 2), // Pink border
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage: NetworkImage(
                                      user.profileImage != null && user.profileImage!.isNotEmpty
                                          ? user.profileImage!
                                          : "https://via.placeholder.com/150"
                                    ),backgroundColor: Colors.grey[800],
                                    child: (user.profileImage == null || user.profileImage!.isEmpty)
                                        ? const Icon(Icons.person, size: 60, color: Colors.white60)
                                        : null,
                                  ),
                                ),
                              ),
                              // Positioned(
                              //   bottom: 5,
                              //   right: 5,
                              //   child: GestureDetector(
                              //     onTap: () => controller.pickAndUploadImage(true),
                              //     child: Container(
                              //       padding: const EdgeInsets.all(6),
                              //       decoration: const BoxDecoration(
                              //         color: AppColors.primary,
                              //         shape: BoxShape.circle,
                              //       ),
                              //       child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.fullName,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              user.bio ?? "No bio available.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Top Bar Actions
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.arrow_back, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem("${user.followersCount}", "Followers"),
                    _buildStatItem("${user.followingCount}", "Following"),
                    _buildStatItem("${user.totalLikes}", "Likes"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 3. Trust Score Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Trust Score", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text("$legit%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Trust Bar
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                         color: Colors.grey.withOpacity(0.2),
                         borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: legit.toInt(),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.vibrantSuccess,
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(3)),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: shady.toInt(),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(3)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("$legit% Legit", style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                        Text("$shady% Suspicious", style: const TextStyle(color: Colors.redAccent, fontSize: 10)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed(Routes.START_LIVE),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Go Live", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                         onPressed: () => Get.toNamed(Routes.EDIT_PROFILE), // Edit Profile action
                         style: OutlinedButton.styleFrom(
                           side: BorderSide(color: Colors.grey.shade700),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                           padding: const EdgeInsets.symmetric(vertical: 12),
                         ),
                         child: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5. Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: controller.tabs.map((tab) {
                    return Obx(() {
                      final isSelected = controller.selectedTab.value == tab;
                      return GestureDetector(
                        onTap: () => controller.selectedTab.value = tab,
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.secondaryPrimary : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade800),
                          ),
                          child: Text(
                            tab,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade400,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, 
                            ),
                          ),
                        ),
                      );
                    });
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // 6. Personal Info & Grid Content (Placeholder based on screenshot)
              Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 20),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         const Text("Personal Info", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          GestureDetector(
                              onTap: () => Get.toNamed(Routes.EDIT_PROFILE),
                              child: Icon(Icons.edit, color: Colors.grey, size: 18)),

                       ],
                     ),
                     const SizedBox(height: 10),
                     Text("Male", style: TextStyle(color: Colors.grey.shade400)),
                     Text("21 years old", style: TextStyle(color: Colors.grey.shade400)),
                     Text(user.country ?? "Unknown Location", style: TextStyle(color: Colors.grey.shade400)),
                     const SizedBox(height: 20),
                   ],
                 ),
              ),

              // Content based on Tab
              if (controller.selectedTab.value == "Insights") ...[
                _buildInsights(context,user),
              ] else ...[
                // Grid Content (Past Streams)
                if(user.pastStreams.isNotEmpty)
                  GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: user.pastStreams.isNotEmpty ? user.pastStreams.length : 0, // Mock if empty
                  itemBuilder: (context, index) {
                     if (user.pastStreams.isEmpty) {
                       // Placeholder cards if no streams
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF161621),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                        );
                     }
                    final stream = user.pastStreams[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(stream.thumbnail ?? "https://via.placeholder.com/300"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(stream.title ?? "Stream", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                ),
                if(user.pastStreams.isEmpty)
                  const Text("You have not past stream",style: TextStyle(color: Colors.white),),
                
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInsights(BuildContext context, UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("My Wallet"),
          const SizedBox(height: 16),
          // Gradient Wallet Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondaryPrimary, AppColors.purple], // Purple gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Available Balance", style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Obx(() => Text("${controller.coinBalance.value.toInt()}", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
                         const Text("Tokens", style: TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                    Container(height: 40, width: 1, color: Colors.white24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Obx(() => Text("\$${controller.fiatValue.value.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
                         const Text("Tokens", style: TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed(Routes.PAYMENT_HISTORY),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text("History", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (user.kyc?.status=="approved") {
                            Get.toNamed(Routes.WITHDRAW_TO);
                          } else {
                            Get.toNamed(Routes.KYC);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text("Withdraw", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildSectionHeader("Buy Tokens"),
          const SizedBox(height: 16),
          // Token Packages Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
            children: [
              _buildTokenCard(100, 0.99),
              _buildTokenCard(500, 4.99),
              _buildTokenCard(1200, 9.99),
              _buildTokenCard(6500, 49.99),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildTokenCard(int tokens, double price) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: const Icon(Icons.token, color: Colors.amber, size: 24),
          ),
          const SizedBox(height: 12),
          Text("$tokens", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("Tokens", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.buyTokens(tokens, price),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryPrimary, // Blue
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
            child: Text("\$$price Pay", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
