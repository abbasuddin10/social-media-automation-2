import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'auth_controller.dart';

class AutomationController extends GetxController {
  final aiPromptController = TextEditingController();
  final aiGeneratedCaptionController =
      TextEditingController(); // 🎯 AI Generated Editable Caption
  final manualPromptController = TextEditingController();
  final schedulePromptController = TextEditingController();
  final TextEditingController promptController = TextEditingController();
  var selectedImages = <File>[].obs;

  var selectedTab = 0.obs;
  var isLoading = false.obs;
  var isGeneratingAi = false.obs; // 🎯 AI Loading State
  var isAiCaptionGenerated = false.obs; // 🎯 Preview Visibility
  var selectAll = false.obs;

  var postToFacebook = true.obs;
  var postToInstagram = false.obs;
  var postToPinterest = false.obs;

  var uploadedImages = <String>[].obs;
  var selectedTemplateIndex = (-1).obs;
  var selectedTime = Rxn<TimeOfDay>();

  // 🎯 Gemini API দিয়ে ক্যাপশন জেনারেট করার ফাংশন
  Future<String?> generateAiCaption(String prompt) async {
    try {
      final AuthController authController = Get.find<AuthController>();
      String? token = authController.token.value;

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
        if (data['success'] == true) {
          return data['caption'];
        }
      } else {
        debugPrint("API Error: ${response.body}");
      }
    } catch (e) {
      debugPrint("AI Generation Error: $e");
    }
    return null;
  }

  // 🎯 AI Agent ট্যাবে প্রিভিউ ক্যাপশন আনার হ্যান্ডলার
  Future<void> handleAiPreviewGeneration() async {
    String prompt = aiPromptController.text.trim();
    if (prompt.isEmpty) {
      Get.snackbar(
        "Warning",
        "দয়া করে পোস্টের বিষয় বা প্রম্পট লিখুন!",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isGeneratingAi.value = true;
    String? caption = await generateAiCaption(prompt);
    isGeneratingAi.value = false;

    if (caption != null) {
      aiGeneratedCaptionController.text = caption;
      isAiCaptionGenerated.value = true;
      Get.snackbar(
        "Success 🎉",
        "AI ক্যাপশন তৈরি হয়েছে! প্রয়োজনে নিচে এডিট করে নিন।",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Error",
        "ক্যাপশন জেনারেট করতে ব্যর্থ হয়েছে!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 🎯 টেমপ্লেট পোস্ট ব্যাকএন্ডে সাবমিট করার জন্য
  Future<bool> publishTemplatePost({
    required File imageFile,
    required String mode,
    required String content,
    required bool facebook,
    required bool instagram,
    required bool pinterest,
  }) async {
    try {
      isLoading.value = true;
      final AuthController authController = Get.find<AuthController>();
      String token = authController.token.value;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://social-backend-1hwz.onrender.com/api/save-post'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['mode'] = (mode == 'ai' || mode == 'ai_agent')
          ? 'ai_agent'
          : 'manual';

      request.fields['content'] = content;
      request.fields['facebook'] = facebook.toString();
      request.fields['instagram'] = instagram.toString();
      request.fields['pinterest'] = pinterest.toString();

      var multipartFile = await http.MultipartFile.fromPath(
        'images',
        imageFile.path,
      );
      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success 🎉",
          "পোস্ট প্রসেসিংয়ের জন্য n8n অটোমেশনে পাঠানো হয়েছে!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          "Error",
          "সার্ভার এরর: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "পোস্ট পাঠাতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

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

    String? aiCaption = await generateAiCaption(query);
    if (aiCaption != null) {
      manualPromptController.text = aiCaption;
    } else {
      manualPromptController.text =
          "✨ [Gemini AI Generated]: $query সম্পর্কিত আকর্ষণীয় ক্যাপশন...";
    }
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
        mode =
            'manual'; // ✅ ম্যানুয়াল মোড দিলে n8n আর ব্যাকএন্ডে AI চালাবে না, সরাসরি অ্যাপের রেডি টেক্সট পোস্ট করে দেবে
        promptText =
            isAiCaptionGenerated.value &&
                aiGeneratedCaptionController.text.trim().isNotEmpty
            ? aiGeneratedCaptionController.text
            : aiPromptController.text;
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
        aiGeneratedCaptionController.clear();
        isAiCaptionGenerated.value = false;
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
