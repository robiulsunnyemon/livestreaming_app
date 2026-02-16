import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/live_stream_model.dart';
import 'auth_service.dart';

class StreamingService {
  final String _baseUrl = AuthService.baseUrl;

  Future<Map<String, dynamic>> startStream({
    bool isPremium = false, 
    int entryFee = 0, 
    String title = "", 
    String category = ""
  }) async {
    final url = Uri.parse("$_baseUrl/streaming/start");
    final token = AuthService.to.token;

    if (token == null) {
      throw Exception("Authentication Required");
    }

    try {
      final queryUrl = url.replace(queryParameters: {
        "is_premium": isPremium.toString(),
        "entry_fee": entryFee.toString(),
        "title": title,
        "category": category,
      });

      final response = await http.post(
        queryUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json'
        },
      );



      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to start stream: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error starting stream: $e");
    }
  }

  Future<Map<String, dynamic>> joinStream(String sessionId) async {
    final url = Uri.parse("$_baseUrl/streaming/join/$sessionId");
    final token = AuthService.to.token;

    try {
      final response = await http.post(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'accept': 'application/json'
        },
      );


      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
         try {
             final err = jsonDecode(response.body);
             throw Exception(err['detail'] ?? "Failed to join stream");
         } catch(_) {

             throw Exception("Failed to join stream: ${response.statusCode}");
         }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> payStreamFee(String sessionId) async {
    final url = Uri.parse("$_baseUrl/streaming/pay/$sessionId");
    final token = AuthService.to.token;

    if (token == null) {
      throw Exception("Authentication Required");
    }

    try {
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
        try {
          final err = jsonDecode(response.body);
          throw Exception(err['detail'] ?? "Payment failed");
        } catch (_) {
          throw Exception("Payment failed: ${response.statusCode}");
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendGift(String sessionId, int amount) async {
    final url = Uri.parse("$_baseUrl/streaming/gifts/send?amount=$amount&session_id=$sessionId");
    final token = AuthService.to.token;
    if (token == null) throw Exception("Authentication Required");

    try {
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
         throw Exception("Failed to send gift: ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendLike(String sessionId) async {
    final url = Uri.parse("$_baseUrl/streaming/interactions/like?session_id=$sessionId");
    final token = AuthService.to.token;
    if (token == null) throw Exception("Authentication Required");

    try {
      final response = await http.post(
          url,
          headers: {'Authorization': 'Bearer $token'}
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
         throw Exception("Failed to like: ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendComment(String sessionId, String content) async {
    final url = Uri.parse("$_baseUrl/streaming/interactions/comment?session_id=$sessionId&content=$content");
    final token = AuthService.to.token;
    if (token == null) throw Exception("Authentication Required");

    try {
      final response = await http.post(
          url,
          headers: {'Authorization': 'Bearer $token'}
      );
      if (response.statusCode != 200) {
         throw Exception("Failed to comment: ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> stopStream(String sessionId) async {
    final url = Uri.parse("$_baseUrl/streaming/stop/$sessionId");
    final token = AuthService.to.token;
    if (token == null) return;

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json'
        },
      );

    } catch (e) {
      print("Error stopping stream: $e");
    }
  }

  Future<void> reportStream(String sessionId, String category, {String? description}) async {
    final token = AuthService.to.token;
    if (token == null) throw Exception("Authentication Required");

    final url = Uri.parse("$_baseUrl/streaming/interactions/report").replace(queryParameters: {
      "session_id": sessionId,
      "category": category,
      if (description != null) "description": description,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token', 'accept': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to report: ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LiveStreamModel>> getAllLiveStreams() async {
    final url = Uri.parse("$_baseUrl/streaming/active");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => LiveStreamModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }

  Future<List<LiveStreamModel>> getActiveStreamsByCategory(String category) async {
    final url = Uri.parse("$_baseUrl/streaming/active/$category");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => LiveStreamModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }

  Future<List<LiveStreamModel>> getFreeLiveStreams() async {
    final url = Uri.parse("$_baseUrl/streaming/active/all/free");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => LiveStreamModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }

  Future<List<LiveStreamModel>> getPremiumLiveStreams() async {
    // Note: Endpoint has specific path structure provided by user
    final url = Uri.parse("$_baseUrl/streaming/active/streams/all/premium");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => LiveStreamModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }
  Future<List<LiveStreamModel>> searchStreams(String query) async {
    final url = Uri.parse("$_baseUrl/streaming/search?q=$query");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => LiveStreamModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }
}
