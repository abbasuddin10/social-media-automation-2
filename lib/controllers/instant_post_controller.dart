import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:social_media_automation/controllers/accounts_view_controller.dart';
import 'auth_controller.dart';

class InstantPostController extends GetxController {
  // 🎯 Text Controllers
  final promptInputController = TextEditingController();
  final captionInputController = TextEditingController();
  final hashtagInputController = TextEditingController();

  // 🎯 AccountsViewController রেফারেন্স
  late AccountsViewController accountsController;

  // 🎯 Observable States
  var selectedImage = Rxn<File>();
  var isAiMode = true.obs;
  var isLoadingAi = false.obs;
  var isLoading = false.obs;
  var captionText = ''.obs;
  var hashtagText = ''.obs;

  // 🎯 সোশ্যাল মিডিয়া অ্যাকাউন্ট লিস্ট (YouTube বদলে LinkedIn যুক্ত করা হয়েছে)
  var connectedAccounts = <Map<String, String>>[
    {'key': 'facebook', 'platform': 'Facebook Page'},
    {'key': 'instagram', 'platform': 'Instagram Business'},
    {'key': 'linkedin', 'platform': 'LinkedIn Profile/Page'},
    {'key': 'pinterest', 'platform': 'Pinterest Profile'},
    {'key': 'twitter', 'platform': 'Twitter (X)'},
  ].obs;

  // 🎯 সিলেক্ট করা একাউন্টগুলোর লিস্ট
  var selectedAccounts = <String>[].obs;

  @override
  void onInit() {
    super.onInit();

    // AccountsViewController পাওয়া বা পুট করা
    if (Get.isRegistered<AccountsViewController>()) {
      accountsController = Get.find<AccountsViewController>();
    } else {
      accountsController = Get.put(AccountsViewController());
    }

    // কানেকশন স্ট্যাটাস ফেচ করা ও সিঙ্ক করা
    accountsController.fetchConnectionStatus();
    _syncConnectedAccounts();
  }

  // 🎯 শুধুমাত্র যা কানেক্টেড আছে তা সিলেক্ট রাখা
  void _syncConnectedAccounts() {
    selectedAccounts.clear();
    if (accountsController.isFacebookConnected.value) {
      selectedAccounts.add('facebook');
    }
    if (accountsController.isInstagramConnected.value) {
      selectedAccounts.add('instagram');
    }
    if (accountsController.isLinkedinConnected.value) {
      selectedAccounts.add('linkedin');
    }
    if (accountsController.isPinterestConnected.value) {
      selectedAccounts.add('pinterest');
    }
    if (accountsController.isTwitterConnected.value) {
      selectedAccounts.add('twitter');
    }
  }

  // 🔗 অ্যাকাউন্ট সিলেকশন টগল এবং লক অ্যাকাউন্ট হ্যান্ডলিং (ক্র্যাশ ফিক্স সহ)
  void toggleAccountSelection(
    String key,
    bool isConnected,
    String platformName,
  ) {
    if (!isConnected) {
      Get.defaultDialog(
        title: 'অ্যাকাউন্ট কানেক্ট নেই',
        titleStyle: const TextStyle(fontWeight: FontWeight.bold),
        middleText:
            '$platformName-এ পোস্ট করতে হলে অ্যাকাউন্টটি আগে কানেক্ট করুন।',
        textConfirm: 'Connect Now',
        textCancel: 'বাতিল',
        confirmTextColor: Colors.white,
        buttonColor: Colors.deepPurple,
        onConfirm: () {
          // ১. অ্যাপ ক্র্যাশ প্রতিরোধে আগে ডায়ালগটি বন্ধ করুন
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }

          // ২. ডায়ালগ বন্ধ হওয়া নিশ্চিত হয়ে নেভিগেট করুন
          Future.microtask(() {
            Get.toNamed('/accounts');
          });
        },
      );
      return;
    }

