import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();
  
  final _box = GetStorage();
  final _tokenKey = 'access_token';
  
  // Base URL
  static const String baseUrl = 'https://erronliveapp.mtscorporate.com/api/v1';
  static const String baseOrigin = 'https://erronliveapp.mtscorporate.com';

  static String getFullUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;
    return "$baseOrigin${path.startsWith('/') ? '' : '/'}$path";
  }

  bool get isLoggedIn => _box.hasData(_tokenKey);
  String? get token => _box.read(_tokenKey);

  Future<AuthService> init() async {
    await GetStorage.init();
    return this;
  }

  Future<bool> login(String email, String password) async {
    try {
      final uri=Uri.parse('$baseUrl/auth/login');
      final response = await http.post(
        uri,
        body: {
          'username': email,
          'password': password,
        },
      );



      print("response: $uri  ${response.statusCode},${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        await _box.write(_tokenKey, token);
        return true;
      } else {
        Get.snackbar("Login Failed", "Invalid credentials");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
      return false;
    }
  }

  Future<bool> signup(String firstName, String lastName, String email, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/signup');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        Get.snackbar("Signup Failed", response.body);
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
      return false;
    }
  }

  Future<void> logout() async {
    await _box.remove(_tokenKey);
    Get.offAllNamed('/login');
  }

  Future<UserModel?> getMyProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/users/my_profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        print("Profile Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Profile Exception: $e");
      return null;
    }
  }
}
