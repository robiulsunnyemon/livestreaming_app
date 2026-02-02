import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/services/chat_socket_service.dart';
import '../../../routes/app_pages.dart';
import 'package:flutter/material.dart';


class ActiveUsersController extends GetxController {
  final ChatService _chatService = ChatService();
  final ChatSocketService _socketService = Get.find<ChatSocketService>();
  
  final activeUsers = <UserModel>[].obs;
  final conversations = <Conversation>[].obs;
  final searchResults = <UserModel>[].obs;
  final isLoading = false.obs;
  final isSearching = false.obs;
  final currentUser = Rxn<UserModel>();
  
  final searchTextController = TextEditingController();
  Timer? _searchDebounce;

  StreamSubscription? _messageSubscription;

  @override
  void onInit() {
    super.onInit();
    _socketService.connect();
    fetchAllData();
    fetchCurrentUser();
    _listenForUpdates();
  }

  void search(String query) {
    if (query.trim().isEmpty) {
      isSearching.value = false;
      searchResults.clear();
      return;
    }

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      isSearching.value = true;
      try {
        final results = await _chatService.searchUsers(query);
        searchResults.assignAll(results);
      } finally {
        isSearching.value = false;
      }
    });
  }

  void clearSearch() {
    searchTextController.clear();
    searchResults.clear();
    isSearching.value = false;
    _searchDebounce?.cancel();
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
    searchTextController.dispose();
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

  Future<void> fetchCurrentUser() async {
     try {
       final user = await AuthService.to.getMyProfile();
       currentUser.value = user;
     } catch (e) {
       print("Error fetching current user: $e");
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
