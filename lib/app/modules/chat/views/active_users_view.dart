import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/active_users_controller.dart';

class ActiveUsersView extends GetView<ActiveUsersController> {
  const ActiveUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Users'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.activeUsers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.activeUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[700]),
                const SizedBox(height: 16),
                const Text(
                  "No active users found",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                TextButton(
                  onPressed: controller.fetchActiveUsers,
                  child: const Text("Refresh"),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchActiveUsers,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.activeUsers.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final user = controller.activeUsers[index];
              return ListTile(
                onTap: () => controller.startChat(user),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty
                          ? NetworkImage(user.profileImage!)
                          : null,
                      child: user.profileImage == null || user.profileImage!.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  user.fullName ?? "Guest User",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Active Now", style: TextStyle(color: Colors.green, fontSize: 12)),
                trailing: const Icon(Icons.chat_bubble_outline, color: Colors.blueAccent),
              );
            },
          ),
        );
      }),
    );
  }
}
