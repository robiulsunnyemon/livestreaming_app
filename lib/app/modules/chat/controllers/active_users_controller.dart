import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/services/chat_socket_service.dart';
import '../../../routes/app_pages.dart';

class ActiveUsersController extends GetxController {
  final ChatService _chatService = ChatService();
  final ChatSocketService _socketService = Get.find<ChatSocketService>();
  
  final activeUsers = <UserModel>[].obs;
  final conversations = <Conversation>[].obs;
  final isLoading = false.obs;

  StreamSubscription? _messageSubscription;

  @override
  void onInit() {
    super.onInit();
    _socketService.connect();
    fetchAllData();
    _listenForUpdates();
  }

  void _listenForUpdates() {
    _messageSubscription = _socketService.messages.listen((_) {
      // Whenever ANY message is received, refresh the conversation list
      fetchConversations();
    });
  }

  @override
  void onClose() {
    _messageSubscription?.cancel();
    super.onClose();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchActiveUsers(),
        fetchConversations(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchActiveUsers() async {
    try {
      final users = await _chatService.getActiveUsers();
      activeUsers.assignAll(users);
    } catch (e) {
      print("Error fetching active users: $e");
    }
  }

  Future<void> fetchConversations() async {
    try {
      final history = await _chatService.getConversations();
      conversations.assignAll(history);
    } catch (e) {
      print("Error fetching conversations: $e");
    }
  }

  void startChat(UserModel user) {
    Get.toNamed(Routes.CHAT, arguments: {
      'id': user.id,
      'name': user.fullName,
      'image': user.profileImage,
    })?.then((_) => fetchConversations());
  }

  void startChatWithConversation(Conversation conversation) {
    startChat(conversation.otherUser);
  }
}
