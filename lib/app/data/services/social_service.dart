import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SocialService {
  final String _baseUrl = AuthService.baseUrl;

  Future<bool> followUser(String targetId) async {
    final url = Uri.parse("$_baseUrl/social/follow/$targetId");
    final token = AuthService.to.token;
    if (token == null) throw Exception("Authentication Required");

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token', 'accept': 'application/json'},
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {

      return false;
    }
  }

  Future<bool> unfollowUser(String targetId) async {
    final url = Uri.parse("$_baseUrl/social/unfollow/$targetId");
    final token = AuthService.to.token;
    if (token == null) throw Exception("Authentication Required");

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token', 'accept': 'application/json'},
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {

      return false;
    }
  }

  Future<bool> isFollowing(String targetId) async {
    final url = Uri.parse("$_baseUrl/social/is-following/$targetId");
    final token = AuthService.to.token;
    if (token == null) return false;

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token', 'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_following'] ?? false;
      }
      return false;
    } catch (e) {

      return false;
    }
  }

  Future<Map<String, dynamic>?> getPublicProfile(String targetId) async {
    final url = Uri.parse("$_baseUrl/users/profile/public/$targetId");
    final token = AuthService.to.token;

    try {
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {

      return null;
    }
  }
}
