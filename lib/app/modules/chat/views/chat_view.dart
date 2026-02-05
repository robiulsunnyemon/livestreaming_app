import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/services/auth_service.dart';
import '../controllers/chat_controller.dart';
import '../../../core/theme/app_colors.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
               color: AppColors.surface,
               shape: BoxShape.circle,
            ),
             child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white)
          ),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[800],
              backgroundImage: controller.receiverImage != null 
                  ? NetworkImage(AuthService.getFullUrl(controller.receiverImage)) 
                  : null,
              child: controller.receiverImage == null 
                  ? const Icon(Icons.person, color: Colors.white) 
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.receiverName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Row(
                  children: [
                    Obx(() => Container(width: 8, height: 8, decoration: BoxDecoration(color: controller.isOnline.value ? AppColors.success : Colors.grey, shape: BoxShape.circle))),
                    const SizedBox(width: 4),
                    Obx(() => Text(controller.isOnline.value ? "Online" : "Offline", style: const TextStyle(fontSize: 12, color: Colors.grey))),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
               padding: const EdgeInsets.all(8),
               decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
               child: const Icon(Icons.call, size: 18, color: Colors.blueAccent)
            ),
             onPressed: () => controller.startCall("audio"),
          ),
          IconButton(
            icon: Container(
               padding: const EdgeInsets.all(8),
               decoration: const BoxDecoration(color: Color(0xFF161621), shape: BoxShape.circle),
               child: const Icon(Icons.videocam, size: 18, color: Colors.blueAccent)
            ),
             onPressed: () => controller.startCall("video"),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator(color:  AppColors.secondaryPrimary,));
              }
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: controller.messages.length + (controller.isTyping.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.messages.length) {
                     return Align(
                       alignment: Alignment.centerLeft,
                       child: Container(
                         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(20),
                         ),
                         child: const Text("Typing...", style: TextStyle(color: Colors.black54, fontSize: 12, fontStyle: FontStyle.italic)),
                       ),
                     );
                  }
                  final msg = controller.messages[index];
                  final isMe = msg.senderId != controller.receiverId;

                  // Find replied message if exists
                  ChatMessage? repliedMsg;
                  if (msg.repliedToId != null) {
                    try {
                      repliedMsg = controller.messages.firstWhere((m) => m.id == msg.repliedToId);
                    } catch (_) {}
                  }

                  return Dismissible(
                    key: Key(msg.id ?? index.toString()),
                    direction: isMe ? DismissDirection.none : DismissDirection.startToEnd,
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        controller.setReplyingTo(msg);
                        return false;
                      }
                      return false;
                    },
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.reply, color: Colors.blue, size: 30),
                    ),
                    child: GestureDetector(
                    onLongPress: () => _showReactionMenu(context, msg),
                    child: Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4).copyWith(bottom: msg.reactions.isNotEmpty ? 15 : 4),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: Radius.circular(isMe ? 20 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 20),
                              ),
                            ),
                            constraints: BoxConstraints(maxWidth: Get.width * 0.75),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (repliedMsg != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border(left: BorderSide(color: isMe ? Colors.white : AppColors.secondaryPrimary, width: 3)),
                                    ),
                                    child: Text(
                                      repliedMsg.message ?? "Photo",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 12),
                                    ),
                                  ),
                                if (msg.imageUrl != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        AuthService.getFullUrl(msg.imageUrl),
                                        width: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                if (msg.message != null && msg.message!.isNotEmpty)
                                  Text(
                                    msg.message!,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black87, 
                                      fontSize: 15
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (msg.reactions.isNotEmpty)
                            Positioned(
                              bottom: -5,
                              right: isMe ? 0 : null,
                              left: isMe ? null : 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24, width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Wrap(
                                  spacing: 2,
                                  children: msg.reactions.take(3).map((r) => Text(r.emoji, style: const TextStyle(fontSize: 12))).toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ));
                },
              );
            }),
          ),
          Obx(() => controller.replyingToMessage.value != null 
            ? _buildReplyPreview() 
            : const SizedBox.shrink()),
          _buildInputArea(),
          Obx(() => controller.showEmojiPicker.value 
            ? _buildEmojiPicker() 
            : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    final msg = controller.replyingToMessage.value!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      color: Colors.grey[900],
      child: Row(
        children: [
          const Icon(Icons.reply, color: AppColors.secondaryPrimary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.senderId == controller.receiverId ? controller.receiverName : "You",
                  style: const TextStyle(color:  AppColors.secondaryPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  msg.message ?? "Photo",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.white70),
            onPressed: () => controller.cancelReply(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: Row(
          children: [
             Expanded(
               child: Container(
                 padding: const EdgeInsets.symmetric(horizontal: 16),
                 decoration: BoxDecoration(
                   color: const Color(0xFF161621),
                   borderRadius: BorderRadius.circular(30),
                 ),
                 child: Row(
                   children: [
                     Expanded(
                       child: TextField(
                          controller: controller.messageController,
                          focusNode: controller.messageFocusNode,
                          onChanged: controller.onTextChanged,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Say something...",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                       ),
                     ),
                     IconButton(
                        icon: const Icon(Icons.attach_file, color: Colors.grey),
                        onPressed: () async {
                           final picker = ImagePicker();
                           final image = await picker.pickImage(source: ImageSource.gallery);
                           if(image != null) controller.sendImage(image.path);
                        },
                     ),
                     IconButton(
                       icon: Obx(() => Icon(
                         controller.showEmojiPicker.value ? Icons.keyboard : Icons.sentiment_satisfied_alt,
                         color: Colors.grey,
                       )),
                       onPressed: () => controller.toggleEmojiPicker(),
                     ),
                   ],
                 ),
               ),
             ),
             const SizedBox(width: 12),
             GestureDetector(
               onTap: () => controller.sendMessage(),
               child: Container(
                 padding: const EdgeInsets.all(12),
                 decoration: const BoxDecoration(
                   color: Colors.transparent, // Or a send button color if visible in screenshot? Looks like just an icon
                 ),
                 child: const Icon(Icons.send, color: AppColors.secondaryPrimary), // Or white/grey
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiPicker() {
    final emojis = ["❤️", "😂", "😮", "😢", "😡", "👍", "🙏", "🔥", "👏", "🎉", "💯", "✨"];
    return Container(
      height: 200,
      color: Colors.grey[900],
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: emojis.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => controller.onEmojiSelected(emojis[index]),
            child: Center(
              child: Text(emojis[index], style: const TextStyle(fontSize: 24)),
            ),
          );
        },
      ),
    );
  }

  void _showReactionMenu(BuildContext context, ChatMessage message) {
    final emojis = ["❤️", "😂", "😮", "😢", "😡", "👍"];
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 15,
              children: emojis.map((e) => InkWell(
                onTap: () {
                  controller.sendReaction(message.id!, e);
                  Get.back();
                },
                child: Text(e, style: const TextStyle(fontSize: 30)),
              )).toList(),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.reply, color: Colors.white),
              title: const Text("Reply", style: TextStyle(color: Colors.white)),
              onTap: () {
                controller.setReplyingTo(message);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.white),
              title: const Text("Copy Text", style: TextStyle(color: Colors.white)),
              onTap: () {
                // Add copy logic if needed
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
