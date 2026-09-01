import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../controllers/ai_video_controller.dart';

class SmartButton extends StatelessWidget {
  final String?
  text; // বাটনের নাম/টেক্সট (অপশনাল, কন্ট্রোলার থাকলে অটো জেনারেট হবে)
  final VoidCallback? onPressed; // বাটনে প্রেস করলে কি হবে
  final Color? backgroundColor; // কাস্টম ব্যাকগ্রাউন্ড কালার
  final Color? textColor; // কাস্টম টেক্সট কালার
  final IconData? icon; // বাটন এর আইকন (অপশনাল)
  final bool isLoading; // লোডিং স্পিনার দেখানোর জন্য
  final bool isOutlined; // আউটলাইন ডিজাইন কি না
  final double height; // বাটনের উচ্চতা
  final double borderRadius; // বাটনের কোণা গোল করার জন্য
  final AiVideoController?
  controller; // AI Video പേজের ডাইনামিক পোস্ট/শিডিউল কন্ট্রোলারের জন্য

  const SmartButton({
    super.key,
    this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.height = 48.0,
    this.borderRadius = 10.0,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // ১. AI Video Page-এর জন্য ডাইনামিক রেসপনসিভ লজিক
    if (controller != null) {
      return Obx(() {
        final ctrl = controller!;
        final isEnabled = ctrl.canPost;
        final isSchedule = ctrl.isScheduled.value;
        final loading = ctrl.isSubmitting.value || isLoading;

        // ডাইনামিক টেক্সট সেট করা
        String dynamicText = text ?? '🚀 Publish Now';
        if (text == null && isSchedule) {
          if (ctrl.scheduledDateTime.value != null) {
            String formattedTime = DateFormat(
              'MMM d, h:mm a',
            ).format(ctrl.scheduledDateTime.value!);
            dynamicText = '📅 Schedule for [$formattedTime]';
          } else {
            dynamicText = '📅 Select Date & Time';
          }
        }

        VoidCallback? action = isEnabled && !loading
            ? (onPressed ?? () => ctrl.submitPost())
            : null;

        return _buildButtonContent(
          context: context,
          displayText: dynamicText,
          actionOnPressed: action,
          showLoading: loading,
          isDisabled: !isEnabled,
        );
      });
    }

    // ২. আগের সাধারণ ব্যবহারের জন্য (Normal Button Logic)
    return _buildButtonContent(
      context: context,
      displayText: text ?? '',
      actionOnPressed: isLoading ? null : onPressed,
      showLoading: isLoading,
      isDisabled: onPressed == null,
    );
  }

  // আপনার মূল ডিজাইন অনুসরণ করে বাটন বিল্ডিং
  Widget _buildButtonContent({
    required BuildContext context,
    required String displayText,
    required VoidCallback? actionOnPressed,
    required bool showLoading,
    required bool isDisabled,
  }) {
    final bgColor = isDisabled
        ? Colors.grey.shade400
        : (backgroundColor ?? AppColors.primary);
    final txtColor = textColor ?? (isOutlined ? bgColor : AppColors.white);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: bgColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              onPressed: actionOnPressed,
              child: _buildButtonChild(displayText, txtColor, showLoading),
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
              onPressed: actionOnPressed,
              child: _buildButtonChild(displayText, txtColor, showLoading),
            ),
    );
  }

  // বাটনের ভেতরের কন্টেন্ট (টেক্সট, আইকন অথবা লোডার)
  Widget _buildButtonChild(
    String displayText,
    Color effectiveTextColor,
    bool showLoading,
  ) {
    if (showLoading) {
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
            displayText,
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
      displayText,
      style: TextStyle(
        color: effectiveTextColor,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
