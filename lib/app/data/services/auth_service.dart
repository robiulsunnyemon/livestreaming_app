import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/user_model.dart';
import '../models/payout_model.dart';

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
        Uri.parse('$baseUrl/users/my_profile'),
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

  Future<Map<String, dynamic>?> submitKYC(String frontPath, String backPath) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/users/kyc/submit'));
      request.headers['Authorization'] = 'Bearer $token';
      
      request.files.add(await http.MultipartFile.fromPath('id_front', frontPath));
      request.files.add(await http.MultipartFile.fromPath('id_back', backPath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        Get.snackbar("KYC Submission Failed", response.body);
        return null;
      }
    } catch (e) {
      Get.snackbar("Error", "Submission Error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getKYCStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/kyc/view'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/otp-verify');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        // If the response returns user data where is_verified is true, we might want to update local storage if logged in.
        // But predominantly this is for activation.
        return true;
      } else {
        Get.snackbar("Verification Failed", response.body);
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
      return false;
    }
  }

  Future<bool> resendOtp(String email) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/resend-otp');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        Get.snackbar("Failed to Resend OTP", response.body);
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/reset-password');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'new_password': newPassword,
        }),
      );

      print(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        Get.snackbar("Reset Password Failed", response.body);
        return false;
      }
    }
    catch (e){
      print(e);
      Get.snackbar("Error", "Something went wrong: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getWalletStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/finance/wallet/stats'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> uploadProfileImage(String filePath) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/users/my_profile/upload-profile-image'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'image', 
        filePath,
        contentType: _getMediaType(filePath),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        print(response.body);
        Get.snackbar("Error", "Failed to upload profile image: ${response.body}");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Upload failed: $e");
      return false;
    }
  }

  Future<bool> uploadCoverImage(String filePath) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/users/my_profile/upload/cover-image'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'image', 
        filePath,
        contentType: _getMediaType(filePath),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        Get.snackbar("Error", "Failed to upload cover image: ${response.body}");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Upload failed: $e");
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/my_profile/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        Get.snackbar("Error", "Failed to update profile: ${response.body}");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Update failed: $e");
      return false;
    }
  }

  Future<List<PayoutRequestModel>> getPayoutHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/finance/payout/history'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => PayoutRequestModel.fromJson(e)).toList();
      } else {
        print("Payout History Error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Payout History Exception: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> createStripePaymentIntent(double amount, int tokens) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/finance/stripe/create-payment-intent'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'tokens': tokens,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        Get.snackbar("Error", "Failed to create payment: ${response.body}");
        return null;
      }
    } catch (e) {
      Get.snackbar("Error", "Payment Intent Error: $e");
      return null;
    }
  }

  MediaType _getMediaType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    if (ext == 'png') return MediaType('image', 'png');
    if (ext == 'webp') return MediaType('image', 'webp');
    return MediaType('image', 'jpeg');
  }
}
