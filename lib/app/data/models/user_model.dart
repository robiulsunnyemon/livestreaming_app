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
  final int followingCount;
  final int followersCount;
  final int totalLikes;
  final String? profileImage;
  final String authProvider;

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
    this.isOnline = false,
    this.followingCount = 0,
    this.followersCount = 0,
    this.totalLikes = 0,
    this.profileImage,
    this.authProvider = "email",
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
      isOnline: json['is_online'] ?? false,
      followingCount: json['following_count'] ?? 0,
      followersCount: json['followers_count'] ?? 0,
      totalLikes: json['total_likes'] ?? 0,
      profileImage: json['profile_image'],
      authProvider: json['auth_provider'] ?? "email",
    );
  }

  String get fullName => "${firstName ?? ''} ${lastName ?? ''}".trim();
}
