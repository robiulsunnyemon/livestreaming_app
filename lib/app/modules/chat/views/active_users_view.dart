import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../controllers/active_users_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/conversation_model.dart';

class ActiveUsersView extends GetView<ActiveUsersController> {
  const ActiveUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Message',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            width: 150,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                filled: true,
                fillColor: Colors.black26,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.activeUsers.isEmpty && controller.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAllData,
          color: Colors.blueAccent,
          child: CustomScrollView(
            slivers: [
              // Active Users Horizontal List
              SliverToBoxAdapter(
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.only(top: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: controller.activeUsers.length,
                    itemBuilder: (context, index) {
                      final user = controller.activeUsers[index];
                      return _buildActiveUserAvatar(user);
                    },
                  ),
                ),
              ),

              // "Chats" Title
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Recent Conversations Vertical List
              if (controller.conversations.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      "No recent chats",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
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

  Widget _buildActiveUserAvatar(UserModel user) {
    return GestureDetector(
      onTap: () => controller.startChat(user),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.pinkAccent, width: 2),
              ),
              child: CircleAvatar(
                radius: 30,
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
              bottom: 8,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0F121D), width: 2.5),
                ),
              ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty
            ? NetworkImage(AuthService.getFullUrl(user.profileImage))
            : null,
            child: user.profileImage == null || user.profileImage!.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          if (user.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0F121D), width: 2.5),
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
        ),
      ),
      subtitle: Text(
        conversation.lastMessage ?? (conversation.lastImageUrl != null ? "Sent an image" : ""),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(conversation.createdAt),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          if (conversation.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFE91E63),
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

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
