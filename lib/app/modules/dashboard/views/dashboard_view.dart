import 'package:instalive/app/modules/chat/views/active_users_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/views/home_view.dart';
import '../../explore/views/explore_view.dart';
import '../../profile/views/profile_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: [
          const HomeView(),
          const ExploreView(),
          Container(), // Placeholder for Start Live (handled by controller logic)
          const ActiveUsersView(),
          const ProfileView(),
        ],
      )),
      bottomNavigationBar: Obx(() => Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF0B0B15),
          border: Border(top: BorderSide(color: Colors.grey.shade900)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
             _buildNavItem(0, Icons.home_outlined, Icons.home),
             _buildNavItem(1, Icons.explore_outlined, Icons.explore),
             _buildLiveButton(),
             _buildNavItem(3, Icons.chat_bubble_outline, Icons.chat_bubble),
             _buildNavItem(4, Icons.person_outline, Icons.person),
          ],
        ),
      )),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon) {
    final isSelected = controller.currentIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changePage(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: isSelected 
          ? BoxDecoration(
              color:AppColors.secondaryPrimary,
              borderRadius: BorderRadius.circular(16),
            )
          : null,
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? Colors.white : Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildLiveButton() {
    return GestureDetector(
      onTap: () => controller.changePage(2),
      child: Container(
        width: 48,
        height: 48,
         decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
        child: const Icon(Icons.videocam, color: Colors.white),
      ),
    );
  }
}
