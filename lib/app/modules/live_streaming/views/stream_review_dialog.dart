
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/live_streaming_controller.dart';
import '../../../core/utils/snackbar_helper.dart';

class StreamReviewDialog extends StatefulWidget {
  final LiveStreamingController controller;
  const StreamReviewDialog({super.key, required this.controller});

  @override
  State<StreamReviewDialog> createState() => _StreamReviewDialogState();
}

class _StreamReviewDialogState extends State<StreamReviewDialog> {
  bool showReportView = false;
  String? selectedCategory;
  final TextEditingController reportController = TextEditingController();

  final List<String> categories = ["Nudity", "Violence", "Scam", "Harassment"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: showReportView ? _buildReportView() : _buildExperienceView(),
      ),
    );
  }

  Widget _buildExperienceView() {
    return Column(
      key: const ValueKey("ExperienceView"),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Stream Ended",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "How was your experience with ${widget.controller.roomName}?",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.verified_user_outlined,
                label: "Legitimate",
                color: Colors.greenAccent,
                onTap: () {
                  Get.offAllNamed(Routes.DASHBOARD);
                  SnackbarHelper.showSuccess("Success", "Glad you enjoyed the stream!");
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.report_problem_outlined,
                label: "Suspicious",
                color: Colors.redAccent,
                onTap: () {
                  setState(() {
                    showReportView = true;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Get.offAllNamed(Routes.DASHBOARD),
          child: const Text("Skip", style: TextStyle(color: Colors.white54, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildReportView() {
    return Column(
      key: const ValueKey("ReportView"),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "Report Stream",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            "If there is anything else you would like to review or report, please feel free to let me know.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: reportController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Write you complain here",
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text("Select category", style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: categories.map((cat) {
            final isSelected = selectedCategory == cat;
            return ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  selectedCategory = val ? cat : null;
                });
              },
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              selectedColor: Colors.blueAccent.withValues(alpha: 0.3),
              labelStyle: TextStyle(color: isSelected ? Colors.blueAccent : Colors.black),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: isSelected ? Colors.blueAccent : Colors.white24),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              if (selectedCategory == null) {
                SnackbarHelper.showError("Error", "Please select a category");
                return;
              }
              await widget.controller.reportStream(
                selectedCategory!, 
                reportController.text
              );
              Get.offAllNamed(Routes.DASHBOARD);
              SnackbarHelper.showNotice("Reported", "Thank you. We will review this stream.");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: const Text("Submit", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: (){
              Get.offAllNamed(Routes.DASHBOARD);
            },
            child: const Text("Skip", style: TextStyle(color: Colors.white54, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
