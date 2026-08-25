import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var isUpdating = false.obs;
  var isUploadingImage = false.obs; // 🖼️ ইমেজ আপলোডের লোডিং স্টেট
  var isTermsAccepted = false.obs;
  // Editable Fields (নাম এবং প্রোফাইল পিকচার URL)
  final nameController = TextEditingController();
  final profilePicController = TextEditingController();

  // Read-only Fields
  final emailController = TextEditingController();
  final userIdController = TextEditingController();

  // Connected Accounts State
  var connectedAccounts = <Map<String, dynamic>>[].obs;

  final String baseUrl = 'https://social-backend-1hwz.onrender.com/api';

  // 🛠️ ImagePicker & Supabase Instance
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  // ------------------ 📸 গ্যালারি থেকে ছবি নিয়ে Supabase-এ আপলোড ------------------
  Future<void> pickAndUploadImage() async {
    try {
      // ১. গ্যালারি থেকে পিক সিলেক্ট করা
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // পারফরম্যান্সের জন্য ইমেজ সাইজ কিছুটা কমপ্রেস করা
      );

      if (image == null) return; // ইউজার ক্যানসেল করলে ব্যাক করবে

      isUploadingImage.value = true;
      File file = File(image.path);

      // ২. ফাইল পাথ তৈরি (ইউজারের নিজস্ব ফোল্ডার: avatars/USER_ID/fileName.jpg)
      final String fileName =
          '${userIdController.text}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = '${userIdController.text}/$fileName';

      // ৩. Supabase 'avatars' বাকেটে পিক আপলোড
      await supabase.storage
          .from('avatars')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // ৪. আপলোড করা ইমেজের Public URL সংগ্রহ
      final String imageUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(path);

      // ৫. কন্ট্রোলার আপডেট এবং ব্যাকএন্ড ডাটাবেজে নতুন URL সেভ
      profilePicController.text = imageUrl;
      await updateUserProfile();

      Get.snackbar(
        'Success',
        'প্রোফাইল পিকচার সফলভাবে পরিবর্তন করা হয়েছে!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'ছবি আপলোড করতে সমস্যা হয়েছে: $e');
    } finally {
      isUploadingImage.value = false;
    }
  }

  // ------------------ 👤 প্রোফাইল ফেচিং ------------------
  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'সেশন শেষ হয়ে গেছে, দয়া করে আবার লগইন করুন!');
        return;
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/user/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var user = data['user'];

        if (!isClosed) {
          userIdController.text = user['id']?.toString() ?? '';
          nameController.text = user['name'] ?? '';
          emailController.text = user['email'] ?? '';
          profilePicController.text = user['profile_pic'] ?? '';

          if (data['connected_accounts'] != null) {
            connectedAccounts.assignAll(
              List<Map<String, dynamic>>.from(data['connected_accounts']),
            );
          }
        }
      } else {
        Get.snackbar('Error', 'প্রোফাইল লোড করতে ব্যর্থ হয়েছে!');
      }
    } catch (e) {
      Get.snackbar('Error', 'নেটওয়ার্ক সংযোগে সমস্যা হয়েছে!');
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  // 📤 নাম ও প্রোফাইল পিকচার আপডেট
  Future<void> updateUserProfile() async {
    isUpdating.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': nameController.text.trim(),
          'profile_pic': profilePicController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        update(); // UI রিফ্রেশ
      } else {
        Get.snackbar('Failed', data['message'] ?? 'আপডেট করা সম্ভব হয়নি!');
      }
    } catch (e) {
      Get.snackbar('Error', 'সমস্যা হয়েছে: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  // 🔑 লগইন পেইজের Forgot Password Flow ট্রিগার করা
  // 🔑 পাসওয়ার্ড রিসেট ডায়ালগ (Fixed Flow)
  void openResetPasswordDialog() {
    final authController = Get.find<AuthController>();
    authController.emailController.text = emailController.text;
    authController.isForgotPassword.value = true;
    authController.isOtpSent.value = false;
    authController.otpController.clear();
    authController.passwordController.clear();

    Get.defaultDialog(
      title: "Reset Password",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      contentPadding: const EdgeInsets.all(16),
      content: Obx(
        () => Column(
          children: [
            Text(
              "Email: ${emailController.text}",
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // ১. যদি OTP পাঠানো হয়ে থাকে, তবে OTP এবং New Password নেওয়ার ফিল্ড দেখাবে
            if (authController.isOtpSent.value) ...[
              TextField(
                controller: authController.otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "6-Digit OTP",
                  prefixIcon: const Icon(Icons.mark_email_read_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: authController.passwordController,
                obscureText: !authController.isPasswordVisible.value,
                decoration: InputDecoration(
                  labelText: "New Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      authController.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => authController.togglePasswordVisibility(),
                  ),
                ),
              ),
            ] else ...[
              const Text(
                "Click below to send an OTP to your email address.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            authController.isForgotPassword.value = false;
            Get.back();
          },
          child: const Text("Cancel"),
        ),
        Obx(
          () => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: authController.isLoading.value
                ? null
                : () async {
                    if (!authController.isOtpSent.value) {
                      // স্টেপ ১: OTP পাঠাবে
                      await authController.submitAuth();
                    } else {
                      // স্টেপ ২: OTP ও পাসওয়ার্ড ভেরিফাই করে পাসওয়ার্ড রিসেট করবে
                      await authController.submitAuth();
                      if (!authController.isLoading.value) {
                        Get.back(); // সফল হলে ডায়ালগ বন্ধ হবে
                      }
                    }
                  },
            child: authController.isLoading.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    authController.isOtpSent.value
                        ? "Reset Password"
                        : "Send OTP",
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  // ১. লাইভ সাপোর্ট (WhatsApp integration)
  Future<void> openLiveSupport() async {
    const phoneNumber = "+8801310881110"; // আপনার সাপোর্ট হোয়াটসঅ্যাপ নম্বর
    const message = "Hello, I need help with the Social Media Automation app.";
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        "Error",
        "Could not launch WhatsApp",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ২. অ্যাকাউন্ট ডিলিট ডায়ালগ ও লজিক
  void openDeleteAccountDialog() {
    isTermsAccepted.value = false; // Reset checkbox

    Get.defaultDialog(
      title: "Delete Account",
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.redAccent,
      ),
      contentPadding: const EdgeInsets.all(16),
      content: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              "আপনার অ্যাকাউন্ট মুছে ফেললে আপনার সকল তৈরি করা তথ্য স্থায়ীভাবে ডিলিট হয়ে যাবে এবং এটি আর পুনরুদ্ধার করা সম্ভব হবে না।",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            const Text(
              "কোনো সমস্যা বা অসুবিধার মুখোমুখি হলে অ্যাকাউন্ট ডিলিট না করে আমাদের Live Support-এ যোগাযোগ করুন।",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: isTermsAccepted.value,
                  onChanged: (val) => isTermsAccepted.value = val ?? false,
                  activeColor: Colors.red,
                ),
                const Expanded(
                  child: Text(
                    "আমি সব শর্ত বুঝেছি এবং অ্যাকাউন্ট স্থায়ীভাবে ডিলিট করতে চাই।",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        Obx(
          () => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isTermsAccepted.value ? Colors.red : Colors.grey,
            ),
            onPressed: isTermsAccepted.value
                ? () async {
                    Get.back();
                    await deleteUserAccount();
                  }
                : null,
            child: const Text(
              "Delete Permanently",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Supabase থেকে অ্যাকাউন্ট মোছার কাজ
  Future<void> deleteUserAccount() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // ডাটাবেজ টেবিল থেকে ইউজার ডাটা ক্লিন করা (প্রয়োজন অনুযায়ী)
        await Supabase.instance.client
            .from('profiles')
            .delete()
            .eq('id', user.id);

        // শাটডাউন/লগআউট
        await Supabase.instance.client.auth.signOut();
        Get.offAllNamed('/login'); // আপনার লগইন রুট
        Get.snackbar(
          "Deleted",
          "Your account has been deleted successfully.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete account: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    profilePicController.dispose();
    emailController.dispose();
    userIdController.dispose();
    super.onClose();
  }
}
