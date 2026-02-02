import 'package:get/get.dart';
import '../controllers/public_profile_controller.dart';
import '../../../data/services/social_service.dart';

class PublicProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SocialService>(() => SocialService());
    Get.lazyPut<PublicProfileController>(
      () => PublicProfileController(),
    );
  }
}
