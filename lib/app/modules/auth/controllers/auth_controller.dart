import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  // Registration
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // OTP
  final otpController = TextEditingController();

  // Reset Password
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.value = !isPasswordVisible.value;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  
  // Login
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }
    
    isLoading.value = true;
    final success = await _authService.login(emailController.text.trim(), passwordController.text);
    isLoading.value = false;
    
    if (success) {
      Get.offAllNamed(Routes.DASHBOARD);
    }
  }

  // Register
  Future<void> register() async {
    if (emailController.text.isEmpty || 
        passwordController.text.isEmpty || 
        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }
    
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    isLoading.value = true;
    final success = await _authService.signup(
      firstNameController.text.trim(),
      lastNameController.text.trim(),
      emailController.text.trim(),
      passwordController.text
    );
    isLoading.value = false;

    if (success) {
      // Pass email to OTP view
      Get.toNamed(Routes.OTP, arguments: {'email': emailController.text.trim()});
    }
  }

  // Verify OTP
  Future<void> verifyOtp() async {
    final email = Get.arguments?['email'] ?? emailController.text.trim();
    if (email.isEmpty || otpController.text.isEmpty) {
      Get.snackbar("Error", "Please enter OTP");
      return;
    }

    isLoading.value = true;
    final success = await _authService.verifyOtp(email, otpController.text.trim());
    isLoading.value = false;

    if (success) {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  // Resend OTP
  Future<void> resendOtp() async {
    final email = Get.arguments?['email'] ?? emailController.text.trim();
    if (email.isEmpty) {
       Get.snackbar("Error", "Email not found");
       return;
    }
    isLoading.value = true;
    await _authService.resendOtp(email);
    isLoading.value = false;
    Get.snackbar("Success", "OTP Resent");
  }

  // Forgot Password
  Future<void> forgotPassword() async {
    if (emailController.text.isEmpty) {
      Get.snackbar("Error", "Please enter your email");
      return;
    }

    isLoading.value = true;
    final success = await _authService.resendOtp(emailController.text.trim()); // Reusing resendOtp as it triggers OTP email
    isLoading.value = false;

    if (success) {
      Get.toNamed(Routes.OTP, arguments: {
        'email': emailController.text.trim(),
        'isReset': true
      });
    }
  }
  
  // In OTP View, if isReset=true, navigate to ResetPasswordView after verification
  Future<void> verifyOtpForReset() async {
     final email = Get.arguments?['email'];
     if (email == null || otpController.text.isEmpty) return;

     isLoading.value = true;
     final success = await _authService.verifyOtp(email, otpController.text.trim());
     isLoading.value = false;

     if (success) {
       Get.toNamed(Routes.RESET_PASSWORD, arguments: {'email': email});
     }
  }


  // Reset Password
  Future<void> resetPassword() async {
    final email = Get.arguments?['email'];
    if (email == null) {
      Get.snackbar("Error", "Session error, please try again");
      return;
    }
    
    if (newPasswordController.text.isEmpty || newPasswordController.text != confirmNewPasswordController.text) {
       Get.snackbar("Error", "Passwords do not match or empty");
       return;
    }

    isLoading.value = true;
    final success = await _authService.resetPassword(email, newPasswordController.text);
    isLoading.value = false;

    if (success) {
      Get.offAllNamed(Routes.LOGIN);
      Get.snackbar("Success", "Password reset successfully");
    }
  }
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }
}
