import 'user_model.dart';

class LiveStreamModel {
  final String? id;
  final String? channelName;
  final String? title;
  final String? thumbnail;
  final String? category;
  final String? livekitToken;
  final bool isPremium;
  final int entryFee;
  final DateTime? startTime;
  final DateTime? endTime;
  final int totalLikes;
  final int earnCoins;
  final int totalViews;
  final int totalComments;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserModel? host;

  LiveStreamModel({
    this.id,
    this.channelName,
    this.title,
    this.thumbnail,
    this.category,
    this.livekitToken,
    this.isPremium = false,
    this.entryFee = 0,
    this.startTime,
    this.endTime,
    this.totalLikes = 0,
    this.earnCoins = 0,
    this.totalViews = 0,
    this.totalComments = 0,
    this.status = "live",
    this.createdAt,
    this.updatedAt,
    this.host,
  });

  factory LiveStreamModel.fromJson(Map<String, dynamic> json) {
    return LiveStreamModel(
      id: (json['id'] ?? json['_id']).toString(),
      channelName: json['channel_name'],
      title: json['title'],
      thumbnail: _getFullUrl(json['thumbnail']),
      category: json['category'],
      livekitToken: json['livekit_token'],
      isPremium: json['is_premium'] ?? false,
      entryFee: (json['entry_fee'] ?? 0).toInt(),
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      totalLikes: json['total_likes'] ?? 0,
      earnCoins: json['earn_coins'] ?? 0,
      totalViews: json['total_views'] ?? 0,
      totalComments: json['total_comments'] ?? 0,
      status: json['status'] ?? "live",
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      host: json['host'] != null ? UserModel.fromJson(json['host']) : null,
    );
  }

  // Compatibility getters
  String get hostFirstName => host?.firstName ?? "";
  String get hostLastName => host?.lastName ?? "";
  String get hostFullName => host?.fullName ?? "";

  static String? _getFullUrl(String? path) {
    if (path == null || path.isEmpty) return path;
    if (path.startsWith('http')) return path;
    const base = 'https://api.instalive.cloud';
    return "$base${path.startsWith('/') ? '' : '/'}$path";
  }
}
