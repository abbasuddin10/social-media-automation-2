import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'auth_controller.dart'; // 👈 AuthController ইম্পোর্ট

class AutomationController extends GetxController {
  // ইনপুট কন্ট্রোলারে বাকি বিষয় অপরিবর্তিত...
  final aiPromptController = TextEditingController();
  final manualPromptController = TextEditingController();
  final schedulePromptController = TextEditingController();

  var selectedTab = 0.obs;
  var isLoading = false.obs;
  var selectAll = false.obs;

  var postToFacebook = true.obs;
  var postToInstagram = false.obs;
  var postToPinterest = false.obs;

  var scheduleTime = TimeOfDay.now().obs;
  var uploadedImages = <String>[].obs;

  void toggleSelectAll(bool val) {
    selectAll.value = val;
    postToFacebook.value = val;
    postToInstagram.value = val;
    postToPinterest.value = val;
  }

  Future<void> pickScheduleTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: scheduleTime.value,
    );

    if (picked != null) {
      scheduleTime.value = picked;
    }
  }

  void pickMultipleImages() async {
    final ImagePicker picker = ImagePicker();

    try {
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        uploadedImages.addAll(images.map((e) => e.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'ছবি সিলেক্ট করতে সমস্যা হয়েছে: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeImage(int index) {
    uploadedImages.removeAt(index);
  }

  void askGeminiForHelp() async {
    String query = manualPromptController.text.trim();

    if (query.isEmpty) {
      Get.snackbar(
        'Error',
        'দয়া করে কিছু লিখে তারপর জেমিনি এজেন্টের সাহায্য নিন!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    manualPromptController.text =
        "✨ [Gemini AI Generated]: $query সম্পর্কিত আকর্ষণীয় ক্যাপশন...";
  }

  // ব্যাকএন্ড এবং n8n-এ ডাটা সাবমিট করার মূল ফাংশন (JWT সিকিউরড)
  void submitData() async {
    try {
      isLoading.value = true;

      // 🛡️ AuthController থেকে JWT টোকেন নেওয়া
      final AuthController authController = Get.find<AuthController>();
      String token = authController.token.value;

      // কোন ট্যাব সিলেক্ট করা আছে তার ওপর ভিত্তি করে মোড নির্ধারণ
      String mode = 'manual';
      String promptText = '';

      if (selectedTab.value == 0) {
        mode = 'ai_agent';
        promptText = aiPromptController.text;
      } else if (selectedTab.value == 1) {
        mode = 'manual';
        promptText = manualPromptController.text;
      } else {
        mode = 'schedule';
        promptText = schedulePromptController.text;
      }

      // মাল্টিপার্ট রিকোয়েস্ট তৈরি
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://social-backend-1hwz.onrender.com/api/save-post'),
      );

      // 🛡️ হেডারে JWT টোকেন যুক্ত করা (হার্ডকোডেড user_id বাদ দেওয়া হয়েছে)
      request.headers['Authorization'] = 'Bearer $token';

      // টেক্সট ফিল্ডগুলো যোগ করা
      request.fields['mode'] = mode;
      request.fields['content'] = promptText;
      request.fields['facebook'] = postToFacebook.value.toString();
      request.fields['instagram'] = postToInstagram.value.toString();
      request.fields['pinterest'] = postToPinterest.value.toString();

      if (selectedTab.value == 2) {
        request.fields['schedule_time'] = scheduleTime.value.format(
          Get.context!,
        );
      }

      // ইমেজ ফাইলগুলো যোগ করা
      for (var path in uploadedImages) {
        var file = File(path);

        var multipartFile = await http.MultipartFile.fromPath(
          'images',
          file.path,
        );

        request.files.add(multipartFile);
      }

      // সার্ভারে পাঠানো
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "ছবি ও কন্টেন্ট সফলভাবে আপলোড হয়েছে!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // ফর্ম ক্লিয়ার করা
        aiPromptController.clear();
        manualPromptController.clear();
        schedulePromptController.clear();
        uploadedImages.clear();
      } else {
        Get.snackbar(
          "Error",
          "সার্ভার এরর: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "ফাইল পাঠাতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
