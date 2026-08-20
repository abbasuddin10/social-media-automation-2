import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../views/home_view.dart';

class AuthController extends GetxController {
  var isLoginMode = true.obs;
  var isForgotPassword = false.obs;
  var isOtpSent = false.obs;
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  var token = ''.obs;
  var userId = ''.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  final ApiService _apiService = ApiService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '910096214036-4gi7puoqg1edarqub27v7mluqqt6fht6.apps.googleusercontent.com',
  );

  @override
  void onInit() {
    super.onInit();
    _loadSavedUserData();
  }

  Future<void> _loadSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getString('userId') ?? '';
    token.value = prefs.getString('token') ?? '';
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
    isForgotPassword.value = false;
    isOtpSent.value = false;
    _clearInputs();
  }

  void toggleForgotPassword() {
    isForgotPassword.value = !isForgotPassword.value;
    isOtpSent.value = false;
    _clearInputs();
  }

  void _clearInputs() {
    passwordController.clear();
    otpController.clear();
  }

  Future<void> _saveUserData(String userToken, String uId) async {
    token.value = userToken;
    userId.value = uId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    if (uId.isNotEmpty) await prefs.setString('userId', uId);
    if (userToken.isNotEmpty) await prefs.setString('token', userToken);
  }

  Future<void> submitAuth() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final otp = otpController.text.trim();

    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email address',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // 🎯 ১. FORGOT PASSWORD FLOW
      if (isForgotPassword.value) {
        if (!isOtpSent.value) {
          final response = await _apiService.sendOtp(email, 'reset');
          isOtpSent.value = true;
          Get.snackbar(
            'Success',
            response['message'] ?? 'OTP Sent to email',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          if (otp.isEmpty || password.isEmpty) {
            Get.snackbar(
              'Error',
              'Please enter both OTP and new password',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }
          final response = await _apiService.resetPassword(
            email: email,
            otp: otp,
            newPassword: password,
          );
          Get.snackbar(
            'Success',
            response['message'] ?? 'Password reset successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          toggleForgotPassword();
        }
        return;
      }

      // 🎯 ২. DIRECT LOGIN FLOW
      if (isLoginMode.value) {
        if (password.isEmpty) {
          Get.snackbar(
            'Error',
            'Please enter password',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        final response = await _apiService.authUser(email, password, true);

        await _saveUserData(
          response['token'] ?? '',
          response['user']?['id']?.toString() ?? '',
        );

        Get.snackbar(
          'Success',
          response['message'] ?? 'Login successful',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAll(() => const HomeView());
        return;
      }
      // 🎯 ৩. DIRECT REGISTER FLOW
      else {
        if (password.isEmpty) {
          Get.snackbar(
            'Error',
            'Please enter password',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        final response = await _apiService.registerUser(
          email: email,
          password: password,
        );

        await _saveUserData(
          response['token'] ?? '',
          response['user']?['id']?.toString() ?? '',
        );

        Get.snackbar(
          'Success',
          response['message'] ?? 'Registration successful',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAll(() => const HomeView());
        return;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        Get.snackbar(
          'Error',
          'Google token not found',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final response = await _apiService.googleLogin(idToken);

      await _saveUserData(
        response['token'] ?? '',
        response['user']?['id']?.toString() ?? '',
      );

      Get.snackbar(
        'Success',
        response['message'] ?? 'Google Login successful',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAll(() => const HomeView());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Google sign-in error: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _googleSignIn.signOut();
    userId.value = '';
    token.value = '';
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
