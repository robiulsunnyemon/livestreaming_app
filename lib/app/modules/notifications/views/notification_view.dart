import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';
import '../../../data/models/notification_model.dart';
import '../../../core/theme/app_colors.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground, // Dark background
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.blueAccent),
            onPressed: controller.markAllRead,
            tooltip: "Mark all as read",
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.notifications.isEmpty) {
          return const Center(
            child: Text("No notifications", style: TextStyle(color: Colors.white54)),
          );
        }

        // Grouping logic (simplified for now: This Week vs Older)
        final now = DateTime.now();
        final thisWeek = <NotificationModel>[];
        final older = <NotificationModel>[];

        for (var n in controller.notifications) {
          if (now.difference(n.createdAt).inDays < 7) {
            thisWeek.add(n);
          } else {
            older.add(n);
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (thisWeek.isNotEmpty) ...[
                const Text("This week", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...thisWeek.map((n) => _buildNotificationItem(n)).toList(),
                const SizedBox(height: 24),
              ],

              if (older.isNotEmpty) ...[
                const Text("Old Notifications", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                 ...older.map((n) => _buildNotificationItem(n)).toList(),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return GestureDetector(
      onTap: () => controller.markRead(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: _getTypeColor(notification.type).withValues(alpha: 0.2),
              child: Icon(_getTypeIcon(notification.type), color: _getTypeColor(notification.type)),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                  ),
                ],
              ),
            ),
            
            // Unread Dot & Time
            Column(
              children: [
                if (!notification.isRead)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.accent, // Pink dot from screenshot
                      shape: BoxShape.circle,
                    ),
                  ),
                // Text(
                //   DateFormat('d MMM').format(notification.createdAt),
                //   style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
                // )
              ],
            )
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case "LIVE": return Icons.videocam;
      case "FINANCE": return Icons.monetization_on;
      case "SYSTEM": return Icons.info;
      default: return Icons.person;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case "LIVE": return Colors.redAccent;
      case "FINANCE": return Colors.greenAccent;
      case "SYSTEM": return Colors.blueAccent;
      default: return Colors.purpleAccent;
    }
  }
}
