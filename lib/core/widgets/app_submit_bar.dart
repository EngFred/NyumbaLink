import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';

/// Replaces: SubmitBar in bookings/book/ and complaints/
class AppSubmitBar extends StatelessWidget {
  const AppSubmitBar({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    this.label = 'Submit',
    this.icon = Icons.send_rounded,
  });

  final bool isLoading;
  final VoidCallback onSubmit;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(icon, size: 18), const Gap(10), Text(label)],
                ),
        ),
      ),
    );
  }
}
