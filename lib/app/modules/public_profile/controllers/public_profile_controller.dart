import 'package:get/get.dart';
import '../../../data/services/social_service.dart';
import '../../../data/models/user_model.dart'; // Ensure UserModel exists or use map
import '../../../routes/app_pages.dart';

class PublicProfileController extends GetxController {
  final SocialService _socialService = Get.find<SocialService>();
  final String userId = Get.arguments ?? "";
  
  final isLoading = true.obs;
  // Use generic map for now as PublicProfileResponse might differ slightly from UserModel
  final userProfile = Rxn<Map<String, dynamic>>(); 
  final isFollowing = false.obs;

  final tabs = ["All", "Past Streams"];
  final selectedTab = "All".obs;

  @override
  void onInit() {
    super.onInit();
    if (userId.isNotEmpty) {
      fetchProfile();
    }
  }

  void fetchProfile() async {
    isLoading.value = true;
    final profile = await _socialService.getPublicProfile(userId);
    if (profile != null) {
        userProfile.value = profile;
        isFollowing.value = profile['is_following'] ?? false;
    }
    isLoading.value = false;
  }

  void toggleFollow() async {
     if (userProfile.value == null) return;
     
     bool success;
     if (isFollowing.value) {
       success = await _socialService.unfollowUser(userId);
       if (success) {
          isFollowing.value = false;
          // Update local count
          if (userProfile.value!['followers_count'] != null) {
            userProfile.value!['followers_count']--;
             userProfile.refresh();
          }
       }
     } else {
       success = await _socialService.followUser(userId);
       if (success) {
          isFollowing.value = true;
          // Update local count
          if (userProfile.value!['followers_count'] != null) {
            userProfile.value!['followers_count']++;
            userProfile.refresh();
          }
       }
     }
  }

  void messageUser() {
    // If we are already in a chat context (check stack?) - but safe to just route to Chat
    // Assuming Get.toNamed handles stack or replaces if same.
    final user = userProfile.value;
    if (user != null) {
        Get.toNamed(Routes.CHAT, arguments: {
            'receiverId': userId,
            'receiverName': "${user['first_name']} ${user['last_name'] ?? ''}",
            'receiverImage': user['profile_image']
        });
    }
  }
}
