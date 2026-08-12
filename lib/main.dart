import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_automation/controllers/auth_controller.dart';
import 'views/auth_view.dart';
import 'views/home_view.dart';

void main() async {
  // ফ্লাটার বাইন্ডিং ইনিশিয়ালাইজ করা বাধ্যতামূলক
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AuthController(), permanent: true);

  // চেক করা ইউজার আগে থেকেই লগইন করা আছে কি না (Persistent Login)
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // GetX ব্যবহারের জন্য MaterialApp-এর পরিবর্তে GetMaterialApp ব্যবহার করতে হয়
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Automation',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // যদি লগইন করা থাকে সরাসরি হোম ভিউ, না হলে অথ ভিউ দেখাবে
      home: isLoggedIn ? const HomeView() : const AuthView(),
    );
  }
}
