import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/public_profile_controller.dart';
import '../../../data/services/auth_service.dart';

class PublicProfileView extends GetView<PublicProfileController> {
  const PublicProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final user = controller.userProfile.value;
        if (user == null) {
          return const Center(child: Text("User not found", style: TextStyle(color: Colors.white)));
        }

        // Handle types (int/float)
        final dynamic shadyVal = user['shady'] ?? 0;
        final double shady = (shadyVal is int) ? shadyVal.toDouble() : (shadyVal as double);
        final double legit = 100 - shady;

        return SingleChildScrollView(
          child: Column(
            children: [
               // Header Stack
               SizedBox(
                 height: 380,
                 child: Stack(
                   alignment: Alignment.topCenter,
                   children: [
                     // Cover
                     Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              (user['cover_image'] != null && user['cover_image'].isNotEmpty)
                               ? AuthService.getFullUrl(user['cover_image'])
                               : "https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=2029&auto=format&fit=crop"
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                     ),
                     // Back Button
                     Positioned(
                       top: 40,
                       left: 16,
                       child: IconButton(
                         icon: Container(
                           padding: const EdgeInsets.all(8),
                           decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                           child: const Icon(Icons.arrow_back, color: Colors.white),
                         ),
                         onPressed: () => Get.back(),
                       ),
                     ),
                     
                     // Profile Content
                     Positioned(
                       top: 150,
                       child: Column(
                         children: [
                            Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.accent, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundImage: NetworkImage(
                                    (user['profile_image'] != null && user['profile_image'].isNotEmpty)
                                        ? AuthService.getFullUrl(user['profile_image'])
                                        : "https://via.placeholder.com/150"
                                  ),
                                  backgroundColor: Colors.grey[800],
                                ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "${user['first_name']} ${user['last_name'] ?? ''}",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                user['bio'] ?? "No bio available.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              ),
                            ),
                         ],
                       ),
                     )
                   ],
                 ),
               ),
               
               // Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem("${user['followers_count'] ?? 0}", "Followers"),
                    _buildStatItem("${user['following_count'] ?? 0}", "Following"),
                    _buildStatItem("${user['total_likes'] ?? 0}", "Likes"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Trust Score
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
                          Text("${legit.toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                     ),
                     const SizedBox(height: 8),
                     Container(
                       height: 6,
                       decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(3)),
                       child: Row(
                         children: [
                           Expanded(flex: legit.toInt(), child: Container(decoration: const BoxDecoration(color: AppColors.vibrantSuccess, borderRadius: BorderRadius.horizontal(left: Radius.circular(3))))),
                           Expanded(flex: shady.toInt(), child: Container(decoration: const BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.horizontal(right: Radius.circular(3))))),
                         ],
                       ),
                     )
                   ],
                 ),
              ),
              const SizedBox(height: 20),
              
              // Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.toggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.isFollowing.value ? Colors.grey[800] : AppColors.secondaryPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(controller.isFollowing.value ? "Unfollow" : "Follow", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                         onPressed: controller.messageUser,
                         style: OutlinedButton.styleFrom(
                           side: BorderSide(color: Colors.grey.shade700),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                           padding: const EdgeInsets.symmetric(vertical: 12),
                         ),
                         child: const Text("Message", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Tabs and Content
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
              
               if (controller.selectedTab.value == "All") ...[
                  Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text("Personal Info", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 10),
                         Text("Gender: ${user['gender'] ?? 'Unknown'}", style: TextStyle(color: Colors.grey.shade400)),
                         Text("Country: ${user['country'] ?? 'Unknown Location'}", style: TextStyle(color: Colors.grey.shade400)),
                       ],
                     ),
                  )
               ] else ...[
                   if(user['past_streams'] != null && (user['past_streams'] as List).isNotEmpty)
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
                        itemCount: (user['past_streams'] as List).length,
                        itemBuilder: (context, index) {
                           final stream = user['past_streams'][index];
                           final thumbnail = stream['thumbnail'];
                           final hostImage = user['profile_image'];
                           final imageUrl = (thumbnail != null && thumbnail.isNotEmpty) ? thumbnail : (hostImage ?? "https://via.placeholder.com/150");
                           
                           return Container(
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(16),
                               image: DecorationImage(
                                 image: NetworkImage(AuthService.getFullUrl(imageUrl)),
                                 fit: BoxFit.cover,
                               ),
                             ),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(stream['title'] ?? "Stream", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                           );
                        }
                      )
                   else 
                      const Center(child: Text("No past streams", style: TextStyle(color: Colors.grey))),
               ],
               
               const SizedBox(height: 40),
            ],
          ),
        );
      }),
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
