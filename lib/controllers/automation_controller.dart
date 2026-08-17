import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'auth_controller.dart';

class AutomationController extends GetxController {
  final aiPromptController = TextEditingController();
  final manualPromptController = TextEditingController();
  final schedulePromptController = TextEditingController();

  var selectedTab = 0.obs;
  var isLoading = false.obs;
  var selectAll = false.obs;

  var postToFacebook = true.obs;
  var postToInstagram = false.obs;
  var postToPinterest = false.obs;

  var uploadedImages = <String>[].obs;
  var selectedTemplateIndex = (-1).obs;
  var selectedTime = Rxn<TimeOfDay>();

  void toggleSelectAll(bool val) {
    selectAll.value = val;
    postToFacebook.value = val;
    postToInstagram.value = val;
    postToPinterest.value = val;
  }

  void applyQuickTemplate(String text) {
    schedulePromptController.text = text;
    selectedTemplateIndex.value = -1;
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

  void submitData() async {
    try {
      if (selectedTab.value == 2 && selectedTime.value == null) {
        Get.snackbar(
          'Error',
          'দয়া করে শিডিউল পোস্টের জন্য টাইম সিলেক্ট করুন!',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      final AuthController authController = Get.find<AuthController>();
      String token = authController.token.value;

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

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://social-backend-1hwz.onrender.com/api/save-post'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['mode'] = mode;
      request.fields['content'] = promptText;
      request.fields['facebook'] = postToFacebook.value.toString();
      request.fields['instagram'] = postToInstagram.value.toString();
      request.fields['pinterest'] = postToPinterest.value.toString();

      // শিডিউল মোডে সঠিক ISO DateTime ফরম্যাট হিসাব করে পাঠানো
      if (selectedTab.value == 2 && selectedTime.value != null) {
        DateTime now = DateTime.now();
        DateTime scheduleDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          selectedTime.value!.hour,
          selectedTime.value!.minute,
        );

        if (scheduleDateTime.isBefore(now)) {
          scheduleDateTime = scheduleDateTime.add(const Duration(days: 1));
        }

        request.fields['schedule_time'] = scheduleDateTime.toIso8601String();
      }

      for (var path in uploadedImages) {
        var file = File(path);
        var multipartFile = await http.MultipartFile.fromPath(
          'images',
          file.path,
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          selectedTab.value == 2
              ? "পরপর ${uploadedImages.length > 0 ? uploadedImages.length : 1} দিনের পোস্ট সফলভাবে শিডিউল হয়েছে!"
              : "পোস্ট সফলভাবে তৈরি হয়েছে!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        aiPromptController.clear();
        manualPromptController.clear();
        schedulePromptController.clear();
        uploadedImages.clear();
        selectedTime.value = null;
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
