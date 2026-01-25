import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/services/chat_socket_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final ChatSocketService _socketService = Get.find<ChatSocketService>();
  
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  final replyingToMessage = Rxn<ChatMessage>();
  final showEmojiPicker = false.obs;
  final FocusNode messageFocusNode = FocusNode();

  StreamSubscription? _messageSubscription;
  
  String receiverId = "";
  String receiverName = "";
  String? receiverImage;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      receiverId = args['id']?.toString() ?? "";
      receiverName = args['name']?.toString() ?? "User";
      receiverImage = args['image']?.toString();
    }
    
    _initChat();
  }

  Future<void> _initChat() async {
    isLoading.value = true;
    try {
      _socketService.connect();
      _listenToMessages();
      await fetchHistory();
      await _chatService.markAsRead(receiverId); // Mark as read on open
    } finally {
      isLoading.value = false;
    }
  }

  void _listenToMessages() async {
    final profile = await AuthService.to.getMyProfile();
    if (profile == null) return;
    final currentUserId = profile.id;

    _messageSubscription = _socketService.messages.listen((payload) {
      if (payload['type'] == 'reaction') {
        final messageId = payload['message_id'];
        final userId = payload['user_id'];
        final emoji = payload['emoji'];
        
        final msgIndex = messages.indexWhere((m) => m.id == messageId);
        if (msgIndex != -1) {
          final currentMsg = messages[msgIndex];
          final newReactions = List<Reaction>.from(currentMsg.reactions);
          newReactions.removeWhere((r) => r.userId == userId);
          newReactions.add(Reaction(userId: userId, emoji: emoji));
          
          messages[msgIndex] = ChatMessage(
            id: currentMsg.id,
            senderId: currentMsg.senderId,
            receiverId: currentMsg.receiverId,
            message: currentMsg.message,
            imageUrl: currentMsg.imageUrl,
            isRead: currentMsg.isRead,
            repliedToId: currentMsg.repliedToId,
            reactions: newReactions,
            createdAt: currentMsg.createdAt,
          );
        }
        return;
      }

      final msg = ChatMessage.fromJson(payload);
      
      if ((msg.senderId == receiverId && msg.receiverId == currentUserId) ||
          (msg.senderId == currentUserId && msg.receiverId == receiverId)) {
        messages.add(msg);
        _scrollToBottom();
        
        // If we are currently in this chat, mark incoming messages as read
        if (msg.senderId == receiverId) {
          _chatService.markAsRead(receiverId);
        }
      }
    });
  }

  Future<void> fetchHistory() async {
    try {
      final history = await _chatService.getChatHistory(receiverId);
      messages.assignAll(history);
      _scrollToBottom();
    } catch (e) {
      print("Error fetching history: $e");
    }
  }

  void sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final payload = {
      "type": "message",
      "receiver_id": receiverId,
      "message": text,
      "replied_to_id": replyingToMessage.value?.id,
    };

    _socketService.sendMessage(payload);
    messageController.clear();
    replyingToMessage.value = null;
    showEmojiPicker.value = false;
  }

  void setReplyingTo(ChatMessage message) {
    replyingToMessage.value = message;
    messageFocusNode.requestFocus();
  }

  void cancelReply() {
    replyingToMessage.value = null;
  }

  void toggleEmojiPicker() {
    showEmojiPicker.value = !showEmojiPicker.value;
    if (showEmojiPicker.value) {
      messageFocusNode.unfocus();
    } else {
      messageFocusNode.requestFocus();
    }
  }

  void onEmojiSelected(String emoji) {
    messageController.text += emoji;
  }

  void sendReaction(String messageId, String emoji) {
    final payload = {
      "type": "reaction",
      "message_id": messageId,
      "emoji": emoji,
      "receiver_id": receiverId,
    };
    _socketService.sendMessage(payload);
  }

  void startCall(String type) {
    Get.toNamed('/call', arguments: {
      'caller_id': receiverId,
      'caller_name': receiverName,
      'caller_image': receiverImage,
      'call_type': type,
      'is_incoming': false,
    });
  }

  Future<void> sendImage(String path) async {
    final imageUrl = await _chatService.uploadImage(path);
    if (imageUrl != null) {
      final payload = {
        "receiver_id": receiverId,
        "image_url": imageUrl,
      };
      _socketService.sendMessage(payload);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    _messageSubscription?.cancel();
    messageController.dispose();
    scrollController.dispose();
    messageFocusNode.dispose();
    super.onClose();
  }
}
