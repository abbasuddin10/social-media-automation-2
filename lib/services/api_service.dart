import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl =
      "https://social-backend-1hwz.onrender.com/api"; // এমুলেটর হলে এটি, আসল ফোন হলে আইপি দিন

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
        // ব্যাকএন্ড থেকে পাঠানো সুনির্দিষ্ট এরর মেসেজ থ্রো করা
        throw Exception(responseData['message'] ?? 'কিছু একটা সমস্যা হয়েছে');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
