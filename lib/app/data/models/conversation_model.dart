import 'user_model.dart';

class Conversation {
  final UserModel otherUser;
  final String? lastMessage;
  final String? lastImageUrl;
  final DateTime createdAt;
  final int unreadCount;

  Conversation({
    required this.otherUser,
    this.lastMessage,
    this.lastImageUrl,
    required this.createdAt,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      otherUser: UserModel.fromJson(json['other_user']),
      lastMessage: json['last_message'],
      lastImageUrl: json['last_image_url'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}
