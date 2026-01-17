import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/user_model.dart';
import '../models/conversation_model.dart';
import 'auth_service.dart';

class ChatService {
  final String _baseUrl = AuthService.baseUrl;

  Future<List<UserModel>> getActiveUsers() async {
    final token = AuthService.to.token;
    if (token == null) return [];

    try {
      final url = Uri.parse("$_baseUrl/chat/active-users");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => UserModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching active users: $e");
      return [];
    }
  }

  Future<List<ChatMessage>> getChatHistory(String receiverId, {int skip = 0, int limit = 50}) async {
    final token = AuthService.to.token;
    if (token == null) return [];

    try {
      final url = Uri.parse("$_baseUrl/chat/history/$receiverId?skip=$skip&limit=$limit");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ChatMessage.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching chat history: $e");
      return [];
    }
  }

  Future<String?> uploadImage(String filePath) async {
    final token = AuthService.to.token;
    if (token == null) return null;

    try {
      final url = Uri.parse("$_baseUrl/chat/upload-image");
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['image_url'];
      }
      return null;
    } catch (e) {
      print("Error uploading chat image: $e");
      return null;
    }
  }

  Future<List<Conversation>> getConversations() async {
    final token = AuthService.to.token;
    if (token == null) return [];

    try {
      final url = Uri.parse("$_baseUrl/chat/conversations");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Conversation.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching conversations: $e");
      return [];
    }
  }

  Future<void> markAsRead(String senderId) async {
    final token = AuthService.to.token;
    if (token == null) return;

    try {
      final url = Uri.parse("$_baseUrl/chat/mark-read/$senderId");
      await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json'
        },
      );
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }
}
