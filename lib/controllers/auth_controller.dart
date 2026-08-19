import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../views/home_view.dart';

class AuthController extends GetxController {
  var isLoginMode = true.obs;
  var isLoading = false.obs;

  var token = ''.obs;
  var userId = ''.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    _loadSavedUserData(); // 🔄 অ্যাপ খোলার সাথে সাথে সেভ থাকা User ID লোড হবে
  }

  // 💾 লোকাল স্টোরেজ থেকে ডাটা লোড করার ফাংশন
  Future<void> _loadSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getString('userId') ?? '';
    token.value = prefs.getString('token') ?? '';
  }

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

    isLoading.value = true;

    try {
      final response = await _apiService.authUser(
        email,
        password,
        isLoginMode.value,
      );

      if (response['success'] == true) {
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

          // 🎯 সবচেয়ে গুরুত্বপূর্ণ: userId এবং token পাকাপাকিভাবে লোকাল স্টোরেজে সেভ করা
          if (userId.value.isNotEmpty) {
            await prefs.setString('userId', userId.value);
          }
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
      isLoading.value = false;
    }
  }

  // 🚪 লগআউট করার সময় লোকাল ডাটা ক্লিয়ার করার হেলপার ফাংশন
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    userId.value = '';
    token.value = '';
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
