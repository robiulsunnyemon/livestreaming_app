import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/finance_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_pages.dart';

class WithdrawToView extends GetView<FinanceController> {
  const WithdrawToView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Withdraw to',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.beneficiaries.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: controller.beneficiaries.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: controller.beneficiaries.length,
                        itemBuilder: (context, index) {
                          final item = controller.beneficiaries[index];
                          return _buildMethodItem(
                            title: item.method == "bank_transfer" ? "Bank transfer" : item.method.capitalizeFirst!,
                            subtitle: item.displayAccount,
                            method: item.method,
                            onTap: () => controller.selectBeneficiary(item),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              _buildAddAccountButton(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text("No payment methods linked", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildMethodItem({
    required String title,
    required String subtitle,
    required String method,
    required VoidCallback onTap,
  }) {
    IconData icon = Icons.account_balance;
    if (method == "paypal") icon = Icons.payment;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white70),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      ),
    );
  }

  Widget _buildAddAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () => Get.toNamed(Routes.LINK_ACCOUNT),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text("Add New Account", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
