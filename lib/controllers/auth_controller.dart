import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../views/home_view.dart';

class AuthController extends GetxController {
  var isLoginMode = true.obs;
  var isLoading = false.obs;

  // 🛡️ JWT টোকেন এবং ইউজার আইডি স্টোর করার জন্য ভেরিয়েবল যুক্ত করা হলো
  var token = ''.obs;
  var userId = ''.obs;

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
        'দয়া করে ইমেইল এবং পাসওয়ার্ড দিন',
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
        // 🛡️ ব্যাকএন্ডের পাঠানো token এবং user id সেভ করা (রেসপন্স স্ট্রাকচার অনুযায়ী)
        token.value = response['token'] ?? '';
        if (response['user'] != null) {
          userId.value = response['user']['id'].toString();
        }

        Get.snackbar(
          'সফল',
          response['message'] ?? 'সফলভাবে সম্পন্ন হয়েছে!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        if (isLoginMode.value) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);

          // ফিউচার কাজের সুবিধার্থে টোকেনটি লোকাল স্টোরেজেও সেভ করে রাখা ভালো
          if (token.value.isNotEmpty) {
            await prefs.setString('token', token.value);
          }

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
      // সবচেয়ে গুরুত্বপূর্ণ: সাকসেস হোক বা এরর আসুক, লোডিং চিরতরে বন্ধ হবেই
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
