
import 'package:get/get.dart';
import '../../../data/services/chat_socket_service.dart';
import '../../chat/controllers/active_users_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../explore/controllers/explore_controller.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../profile/controllers/profile_controller.dart';


class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ExploreController>(() => ExploreController());
    Get.lazyPut<ActiveUsersController>(() => ActiveUsersController());
    Get.lazyPut<ChatSocketService>(() => ChatSocketService());
    Get.lazyPut<ChatController>(() => ChatController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
