import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService.to;
  final ImagePicker _picker = ImagePicker();
  
  final user = Rxn<UserModel>();
  final isLoading = false.obs;
  final isUploading = false.obs;
  
  final selectedTab = "All".obs;
  final tabs = ["All", "Past Streams", "Insights"];

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    ever(selectedTab, (tab) {
      if (tab == "Insights") {
        fetchWalletStats();
      }
    });
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
  
  final coinBalance = 0.0.obs;
  final tokenRateUsd = 0.0.obs;
  final fiatValue = 0.0.obs;

  Future<void> fetchWalletStats() async {
    final stats = await _authService.getWalletStats();
    if (stats != null) {
      coinBalance.value = (stats['coin_balance'] ?? 0).toDouble();
      tokenRateUsd.value = (stats['token_rate_usd'] ?? 0).toDouble();
      fiatValue.value = (stats['estimated_fiat_value'] ?? 0).toDouble();
    }
  }

  Future<void> buyTokens(int tokens, double amount) async {
    try {
      isLoading.value = true;
      
      // 1. Create Payment Intent
      final paymentData = await _authService.createStripePaymentIntent(amount, tokens);
      if (paymentData == null) return;

      final clientSecret = paymentData['client_secret'];

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'InstaLive',
          style: ThemeMode.dark,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: AppColors.secondaryPrimary,
            ),
          ),
        ),
      );

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Success
      Get.snackbar(
        "Success", 
        "Payment successful! $tokens tokens added to your wallet.",
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.white,
      );
      
      // Refresh balance
      await fetchWalletStats();
      await fetchProfile();

    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        // User canceled, no need to show error
      } else {
        Get.snackbar("Payment Error", e.error.localizedMessage ?? "An error occurred");
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUploadImage(bool isProfile) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;

    isUploading.value = true;
    try {
      bool success = false;
      if (isProfile) {
        success = await _authService.uploadProfileImage(image.path);
      } else {
        success = await _authService.uploadCoverImage(image.path);
      }

      if (success) {
        await fetchProfile();
        Get.snackbar("Success", "${isProfile ? 'Profile' : 'Cover'} image updated successfully");
      }
    } finally {
      isUploading.value = false;
    }
  }

  void logout() {
    _authService.logout();
  }
}
