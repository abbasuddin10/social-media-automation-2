import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://social-backend-1hwz.onrender.com/api";

  // 🔑 ১. লগইন সার্ভিস
  Future<Map<String, dynamic>> authUser(
    String email,
    String password,
    bool isLogin,
  ) async {
    final url = Uri.parse('$baseUrl/${isLogin ? 'login' : 'register'}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'কিছু একটা সমস্যা হয়েছে');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 📩 ২. ইমেইলে OTP পাঠানোর সার্ভিস
  Future<Map<String, dynamic>> sendOtp(String email, String type) async {
    final url = Uri.parse('$baseUrl/send-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'type': type}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'OTP পাঠাতে ব্যর্থ হয়েছে');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 🎯 ৩. সরাসরি সাইন-আপ (OTP ছাড়া)
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return responseData;
      } else {
        throw Exception(
          responseData['message'] ?? 'রেজিস্ট্রেশন ব্যর্থ হয়েছে',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 🔑 ৪. লগইন OTP ভেরিফাই মেথড
  Future<Map<String, dynamic>> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/login-verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(
          responseData['message'] ?? 'OTP ভেরিফিকেশন ব্যর্থ হয়েছে',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 🔓 ৫. ফরগেট পাসওয়ার্ড
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/reset-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(
          responseData['message'] ?? 'পাসওয়ার্ড রিসেট ব্যর্থ হয়েছে',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 🌐 ৬. গুগল লগইন (Fixed Response Handling)
  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final url = Uri.parse('$baseUrl/google-login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'গুগল লগইন ব্যর্থ হয়েছে');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
