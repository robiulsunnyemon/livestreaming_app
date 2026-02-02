import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/active_users_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/conversation_model.dart';
import '../../../core/theme/app_colors.dart';

class ActiveUsersView extends GetView<ActiveUsersController> {
  const ActiveUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Message',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            width: 150,
            child: TextField(
              controller: controller.searchTextController,
              onChanged: (val) => controller.search(val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.activeUsers.isEmpty && controller.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.searchResults.isNotEmpty) {
          // ... (Search results styling update if needed, but keeping simple for now)
          return ListView.builder(
            itemCount: controller.searchResults.length,
            itemBuilder: (context, index) {
              final user = controller.searchResults[index];
              return ListTile(
                onTap: () => controller.startChat(user),
                leading: CircleAvatar(
                   backgroundImage: user.profileImage != null ? NetworkImage(AuthService.getFullUrl(user.profileImage)) : null,
                ),
                title: Text(user.fullName, style: const TextStyle(color: Colors.white)),
                // ...
              );
            },
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAllData,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            slivers: [
              // Active Users Horizontal List
              SliverToBoxAdapter(
                child: Container(
                  height: 110,
                  padding: const EdgeInsets.only(top: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: controller.activeUsers.isEmpty ? (controller.currentUser.value != null ? 1 : 0) : controller.activeUsers.length,
                    itemBuilder: (context, index) {
                      if (controller.activeUsers.isEmpty) {
                        return _buildActiveUserAvatar(controller.currentUser.value!, isSelf: true,context: context);
                      }
                      final user = controller.activeUsers[index];
                      return _buildActiveUserAvatar(user,context: context);
                    },
                  ),
                ),
              ),

              // "Chats" Title
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Recent Conversations Vertical List
              if (controller.conversations.isEmpty)
                 const SliverFillRemaining(
                   hasScrollBody: false,
                   child: Center(child: Text("No chats yet", style: TextStyle(color: Colors.grey))),
                 )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final conversation = controller.conversations[index];
                      return _buildConversationItem(conversation);
                    },
                    childCount: controller.conversations.length,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActiveUserAvatar(UserModel user, {bool isSelf = false,required BuildContext context}) {
    return GestureDetector(
      onTap: isSelf ? null : () => _showUserOptions(context, user),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 2), // Pink ring
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty
                        ? NetworkImage(AuthService.getFullUrl(user.profileImage))
                        : null,
                    child: user.profileImage == null || user.profileImage!.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isSelf ? "You" : (user.firstName ?? "User"),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    final user = conversation.otherUser;
    
    return ListTile(
      onTap: () => controller.startChatWithConversation(conversation),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[800],
            backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty
            ? NetworkImage(AuthService.getFullUrl(user.profileImage))
            : null,
            child: user.profileImage == null || user.profileImage!.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          if (user.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        user.fullName ?? "User",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          conversation.lastMessage ?? (conversation.lastImageUrl != null ? "Sent an image" : ""),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(conversation.createdAt),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          const SizedBox(height: 6),
          if (conversation.unreadCount > 0)
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  void _showUserOptions(BuildContext context, UserModel user) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.blueAccent),
              title: const Text("Send Message", style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                controller.startChat(user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.secondaryPrimary),
              title: const Text("View Profile", style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                Get.toNamed(Routes.PUBLIC_PROFILE, arguments: user.id);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
