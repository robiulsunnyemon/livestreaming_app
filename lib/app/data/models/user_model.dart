import 'live_stream_model.dart';

class UserModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String email;
  final double coins;
  final String? phoneNumber;
  final bool isVerified;
  final String? country;
  final String? gender;
  final String? dob;
  final String? bio;
  final bool isOnline;
  final double shady;
  final int followingCount;
  final int followersCount;
  final int totalLikes;
  final String? profileImage;
  final String? coverImage;
  final String authProvider;
  final String role;
  final String accountStatus;
  final KycModel? kyc;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<LiveStreamModel> pastStreams;

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.coins = 50,
    this.phoneNumber,
    this.isVerified = false,
    this.country,
    this.gender,
    this.dob,
    this.bio,
    required this.shady,
    this.isOnline = false,
    this.followingCount = 0,
    this.followersCount = 0,
    this.totalLikes = 0,
    this.profileImage,
    this.coverImage,
    this.authProvider = "email",
    this.role = "user",
    this.accountStatus = "active",
    this.kyc,
    this.createdAt,
    this.updatedAt,
    this.pastStreams = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic obj) {
      if (obj == null) return "";
      if (obj is String) return obj;
      if (obj is Map) {
        return (obj['id'] ?? obj['_id'] ?? obj['\$oid'] ?? "").toString();
      }
      return obj.toString();
    }

    return UserModel(
      id: extractId(json['id'] ?? json['_id']),
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'] ?? "",
      coins: (json['coins'] ?? 0).toDouble(),
      phoneNumber: json['phone_number'],
      isVerified: json['is_verified'] ?? false,
      country: json['country'],
      gender: json['gender'],
      dob: json['date_of_birth'],
      bio: json['bio'],
      shady: (json['shady'] ?? 0.0).toDouble(),
      isOnline: json['is_online'] ?? false,
      followingCount: json['following_count'] ?? 0,
      followersCount: json['followers_count'] ?? 0,
      totalLikes: json['total_likes'] ?? 0,
      profileImage: _getFullUrl(json['profile_image']),
      coverImage: _getFullUrl(json['cover_image']),
      authProvider: json['auth_provider'] ?? "email",
      role: json['role'] ?? "user",
      accountStatus: json['account_status'] ?? "active",
      kyc: json['kyc'] != null ? KycModel.fromJson(json['kyc']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      pastStreams: (json['past_streams'] as List?)
          ?.map((e) => LiveStreamModel.fromJson(e))
          .toList() ?? [],
    );
  }

  String get fullName => "${firstName ?? ''} ${lastName ?? ''}".trim();

  static String? _getFullUrl(String? path) {
    if (path == null || path.isEmpty) return path;
    if (path.startsWith('http')) return path;
    const base = 'https://api.instalive.cloud';
    return "$base${path.startsWith('/') ? '' : '/'}$path";
  }
}

class KycModel {
  final String idFront;
  final String idBack;
  final String status;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KycModel({
    required this.idFront,
    required this.idBack,
    required this.status,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  factory KycModel.fromJson(Map<String, dynamic> json) {
    return KycModel(
      idFront: UserModel._getFullUrl(json['id_front']) ?? "",
      idBack: UserModel._getFullUrl(json['id_back']) ?? "",
      status: json['status'] ?? "none",
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}
