import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/services/auth_service.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B15),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B15),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
               color: const Color(0xFF161621),
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
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF2ECC71), shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text("Online", style: TextStyle(fontSize: 12, color: Colors.grey)),
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
               decoration: const BoxDecoration(color: Color(0xFF161621), shape: BoxShape.circle),
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
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isMe = msg.senderId != controller.receiverId;

                  // Find replied message if exists
                  ChatMessage? repliedMsg;
                  if (msg.repliedToId != null) {
                    try {
                      repliedMsg = controller.messages.firstWhere((m) => m.id == msg.repliedToId);
                    } catch (_) {}
                  }

                  return GestureDetector(
                    onLongPress: () => _showReactionMenu(context, msg),
                    child: Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFF4C4DDC) : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: Radius.circular(isMe ? 20 : 0),
                                bottomRight: Radius.circular(isMe ? 0 : 20),
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
                                      border: Border(left: BorderSide(color: isMe ? Colors.white : const Color(0xFF4C4DDC), width: 3)),
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
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Wrap(
                                spacing: 2,
                                children: msg.reactions.map((r) => Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white24, width: 0.5),
                                  ),
                                  child: Text(r.emoji, style: const TextStyle(fontSize: 12)),
                                )).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
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
          const Icon(Icons.reply, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.senderId == controller.receiverId ? controller.receiverName : "You",
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12),
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
        color: Color(0xFF0B0B15),
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
                 child: const Icon(Icons.send, color: Colors.blueAccent), // Or white/grey
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
