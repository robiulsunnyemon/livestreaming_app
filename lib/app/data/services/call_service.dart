import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CallService {
  final String _baseUrl = AuthService.baseUrl;

  Future<Map<String, dynamic>> initiateCall(String receiverId, String callType) async {
    final url = Uri.parse("$_baseUrl/chat/call/initiate?receiver_id=$receiverId&call_type=$callType");
    final token = AuthService.to.token;

    if (token == null) throw Exception("Authentication Required");

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to initiate call: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> respondToCall(String roomName, String callerId, String action) async {
    final url = Uri.parse("$_baseUrl/chat/call/respond?room_name=$roomName&caller_id=$callerId&action=$action");
    final token = AuthService.to.token;

    if (token == null) throw Exception("Authentication Required");

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to respond to call: ${response.body}");
    }
  }

  Future<void> endCall(String otherUserId, String roomName) async {
    final url = Uri.parse("$_baseUrl/chat/call/end?other_user_id=$otherUserId&room_name=$roomName");
    final token = AuthService.to.token;

    if (token == null) return;

    await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'application/json'
      },
    );
  }
}
