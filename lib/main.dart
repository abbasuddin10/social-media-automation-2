import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_automation/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 📂 Views Import
import 'views/accounts_view.dart';
import 'views/auth_view.dart';
import 'views/home_view.dart';
import 'views/instant_post_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ১. .env ফাইল লোড করা
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }

  // ২. Supabase Initialize
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  Get.put(AuthController(), permanent: true);

  // ৩. Persistent Login চেক
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Automation',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: isLoggedIn ? const HomeView() : const AuthView(),

      // 🎯 অ্যাপ ক্র্যাশ রোধে Named Routes রেজিস্টার করা হলো
      getPages: [
        GetPage(name: '/home', page: () => const HomeView()),
        GetPage(name: '/auth', page: () => const AuthView()),
        GetPage(name: '/accounts', page: () => const AccountsView()),
        GetPage(name: '/instant-post', page: () => const InstantPostView()),
      ],
    );
  }
}
