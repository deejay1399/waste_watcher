import 'package:flutter/material.dart';
import '../core/theme.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;
  final Color? color;
  final bool outlined;

  const CustomButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: outlined
              ? Colors.white
              : (color ?? AppTheme.primary),
          foregroundColor: outlined ? AppTheme.primary : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: outlined
                ? const BorderSide(color: AppTheme.primary)
                : BorderSide.none,
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
