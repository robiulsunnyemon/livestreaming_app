class LiveStreamModel {
  final String? id; // Assuming Mongo ID
  final String? channelName;
  final String? title;
  final String? thumbnail;
  final String? category;
  final String? livekitToken;
  final bool isPremium;
  final num entryFee;
  final String status;
  final int totalViews;
  final String? hostId; // host is likely a link, but usually expanded. If just ID, handle appropriately
  
  LiveStreamModel({
    this.id,
    this.title,
    this.category,
    this.thumbnail,
    this.livekitToken,
    this.channelName,
    this.isPremium = false,
    this.entryFee = 0,
    this.status = "live",
    this.totalViews = 0,
    this.hostId,
  });

  factory LiveStreamModel.fromJson(Map<String, dynamic> json) {
    return LiveStreamModel(
      id: json['_id'], // Beanie/Mongo uses _id
      channelName: json['channel_name'],
      livekitToken: json['livekit_token'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      category: json['category'],
      isPremium: json['is_premium'] ?? false,
      entryFee: json['entry_fee'] ?? 0,
      status: json['status'] ?? "live",
      totalViews: json['total_views'] ?? 0,
      hostId: json['host'] is Map ? json['host']['_id'] : json['host'], // Handle expansion if possible
    );
  }
}
