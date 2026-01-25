import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../data/services/auth_service.dart';

class ChatSocketService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get messages => _messageController.stream;
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void connect() async {
    if (_isConnected) return;

    final token = AuthService.to.token;
    if (token == null) return;

    final profile = await AuthService.to.getMyProfile();
    if (profile == null) return;

    final wsUrl = "wss://erronliveapp.mtscorporate.com/api/v1/chat/ws?token=$token";
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      
      _channel!.stream.listen(
        (data) {
          final payload = jsonDecode(data);
          // Handle Call Signals globally if needed, or pass to listeners
          // For now, we broadcast everything, but we can intercept here.
          _messageController.add(payload);

          // We check for incoming call even when not in ChatView
          if (payload['type'] == 'call_incoming') {
              _handleIncomingCall(payload);
          }
        },
        onError: (error) {
          print("WebSocket Error: $error");
          _isConnected = false;
          _reconnect();
        },
        onDone: () {
          print("WebSocket Closed");
          _isConnected = false;
        },
      );
    } catch (e) {
      print("WebSocket Connection Error: $e");
      _isConnected = false;
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected) {
        connect();
      }
    });
  }

  void sendMessage(Map<String, dynamic> payload) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode(payload));
    } else {
      print("Cannot send message: WebSocket not connected");
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }

  void _handleIncomingCall(Map<String, dynamic> payload) {
    // Navigate to a global "Incoming Call" screen or show a persistent dialog
    // Assuming we have a named route for calls
    Get.toNamed('/call', arguments: {
        'room_name': payload['room_name'],
        'caller_id': payload['caller_id'],
        'caller_name': payload['caller_name'],
        'caller_image': payload['caller_image'],
        'call_type': payload['call_type'],
        'is_incoming': true
    });
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
