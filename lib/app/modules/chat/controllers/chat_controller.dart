import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/chat_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late WebSocketChannel _channel;
  
  String receiverId = "";
  String receiverName = "";
  String? receiverImage;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      receiverId = args['id'];
      receiverName = args['name'] ?? "User";
      receiverImage = args['image'];
    }
    
    _initChat();
  }

  Future<void> _initChat() async {
    isLoading.value = true;
    try {
      final profile = await AuthService.to.getMyProfile();
      if (profile != null) {
        final currentUserId = profile.id;
        _connectWebSocket(currentUserId!);
      }
      await fetchHistory();
    } finally {
      isLoading.value = false;
    }
  }

  void _connectWebSocket(String currentUserId) {
    final token = AuthService.to.token;
    if (token == null) return;

    final wsUrl = "wss://erronliveapp.mtscorporate.com/api/v1/chat/ws?token=$token";
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel.stream.listen((data) {
      final payload = jsonDecode(data);
      final msg = ChatMessage.fromJson(payload);
      
      if ((msg.senderId == receiverId && msg.receiverId == currentUserId) ||
          (msg.senderId == currentUserId && msg.receiverId == receiverId)) {
        messages.add(msg);
        _scrollToBottom();
      }
    }, onError: (err) {
      print("WebSocket Error: $err");
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
      "receiver_id": receiverId,
      "message": text,
    };

    _channel.sink.add(jsonEncode(payload));
    messageController.clear();
  }

  Future<void> sendImage(String path) async {
    final imageUrl = await _chatService.uploadImage(path);
    if (imageUrl != null) {
      final payload = {
        "receiver_id": receiverId,
        "image_url": imageUrl,
      };
      _channel.sink.add(jsonEncode(payload));
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
    _channel.sink.close();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
