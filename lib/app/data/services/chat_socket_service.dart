import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../data/services/auth_service.dart';

class ChatSocketService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get messages => _messageController.stream;

  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get typingEvents => _typingController.stream;

  final _userStatusController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get userStatusEvents => _userStatusController.stream;
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void connect() async {
    if (_isConnected) return;

    final token = AuthService.to.token;
    if (token == null) return;

    final profile = await AuthService.to.getMyProfile();
    if (profile == null) return;

    final wsUrl = "${AuthService.wsUrl}?token=$token";
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      
      _channel!.stream.listen(
        (data) {
          final payload = jsonDecode(data);
          
          // Handle heartbeat Ping from backend
          if (payload['type'] == 'ping') {
            sendMessage({"type": "pong"});
            return;
          }

          // Handle Typing Events
          if (payload['type'] == 'typing' || payload['type'] == 'stop_typing') {
            _typingController.add(payload);
            return;
          }

          // Handle User Status Events
          if (payload['type'] == 'user_connected' || payload['type'] == 'user_disconnected') {
            _userStatusController.add(payload);
            return;
          }

          // Handle Call Signals globally if needed, or pass to listeners

          _messageController.add(payload);

          // We check for incoming call even when not in ChatView
          if (payload['type'] == 'call_incoming') {
              _handleIncomingCall(payload);
          }
        },
        onError: (error) {

          _isConnected = false;
          _reconnect();
        },
        onDone: () {

          _isConnected = false;
          _reconnect(); // Added reconnection on done
        },
      );
    } catch (e) {

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

  void sendTyping(String receiverId) {
    sendMessage({
      "type": "typing",
      "receiver_id": receiverId,
    });
  }

  void sendStopTyping(String receiverId) {
    sendMessage({
      "type": "stop_typing",
      "receiver_id": receiverId,
    });
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
    _typingController.close();
    _userStatusController.close();
  }
}
