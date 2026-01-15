import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService.to;
  
  final user = Rxn<UserModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final userData = await _authService.getMyProfile();
      if (userData != null) {
        user.value = userData;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _authService.logout();
  }
}
