
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class ResetPasswordView extends GetView<AuthController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.altBackground, // Dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
             const SizedBox(height: 40),
            const Text(
              "New Password",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            
            // New Password
            Obx(() => _buildTextField(
              controller: controller.newPasswordController,
              label: "New Password",
              hint: "••••••••",
              obscureText: !controller.isPasswordVisible.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            )),
            const SizedBox(height: 16),

            // Confirm Password
            Obx(() => _buildTextField(
              controller: controller.confirmNewPasswordController,
              label: "Confirm Password",
              hint: "••••••••",
              obscureText: !controller.isConfirmPasswordVisible.value,
               suffixIcon: IconButton(
                icon: Icon(
                  controller.isConfirmPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
            )),
            const SizedBox(height: 32),

            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryPrimary, // Blurple color
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 8,
                  shadowColor: const Color(0xFF4C4DDC).withOpacity(0.5),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save & Update", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: AppColors.fieldBackground, // Slightly darker for input
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blueAccent),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
