import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'auth_controller.dart';

class AutomationController extends GetxController {
  // 🎯 Text Editing Controllers
  final aiPromptController = TextEditingController();
  final aiGeneratedCaptionController = TextEditingController();
  final manualPromptController = TextEditingController();
  final schedulePromptController = TextEditingController();
  final promptController = TextEditingController();

  // 🎯 Observable Variables
  var isAnalyzing = false.obs;
  var generatedRule = {}.obs;
  var selectedImages = <File>[].obs;

  var selectedTab = 0.obs;
  var isLoading = false.obs;
  var isGeneratingAi = false.obs;
  var isAiCaptionGenerated = false.obs;
  var selectAll = false.obs;

  var postToFacebook = true.obs;
  var postToInstagram = false.obs;
  var postToPinterest = false.obs;

  var uploadedImages = <String>[].obs;
  var selectedTemplateIndex = (-1).obs;
  var selectedTime = Rxn<TimeOfDay>();
  var scheduledOnlyPosts = <dynamic>[].obs;
  var isFetchingSchedule = false.obs;

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
        "দয়া করে পোস্টের বিষয় বা প্রম্পট লিখুন!",
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
        "AI ক্যাপশন তৈরি হয়েছে! প্রয়োজনে নিচে এডিট করে নিন।",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Error",
        "ক্যাপশন জেনারেট করতে ব্যর্থ হয়েছে!",
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
        "পোস্ট পাঠাতে সমস্যা হয়েছে: $e",
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
        'ছবি সিলেক্ট করতে সমস্যা হয়েছে: $e',
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
        'দয়া করে কিছু লিখে তারপর জেমিনি এজেন্টের সাহায্য নিন!',
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
          "✨ [Gemini AI Generated]: $query সম্পর্কিত আকর্ষণীয় ক্যাপশন...";
    }
  }

  void submitData() async {
    try {
      if (selectedTab.value == 3 && selectedTime.value == null) {
        Get.snackbar(
          'Error',
          'দয়া করে শিডিউল পোস্টের জন্য টাইম সিলেক্ট করুন!',
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

      if (selectedTab.value == 1) {
        mode = 'ai_caption';
        promptText =
            isAiCaptionGenerated.value &&
                aiGeneratedCaptionController.text.trim().isNotEmpty
            ? aiGeneratedCaptionController.text
            : aiPromptController.text;
      } else if (selectedTab.value == 2) {
        mode = 'manual';
        promptText = manualPromptController.text;
      } else if (selectedTab.value == 3) {
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

      if (selectedTab.value == 3 && selectedTime.value != null) {
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
          selectedTab.value == 3
              ? "পরপর ${uploadedImages.isNotEmpty ? uploadedImages.length : 1} দিনের পোস্ট সফলভাবে শিডিউল হয়েছে!"
              : "পোস্ট সফলভাবে তৈরি হয়েছে!",
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

        fetchScheduleOnlyPosts();
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
        "ফাইল পাঠাতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchScheduleOnlyPosts() async {
    try {
      isFetchingSchedule.value = true;
      final AuthController authController = Get.find<AuthController>();
      String token = authController.token.value;

      final response = await http.get(
        Uri.parse(
          'https://social-backend-1hwz.onrender.com/api/get-scheduled-posts?mode=schedule',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true) {
          scheduledOnlyPosts.assignAll(data['posts']);
        }
      }
    } catch (e) {
      debugPrint("Schedule Fetch Error: $e");
    } finally {
      isFetchingSchedule.value = false;
    }
  }

  // 🎯 পোস্ট ডিলিট করার মেথড
  Future<void> deleteScheduledPost(dynamic postId) async {
    try {
      final AuthController authController = Get.find<AuthController>();
      String token = authController.token.value;

      final response = await http.delete(
        Uri.parse(
          'https://social-backend-1hwz.onrender.com/api/delete-post/$postId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        scheduledOnlyPosts.removeWhere((post) => post['id'] == postId);

        Get.snackbar(
          "Deleted 🎉",
          "পোস্টটি ডাটাবেস থেকে সফলভাবে মুছে ফেলা হয়েছে!",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "পোস্ট ডিলিট করতে ব্যর্থ হয়েছে: ${response.statusCode}",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "নেটওয়ার্ক সমস্যা: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 🎯 পোস্ট আপডেট করার মেথড
  Future<void> updateScheduledPost({
    required dynamic postId,
    required String content,
    List<File>? newImages,
  }) async {
    try {
      isLoading.value = true;
      final AuthController authController = Get.find<AuthController>();
      String token = authController.token.value;

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(
          'https://social-backend-1hwz.onrender.com/api/update-post/$postId',
        ),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['content'] = content;

      if (newImages != null && newImages.isNotEmpty) {
        for (var file in newImages) {
          var multipartFile = await http.MultipartFile.fromPath(
            'images',
            file.path,
          );
          request.files.add(multipartFile);
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success 🎉",
          "পোস্ট সফলভাবে আপডেট হয়েছে!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchScheduleOnlyPosts();
      } else {
        Get.snackbar(
          "Error",
          "আপডেট করতে ব্যর্থ হয়েছে: ${response.statusCode}",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "নেটওয়ার্ক সমস্যা: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🎯 Schedule Preview Data Model/List
  var scheduledPreviewList = <Map<String, dynamic>>[].obs;
  var isGeneratingScheduleCaptions = false.obs;

  // 🎯 ছবির জন্য AI ক্যাপশন জেনারেট করার মেথড
  Future<void> generateSchedulePreviewList() async {
    String basePrompt = schedulePromptController.text.trim();

    if (basePrompt.isEmpty) {
      Get.snackbar(
        "Warning",
        "দয়া করে পোস্টের প্রম্পট বা বিবরণ লিখুন!",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    if (selectedTime.value == null) {
      Get.snackbar(
        "Warning",
        "দয়া করে দৈনিক পোস্ট করার সময় (Time) সিলেক্ট করুন!",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    if (uploadedImages.isEmpty) {
      Get.snackbar(
        "Warning",
        "দয়া করে অন্তত ১টি ছবি যুক্ত করুন!",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isGeneratingScheduleCaptions.value = true;

      // পূর্বের লিস্টের টেক্সট কন্ট্রোলারগুলো সঠিকভাবে ডিসপোজ করা
      _clearScheduledPreviewList();

      DateTime now = DateTime.now();

      for (int i = 0; i < uploadedImages.length; i++) {
        String imagePath = uploadedImages[i];

        String prompt =
            "$basePrompt (Generate a unique engaging caption for Day ${i + 1} post)";
        String? generatedCaption = await generateAiCaption(prompt);

        DateTime scheduleDateTime = DateTime(
          now.year,
          now.month,
          now.day + i,
          selectedTime.value!.hour,
          selectedTime.value!.minute,
        );

        scheduledPreviewList.add({
          'day': i + 1,
          'imagePath': imagePath,
          'captionController': TextEditingController(
            text: generatedCaption ?? basePrompt,
          ),
          'scheduleTime': scheduleDateTime,
        });
      }

      Get.snackbar(
        "Success 🎉",
        "সবগুলো ছবির জন্য AI ক্যাপশন তৈরি হয়েছে! নিচে প্রিভিউ দেখুন।",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "ক্যাপশন জেনারেট করতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isGeneratingScheduleCaptions.value = false;
    }
  }

  // 🎯 প্রিভিউ সেভ করার মেথড
  Future<void> confirmAndSaveSchedulePosts() async {
    if (scheduledPreviewList.isEmpty) return;

    try {
      isLoading.value = true;
      final AuthController authController = Get.find<AuthController>();
      String token = authController.token.value;

      for (var item in scheduledPreviewList) {
        TextEditingController controller = item['captionController'];
        String finalCaption = controller.text.trim();
        DateTime scheduleTime = item['scheduleTime'];
        String imagePath = item['imagePath'];

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://social-backend-1hwz.onrender.com/api/save-post'),
        );

        request.headers['Authorization'] = 'Bearer $token';
        request.fields['mode'] = 'schedule';
        request.fields['content'] = finalCaption;
        request.fields['facebook'] = postToFacebook.value.toString();
        request.fields['instagram'] = postToInstagram.value.toString();
        request.fields['pinterest'] = postToPinterest.value.toString();
        request.fields['schedule_time'] = scheduleTime.toIso8601String();

        var multipartFile = await http.MultipartFile.fromPath(
          'images',
          imagePath,
        );
        request.files.add(multipartFile);

        var streamedResponse = await request.send();
        await http.Response.fromStream(streamedResponse);
      }

      Get.snackbar(
        "Success 🎉",
        "সকল শিডিউল পোস্ট ডাটাবেসে সফলভাবে সেভ করা হয়েছে!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // রিসেট ও রিফ্রেশ
      schedulePromptController.clear();
      uploadedImages.clear();
      _clearScheduledPreviewList();
      selectedTime.value = null;

      fetchScheduleOnlyPosts();
    } catch (e) {
      Get.snackbar(
        "Error",
        "সেভ করতে সমস্যা হয়েছে: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🎯 অভ্যন্তরীণ মেমোরি ক্লিনআপ ফাংশন
  void _clearScheduledPreviewList() {
    for (var item in scheduledPreviewList) {
      if (item['captionController'] is TextEditingController) {
        (item['captionController'] as TextEditingController).dispose();
      }
    }
    scheduledPreviewList.clear();
  }

  @override
  void onClose() {
    aiPromptController.dispose();
    aiGeneratedCaptionController.dispose();
    manualPromptController.dispose();
    schedulePromptController.dispose();
    promptController.dispose();
    _clearScheduledPreviewList();
    super.onClose();
  }
}
