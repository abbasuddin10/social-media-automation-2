import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../views/home_view.dart';

class AuthController extends GetxController {
  var isLoginMode = true.obs;
  var isLoading = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final ApiService _apiService = ApiService();

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
    emailController.clear();
    passwordController.clear();
  }

  Future<void> submitAuth() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'এরর',
        'দয়া করে ইমেইল এবং পাসওয়ার্ড দিন',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true; // লোডিং শুরু

    try {
      final response = await _apiService.authUser(
        email,
        password,
        isLoginMode.value,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'সফল',
          response['message'],
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        if (isLoginMode.value) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          Get.offAll(() => const HomeView());
        } else {
          isLoginMode.value = true;
          passwordController.clear();
        }
      }
    } catch (e) {
      Get.snackbar(
        'এরর',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // সবচেয়ে গুরুত্বপূর্ণ: সাকসেস হোক বা এরর আসুক, লোডিং চিরতরে বন্ধ হবেই
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
