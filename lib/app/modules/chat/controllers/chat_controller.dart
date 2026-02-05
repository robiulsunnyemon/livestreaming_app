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

  final isTyping = false.obs;
  final isOnline = false.obs;
  Timer? _typingDebounce;
  Timer? _stopTypingDebounce;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _userStatusSubscription;
  
  // Buffers for race conditions
  final Map<String, String> _pendingOutgoingReactions = {}; // tempId -> emoji
  final Map<String, List<Map<String, dynamic>>> _bufferedIncomingReactions = {}; // realId -> list of reaction payloads

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
      _listenToTyping();
      _listenToUserStatus();
      await fetchHistory();
      _checkInitialOnlineStatus();
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
      print("ChatController Received: $payload"); // DEBUG LOG

      // Handle reactions separately
      if (payload['type'] == 'reaction') {
        _handleIncomingReaction(payload);
        return;
      }

      final msg = ChatMessage.fromJson(payload);
      final echoTempId = payload['temp_id']?.toString(); 
      
      print("Parsed Message: ${msg.id}, TempId: $echoTempId");
      
      // Validate that message belongs to this conversation
      if ((msg.senderId == receiverId && msg.receiverId == currentUserId) ||
          (msg.senderId == currentUserId && msg.receiverId == receiverId)) {
        
        // Find match
        int tempIndex = -1;
        if (echoTempId != null) {
           tempIndex = messages.indexWhere((m) => m.id == echoTempId);
        }
        
        // Fallback or double check
        if (tempIndex == -1) {
           tempIndex = messages.indexWhere((m) => 
               m.id?.startsWith('temp_') == true && 
               m.message == msg.message && 
               m.senderId == msg.senderId
           );
        }
        
        if (tempIndex != -1) {
          // Replace temp message with real one
          print("Replacing Temp Message at index $tempIndex");
          final tempId = messages[tempIndex].id;
          
          // Preserve local reactions if they exist (to avoid blink)
          final localReactions = messages[tempIndex].reactions;
          if (localReactions.isNotEmpty && msg.reactions.isEmpty) {
             // We could merge, but for now let's just trust real reactions will arrive momentarily
             // Or better: Re-apply them? No, let the queue handle it.
          }

          messages[tempIndex] = msg;
          
          // PROCESS OUTGOING QUEUE
          if (tempId != null && _pendingOutgoingReactions.containsKey(tempId)) {
             final emoji = _pendingOutgoingReactions.remove(tempId)!;
             print("Processing queued outgoing reaction for $tempId -> ${msg.id}");
             sendReaction(msg.id!, emoji);
          }
        } else {
          // New message (or duplicate)
          if (!messages.any((m) => m.id == msg.id)) {
            print("Adding new message");
            messages.add(msg);
            _scrollToBottom();
          }
          
          // SAFETY NET: Process queue even if temp message was missing in UI
          if (echoTempId != null && _pendingOutgoingReactions.containsKey(echoTempId)) {
               print("Safety Net: Processing queued reaction for missing temp msg $echoTempId");
               final emoji = _pendingOutgoingReactions.remove(echoTempId)!;
               sendReaction(msg.id!, emoji);
          }
        }
        
        // Mark incoming messages as read
        if (msg.senderId == receiverId) {
          _chatService.markAsRead(receiverId);
        }
        
        // Process Buffered Incoming Reactions
        final realId = msg.id!;
        if (_bufferedIncomingReactions.containsKey(realId)) {
           print("Processing buffered incoming reactions for $realId");
           final queuedReactions = _bufferedIncomingReactions.remove(realId)!;
           for (final reactionPayload in queuedReactions) {
              _handleIncomingReaction(reactionPayload);
           }
        }
      }
    });
  }

  void _handleIncomingReaction(Map<String, dynamic> payload) {
    final messageId = payload['message_id'];
    final userId = payload['user_id'];
    final emoji = payload['emoji'];
    
    final msgIndex = messages.indexWhere((m) => m.id == messageId);
    if (msgIndex != -1) {
      final currentMsg = messages[msgIndex];
      final newReactions = List<Reaction>.from(currentMsg.reactions);
      
      // Remove existing reaction from this user
      newReactions.removeWhere((r) => r.userId == userId);
      // Add new reaction
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
      messages.refresh();
    } else {
      // Buffer if message not found (likely pending echo)
      print("Buffering incoming reaction for unknown message ID: $messageId"); // DEBUG LOG
      if (!_bufferedIncomingReactions.containsKey(messageId)) {
        _bufferedIncomingReactions[messageId] = [];
      }
      _bufferedIncomingReactions[messageId]!.add(payload);
    }
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
    _stopTypingDebounce?.cancel(); // Cancel any pending stop typing event
    _socketService.sendStopTyping(receiverId); // Immediately stop typing on send
    
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final profile = await AuthService.to.getMyProfile();
    if (profile == null) return;

    // Create temporary message for immediate UI feedback
    final tempMsg = ChatMessage(
      id: "temp_${DateTime.now().millisecondsSinceEpoch}",
      senderId: profile.id ?? "",
      receiverId: receiverId,
      message: text,
      repliedToId: replyingToMessage.value?.id,
      createdAt: DateTime.now(),
      isRead: false,
    );

    // Add to UI immediately
    messages.add(tempMsg);
    _scrollToBottom();

    // Send via WebSocket
    final payload = {
      "type": "message",
      "receiver_id": receiverId,
      "message": text,
      "replied_to_id": replyingToMessage.value?.id,
      "temp_id": tempMsg.id, // Send the temporary ID to backend
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

  void sendReaction(String messageId, String emoji) async {
    final profile = await AuthService.to.getMyProfile();
    if (profile == null) return;
    final currentUserId = profile.id ?? "";

    // Update local UI immediately (optimistic update)
    final msgIndex = messages.indexWhere((m) => m.id == messageId);
    if (msgIndex != -1) {
      final currentMsg = messages[msgIndex];
      final newReactions = List<Reaction>.from(currentMsg.reactions);
      
      // Remove existing reaction from this user
      newReactions.removeWhere((r) => r.userId == currentUserId);
      // Add new reaction
      newReactions.add(Reaction(userId: currentUserId, emoji: emoji));
      
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
      messages.refresh();
    }

    // Send to backend
    if (messageId.startsWith('temp_')) {
      print("Queueing outgoing reaction for Temp ID: $messageId. Queue size: ${_pendingOutgoingReactions.length + 1}"); 
      _pendingOutgoingReactions[messageId] = emoji;
    } else {
      print("Sending reaction immediately for Real ID: $messageId");
      final payload = {
        "type": "reaction",
        "message_id": messageId,
        "emoji": emoji,
        "receiver_id": receiverId,
      };
      _socketService.sendMessage(payload);
    }
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

  void _listenToTyping() {
    _typingSubscription = _socketService.typingEvents.listen((payload) {
      if (payload['sender_id'] == receiverId) {
        if (payload['type'] == 'typing') {
          isTyping.value = true;
          // Auto-hide typing after 5 seconds if no stop received or missed
          Future.delayed(const Duration(seconds: 5), () {
            if (isTyping.value) isTyping.value = false;
          });
        } else if (payload['type'] == 'stop_typing') {
          isTyping.value = false;
        }
      }
    });
  }

  void onTextChanged(String text) {
    if (text.isEmpty) {
      _stopTypingDebounce?.cancel();
      _socketService.sendStopTyping(receiverId);
      return;
    }

    if (_typingDebounce?.isActive ?? false) _typingDebounce!.cancel();
    _typingDebounce = Timer(const Duration(milliseconds: 500), () {
      _socketService.sendTyping(receiverId);
      
      // Schedule stop typing if no more input for 2 seconds
      _stopTypingDebounce?.cancel();
      _stopTypingDebounce = Timer(const Duration(seconds: 2), () {
        _socketService.sendStopTyping(receiverId);
      });
    });
  }

  void _listenToUserStatus() {
    _userStatusSubscription = _socketService.userStatusEvents.listen((payload) {
        final userId = payload['user_id'];
        if (userId == receiverId) {
            isOnline.value = payload['type'] == 'user_connected';
        }
    });
  }

  void _checkInitialOnlineStatus() async {
      try {
          final activeUsers = await _chatService.getActiveUsers();
          isOnline.value = activeUsers.any((u) => u.id == receiverId);
      } catch (e) {
          print("Error checking online status: $e");
      }
  }

  @override
  void onClose() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _userStatusSubscription?.cancel();
    _typingDebounce?.cancel();
    _stopTypingDebounce?.cancel();
    messageController.dispose();
    scrollController.dispose();
    messageFocusNode.dispose();
    super.onClose();
  }
}