    if (selectedAccounts.contains(key)) {
      selectedAccounts.remove(key);
    } else {
      selectedAccounts.add(key);
    }
  }

  // 🎯 কেবল কানেক্টেড একাউন্টগুলোর জন্য Select All
  void toggleSelectAllAccounts(bool? selectAll) {
    if (selectAll == true) {
      _syncConnectedAccounts();
    } else {
      selectedAccounts.clear();
    }
  }

  // 📷 ক্যামেরা থেকে ছবি নেওয়া
  Future<void> captureImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        selectedImage.value = File(photo.path);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "ক্যামেরা থেকে ছবি তুলতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 🤖 AI ক্যাপশন জেনারেট
  Future<void> generateWithAi() async {
    String prompt = promptInputController.text.trim();
    if (prompt.isEmpty) {
      Get.snackbar(
        "Warning",
        "দয়া করে AI-এর জন্য প্রম্পট লিখুন!",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoadingAi.value = true;
      captionText.value = '';
      captionInputController.clear();

      final AuthController authController = Get.find<AuthController>();
      String token = authController.token.value;

      final response = await http.post(
        Uri.parse(
          'https://social-backend-1hwz.onrender.com/api/generate-caption',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true && data['caption'] != null) {
          String fullCaption = data['caption'].toString();

          // 🎯 টাইপিং ইফেক্ট (স্মুথ এনিমেশন)
          for (int i = 0; i < fullCaption.length; i++) {
            await Future.delayed(const Duration(milliseconds: 15));
            captionText.value += fullCaption[i];
            captionInputController.text = captionText.value;
          }

          Get.snackbar(
            "Success 🎉",
            "AI ক্যাপশন তৈরি হয়েছে!",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          "ক্যাপশন জেনারেট করতে ব্যর্থ হয়েছে (${response.statusCode})",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "নেটওয়ার্ক সমস্যা: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingAi.value = false;
    }
  }

  void regenerateWithAi() => generateWithAi();

  void clearCaption() {
    captionText.value = '';
    captionInputController.clear();
  }

  // 🚀 Neon ডাটাবেসে 'instant' মোডে সেইভ এবং Supabase Image Upload
  Future<void> publishPost() async {
    if (selectedImage.value == null) {
      Get.snackbar(
        "Warning",
        "পোস্ট করার জন্য অবশ্যই একটি ছবি তুলুন!",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedAccounts.isEmpty) {
      Get.snackbar(
        "Warning",
        "অন্তত ১টি কানেক্টেড সোশ্যাল মিডিয়া অ্যাকাউন্ট নির্বাচন করুন!",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final AuthController authController = Get.find<AuthController>();
      String token = authController.token.value;

      String finalContent = captionInputController.text.trim();
      if (hashtagInputController.text.trim().isNotEmpty) {
        finalContent += "\n\n${hashtagInputController.text.trim()}";
      }

      // 🎯 নিওন ডাটাবেসের `platforms` JSONB কলামের স্ট্রাকচার তৈরি
      Map<String, bool> platformsMap = {
        'facebook': selectedAccounts.contains('facebook'),
        'instagram': selectedAccounts.contains('instagram'),
        'linkedin': selectedAccounts.contains('linkedin'),
        'pinterest': selectedAccounts.contains('pinterest'),
        'twitter': selectedAccounts.contains('twitter'),
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://social-backend-1hwz.onrender.com/api/save-post'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // 🎯 ফর্ম ফিল্ড ডাটা
      request.fields['mode'] = 'instant';
      request.fields['content'] = finalContent;
      request.fields['platforms'] = jsonEncode(platformsMap);

      // 🎯 আলাদা কী ফিল্ড হিসেবেও পাঠানো
      request.fields['facebook'] = platformsMap['facebook'].toString();
      request.fields['instagram'] = platformsMap['instagram'].toString();
      request.fields['linkedin'] = platformsMap['linkedin'].toString();
      request.fields['pinterest'] = platformsMap['pinterest'].toString();
      request.fields['twitter'] = platformsMap['twitter'].toString();

      // 📷 ছবি আপলোড
      var multipartFile = await http.MultipartFile.fromPath(
        'images',
        selectedImage.value!.path,
      );
      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success 🎉",
          "ইনস্ট্যান্ট পোস্ট সফলভাবে নিওন ডাটাবেসে সেভ হয়েছে!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // সেভ হওয়ার পর ইনপুট রিফ্রেশ
        selectedImage.value = null;
        captionInputController.clear();
        promptInputController.clear();
        hashtagInputController.clear();
        captionText.value = '';
      } else {
        Get.snackbar(
          "Error",
          "সার্ভার সমস্যা: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "পোস্ট সেভ করতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    promptInputController.dispose();
    captionInputController.dispose();
    hashtagInputController.dispose();
    super.onClose();
  }
}
