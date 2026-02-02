import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/auth_service.dart';
import '../../chat/controllers/active_users_controller.dart';

class DashboardController extends GetxController {
  final currentIndex = 0.obs;

  void changePage(int index) {
    // Restricted tabs for guests: Start Live (2), Chat/Active Users (3), Profile (4)
    if (index >= 2) {
      if (!AuthService.to.isLoggedIn) {
        Get.toNamed(Routes.LOGIN);
        return;
      }
    }

    if (index == 2) {
      // Start Live tab index
      Get.toNamed(Routes.START_LIVE);
    } else {
      if (currentIndex.value != index) {
        try {
          if (Get.isRegistered<ActiveUsersController>()) {
            Get.find<ActiveUsersController>().clearSearch();
          }
        } catch (e) {
          // Controller might not be registered yet
        }
      }
      currentIndex.value = index;
    }
  }
}
