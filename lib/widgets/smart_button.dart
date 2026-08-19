import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SmartButton extends StatelessWidget {
  final String text; // বাটনের নাম/টেক্সট
  final VoidCallback? onPressed; // বাটনে প্রেস করলে কি হবে
  final Color? backgroundColor; // কাস্টম ব্যাকগ্রাউন্ড কালার
  final Color? textColor; // কাস্টم টেক্সট কালার
  final IconData? icon; // বাটন এর আইকন (অপশনাল)
  final bool isLoading; // লোডিং স্পিনার দেখানোর জন্য
  final bool isOutlined; // আউটলাইন ডিজাইন কি না
  final double height; // বাটনের উচ্চতা
  final double borderRadius; // বাটনের কোণা গোল করার জন্য

  const SmartButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.height = 48.0,
    this.borderRadius = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final txtColor = textColor ?? (isOutlined ? bgColor : AppColors.white);

    return SizedBox(
      height: height,
      child: isOutlined
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: bgColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              onPressed: isLoading ? null : onPressed,
              child: _buildButtonChild(txtColor),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: txtColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              onPressed: isLoading ? null : onPressed,
              child: _buildButtonChild(txtColor),
            ),
    );
  }

  // বাটনের ভেতরের কন্টেন্ট (টেক্সট, আইকন অথবা লোডার)
  Widget _buildButtonChild(Color effectiveTextColor) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: effectiveTextColor,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: effectiveTextColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: effectiveTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        color: effectiveTextColor,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
