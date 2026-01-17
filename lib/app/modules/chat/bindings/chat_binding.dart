import 'package:get/get.dart';
import '../../../data/services/chat_socket_service.dart';
import '../controllers/chat_controller.dart';
import '../controllers/active_users_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatSocketService>(
      () => ChatSocketService(),
    );
    Get.lazyPut<ChatController>(
      () => ChatController(),
    );
    Get.lazyPut<ActiveUsersController>(
      () => ActiveUsersController(),
    );
  }
}
