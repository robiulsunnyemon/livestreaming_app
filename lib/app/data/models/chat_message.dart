class ChatMessage {
  final String? id;
  final String senderId;
  final String receiverId;
  final String? message;
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;

  ChatMessage({
    this.id,
    required this.senderId,
    required this.receiverId,
    this.message,
    this.imageUrl,
    this.isRead = false,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? json['id'],
      senderId: json['sender_id'] ?? (json['sender'] is Map ? json['sender']['_id'] : json['sender']),
      receiverId: json['receiver_id'] ?? (json['receiver'] is Map ? json['receiver']['_id'] : json['receiver']),
      message: json['message'],
      imageUrl: json['image_url'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']).toLocal() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiver_id': receiverId,
      'message': message,
      'image_url': imageUrl,
    };
  }
}
