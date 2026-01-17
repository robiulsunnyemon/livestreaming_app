import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/auth_service.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: controller.receiverImage != null 
                  ? NetworkImage(AuthService.getFullUrl(controller.receiverImage)) 
                  : null,
              child: controller.receiverImage == null 
                  ? const Icon(Icons.person) 
                  : null,
            ),
            const SizedBox(width: 10),
            Text(controller.receiverName),
          ],
        ),
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

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blueAccent : Colors.grey[800],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: Radius.circular(isMe ? 12 : 0),
                          bottomRight: Radius.circular(isMe ? 0 : 12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (msg.imageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                AuthService.getFullUrl(msg.imageUrl),
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (msg.message != null)
                            Text(
                              msg.message!,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            "${msg.createdAt.hour}:${msg.createdAt.minute}",
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black26,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: Colors.blueAccent),
            onPressed: () async {
              final picker = ImagePicker();
              final image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                controller.sendImage(image.path);
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: controller.messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[900],
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 5),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: () => controller.sendMessage(),
          ),
        ],
      ),
    );
  }
}
