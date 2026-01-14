import 'dart:convert';
import 'package:http/http.dart' as http;

class StreamingService {
  final String _baseUrl = "https://erronliveapp.mtscorporate.com/api/v1/streaming";

  Future<String> getToken({required String roomName, required String participantName, required bool isHost}) async {
    final url = Uri.parse("$_baseUrl/get-token");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "room_name": roomName,
          "participant_name": participantName,
          "is_host": isHost,
        }),
      );

      print("response: ${response.statusCode},${response.body}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['livekit_token'];
      } else {
        throw Exception("Failed to get token: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error getting token: $e");
    }
  }
}
