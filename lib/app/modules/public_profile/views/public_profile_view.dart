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

        final dynamic shadyVal = user['shady'] ?? 0;
        final double shady = (shadyVal is int) ? shadyVal.toDouble() : (shadyVal as double);
        final double legit = 100 - shady;

        return RefreshIndicator(
          onRefresh: () => controller.fetchProfile(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
              // Header with Profile Picture and Name
              _buildModernHeader(user),
              
              const SizedBox(height: 10),
              
              // Bio Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  user['bio'] ?? "Aliquam pulvinar vestibulum blandit. Donec sed nisl libero. Fusce dignissim luctus sem eu dapibus. P",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13, height: 1.5),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Stats Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem("${user['followers_count'] ?? '100k'}", "Followers"),
                    _buildStatItem("${user['following_count'] ?? '12'}", "Following"),
                    _buildStatItem("${user['total_likes'] ?? '150k'}", "Likes"),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Trust Score Section (Premium Card)
              _buildTrustScoreCard(legit, shady),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.toggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3333FF), // Vibrant Blue
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: Text(
                          controller.isFollowing.value ? "Unfollow" : "Follow", 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ),
                    ),
                    // const SizedBox(width: 12),
                    // Expanded(
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(25),
                    //       border: Border.all(color: Colors.white12),
                    //       color: const Color(0xFF1E1E26),
                    //     ),
                    //     child: TextButton(
                    //       onPressed: () {}, // "Connect" logic
                    //       style: TextButton.styleFrom(
                    //         padding: const EdgeInsets.symmetric(vertical: 16),
                    //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    //       ),
                    //       child: const Text("Connect", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Custom Tab Divider
              const Divider(color: Colors.white10, height: 1),
              
              const SizedBox(height: 20),
              
              // Tabs
              _buildModernTabs(),
              
              const SizedBox(height: 30),
              
              // Conditional Content: Personal Info or Past Streams
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.selectedTab.value == "All") ...[
                      const Text("Personal Info", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _buildInfoRow("Female"), 
                      _buildInfoRow("21 years old"),
                      _buildInfoRow("UK"),
                      _buildInfoRow("189 Friends"),
                      _buildInfoRow("21 years old"),
                      const SizedBox(height: 30),
                      _buildStreamGrid(user['past_streams']),
                    ] else ...[
                       _buildStreamGrid(user['past_streams']),
                    ]
                  ],
                ),
              ),
              
              const SizedBox(height: 50),
            ],
          ),
        )
        );
      }),
    );
  }

  Widget _buildModernHeader(user) {
    return SizedBox(
      height: 420,
      child: Stack(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                   (user['profile_image'] != null && user['profile_image'].isNotEmpty)
                    ? AuthService.getFullUrl(user['profile_image'])
                    : "https://via.placeholder.com/400"
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFF007F), width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundImage: NetworkImage(
                       (user['profile_image'] != null && user['profile_image'].isNotEmpty)
                          ? AuthService.getFullUrl(user['profile_image'])
                          : "https://via.placeholder.com/150"
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${user['first_name']} ${user['last_name'] ?? ''}",
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
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

  Widget _buildTrustScoreCard(double legit, double shady) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF13131D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Trust Score", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              Text("${legit.toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
              ),
              FractionallySizedBox(
                widthFactor: legit / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF00FF99), Color(0xFF00FF77)]),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF00FF99).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("92 Legit", style: TextStyle(color: Colors.white54, fontSize: 11)),
              Text("8% Suspicious", style: TextStyle(color: Color(0xFFFF3B30), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabs() {
    final List<String> tabs = ["All", "Past Streams", "Insights"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: tabs.map((tab) {
          return Obx(() {
            final isSelected = controller.selectedTab.value == tab;
            return GestureDetector(
              onTap: () => controller.selectedTab.value = tab,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3333FF) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white38,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
    );
  }

  Widget _buildStreamGrid(dynamic streams) {
    if (streams == null || (streams as List).isEmpty) return const SizedBox.shrink();
    
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: (streams as List).length,
      itemBuilder: (context, index) {
        final stream = streams[index];
        final thumbnailUrl = AuthService.getFullUrl(stream['thumbnail'] ?? "");
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(image: NetworkImage(thumbnailUrl), fit: BoxFit.cover),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(radius: 8, backgroundColor: Colors.white10, backgroundImage: NetworkImage("https://via.placeholder.com/30")),
                        const SizedBox(width: 6),
                        const Expanded(child: Text("Ana Fox", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text("Evening Hangout", style: TextStyle(color: Colors.white60, fontSize: 9)),
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2)),
                      child: Row(
                        children: [
                          Expanded(flex: 7, child: Container(decoration: const BoxDecoration(color: Color(0xFF00FF99), borderRadius: BorderRadius.horizontal(left: Radius.circular(2))))),
                          Expanded(flex: 3, child: Container(decoration: const BoxDecoration(color: Color(0xFFFF007F), borderRadius: BorderRadius.horizontal(right: Radius.circular(2))))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text("Legit: 98%", style: TextStyle(color: Colors.white54, fontSize: 8)),
                         Text("Shady: 2%", style: TextStyle(color: Color(0xFFFF007F), fontSize: 8)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
