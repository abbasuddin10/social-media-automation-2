import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF311042)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔒 Branding Icon
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF818CF8), Color(0xFF6366F1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_person_rounded,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 📌 Title
                    Obx(
                      () => Text(
                        controller.isForgotPassword.value
                            ? 'Reset Password'
                            : (controller.isLoginMode.value
                                  ? 'Welcome Back'
                                  : 'Create Account'),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle
                    Obx(
                      () => Text(
                        controller.isForgotPassword.value
                            ? 'Enter your email to receive an OTP'
                            : (controller.isLoginMode.value
                                  ? (controller.isOtpSent.value
                                        ? 'Enter the OTP sent to your email'
                                        : 'Please sign in to continue')
                                  : 'Fill in the details to get started'),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ✉️ Email Field
                    TextField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                        hintText: 'Email Address',
                        icon: Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔢 OTP Field
                    Obx(
                      () => controller.isOtpSent.value
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: TextField(
                                controller: controller.otpController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildInputDecoration(
                                  hintText: '6-Digit OTP Code',
                                  icon: Icons.mark_email_read_outlined,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // 🔑 Password Field (With Toggle)
                    Obx(
                      () =>
                          (!controller.isForgotPassword.value ||
                              controller.isOtpSent.value)
                          ? TextField(
                              controller: controller.passwordController,
                              obscureText: !controller.isPasswordVisible.value,
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration(
                                hintText: controller.isForgotPassword.value
                                    ? 'New Password'
                                    : 'Password',
                                icon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white60,
                                  ),
                                  onPressed: () =>
                                      controller.togglePasswordVisibility(),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // ❓ Forgot Password Link
                    Obx(
                      () =>
                          (controller.isLoginMode.value &&
                              !controller.isForgotPassword.value)
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    controller.toggleForgotPassword(),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Color(0xFFA5B4FC),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(height: 12),
                    ),

                    // 🚀 Main Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: const Color(
                              0xFF6366F1,
                            ).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.submitAuth(),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  controller.isForgotPassword.value
                                      ? (controller.isOtpSent.value
                                            ? 'Reset Password'
                                            : 'Send OTP')
                                      : (controller.isLoginMode.value
                                            ? (controller.isOtpSent.value
                                                  ? 'Verify OTP & Sign In'
                                                  : 'Sign In')
                                            : 'Register'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🔘 Divider
                    Obx(
                      () => (!controller.isForgotPassword.value)
                          ? Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.white.withOpacity(0.15),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.white.withOpacity(0.15),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),

                    // 🌐 Google Sign In Button
                    Obx(
                      () => (!controller.isForgotPassword.value)
                          ? SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  backgroundColor: Colors.white.withOpacity(
                                    0.05,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.g_mobiledata_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                label: const Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () => controller.signInWithGoogle(),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 16),

                    // 🔄 Toggle Auth Mode
                    Obx(
                      () => TextButton(
                        onPressed: () {
                          if (controller.isForgotPassword.value) {
                            controller.toggleForgotPassword();
                          } else {
                            controller.toggleMode();
                          }
                        },
                        child: Text(
                          controller.isForgotPassword.value
                              ? 'Back to Sign In'
                              : (controller.isLoginMode.value
                                    ? "Don't have an account? Sign Up"
                                    : 'Already have an account? Sign In'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white70, size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.07),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF818CF8), width: 1.5),
      ),
    );
  }
}
