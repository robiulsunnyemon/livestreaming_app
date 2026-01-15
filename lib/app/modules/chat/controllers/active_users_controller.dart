import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/chat_service.dart';
import '../../../routes/app_pages.dart';

class ActiveUsersController extends GetxController {
  final ChatService _chatService = ChatService();
  
  final activeUsers = <UserModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActiveUsers();
  }

  Future<void> fetchActiveUsers() async {
    isLoading.value = true;
    try {
      final users = await _chatService.getActiveUsers();
      activeUsers.assignAll(users);
    } finally {
      isLoading.value = false;
    }
  }

  void startChat(UserModel user) {
    Get.toNamed(Routes.CHAT, arguments: {
      'id': user.id,
      'name': user.fullName,
      'image': user.profileImage,
    });
  }
}
