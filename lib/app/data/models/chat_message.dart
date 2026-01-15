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
    String extractId(dynamic obj) {
      if (obj == null) return "";
      if (obj is String) return obj;
      if (obj is Map) {
        return (obj['id'] ?? obj['_id'] ?? obj['\$oid'] ?? "").toString();
      }
      return obj.toString();
    }

    return ChatMessage(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      senderId: json['sender_id']?.toString() ?? extractId(json['sender']),
      receiverId: json['receiver_id']?.toString() ?? extractId(json['receiver']),
      message: json['message']?.toString(),
      imageUrl: json['image_url']?.toString(),
      isRead: json['is_read'] == true,
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
