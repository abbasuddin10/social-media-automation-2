import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart' as picker;
import 'package:http/http.dart' as http;
import '../models/post_model.dart';
import 'accounts_view_controller.dart';
import 'auth_controller.dart';

class AiVideoController extends GetxController {
  final AccountsViewController accountsCtrl =
      Get.find<AccountsViewController>();

  // 🔑 AuthController থেকে JWT Token পাওয়ার Getter
  String? get userToken {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().token.value;
    }
    return null;
  }

  // Input Mode: 0 = Custom Media, 1 = AI Mode
  var inputMode = 0.obs;

  // Media & AI Fields
  var selectedVideoPath = ''.obs;
  var selectedThumbnailPath = ''.obs; // 🎯 YouTube Thumbnail Path
  final promptController = TextEditingController();
  final captionController = TextEditingController();
  final twitterCaptionController = TextEditingController();

  // Platform States
  var postToFacebook = false.obs;
  var postToInstagram = false.obs;
  var postToPinterest = false.obs;
  var postToLinkedin = false.obs;
  var postToTwitter = false.obs;
  var postToYoutube = false.obs;

  // YouTube Specific Fields
  final youtubeTitleController = TextEditingController();
  final youtubeDescController = TextEditingController();
  final youtubeTagsController = TextEditingController();
  var youtubePrivacy = 'public'.obs;

  // Schedule States
  var isScheduled = false.obs;
  var scheduledDateTime = Rxn<DateTime>();

  // UI Loading States
  var isGeneratingAi = false.obs;
  var isSubmitting = false.obs;

  // 🎯 Smart Validation Check
  bool get canPost {
    bool hasPlatform =
        postToFacebook.value ||
        postToInstagram.value ||
        postToPinterest.value ||
        postToLinkedin.value ||
        postToTwitter.value ||
        postToYoutube.value;

    // AI Mode (1) হলে ভিডিও বাধ্যতামূলক নয়, Custom Video (0) হলে বাধ্যতামূলক
    bool validMedia =
        inputMode.value == 1 || selectedVideoPath.value.isNotEmpty;

    bool validSchedule =
        !isScheduled.value ||
        (isScheduled.value && scheduledDateTime.value != null);

    return hasPlatform && validMedia && validSchedule;
  }

  // Pick Video File
  Future<void> pickVideo() async {
    picker.FilePickerResult? result = await picker.FilePicker.pickFiles(
      type: picker.FileType.video,
    );

    if (result != null && result.files.isNotEmpty) {
      selectedVideoPath.value = result.files.single.path ?? '';
    }
  }

  // Clear Selected Video
  void removeVideo() {
    selectedVideoPath.value = '';
  }

  // 🎯 Pick Thumbnail File
  Future<void> pickThumbnail() async {
    picker.FilePickerResult? result = await picker.FilePicker.pickFiles(
      type: picker.FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      selectedThumbnailPath.value = result.files.single.path ?? '';
    }
  }

  // 🎯 Clear Selected Thumbnail
  void removeThumbnail() {
    selectedThumbnailPath.value = '';
  }

  // 🤖 AI Content Generator (Caption + Twitter + YouTube)
  Future<Map<String, String>?> generateAiContent() async {
    String promptText = promptController.text.trim();
    if (promptText.isEmpty) {
      Get.snackbar(
        'Warning',
        'Please enter a prompt for AI generation',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return null;
    }

    try {
      isGeneratingAi.value = true;
      const String backendUrl =
          'https://social-backend-1hwz.onrender.com/api/generate-caption';

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
          if (userToken != null && userToken!.isNotEmpty)
            'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({'prompt': promptText}),
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['success'] == true && resData['data'] != null) {
          var aiData = resData['data'];

          String caption = aiData['caption'] ?? '';
          String tweet = aiData['twitter_caption'] ?? caption;
          String ytTitle = aiData['youtube_title'] ?? promptText;
          String ytDesc = aiData['youtube_description'] ?? caption;
          String ytTags = aiData['youtube_tags'] ?? '';

          // কন্ট্রোলারে ডাইনামিক ফিল-আপ
          twitterCaptionController.text = tweet;
          youtubeTitleController.text = ytTitle;
          youtubeDescController.text = ytDesc;
          youtubeTagsController.text = ytTags;

          return {'caption': caption, 'twitter_caption': tweet};
        }
      }
      Get.snackbar('Error', 'Failed to generate content');
    } catch (e) {
      Get.snackbar(
        'Connection Error',
        'Failed to connect server: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isGeneratingAi.value = false;
    }
    return null;
  }

  // Select All Platforms
  void toggleSelectAll(bool val) {
    if (accountsCtrl.isFacebookConnected.value) postToFacebook.value = val;
    if (accountsCtrl.isInstagramConnected.value) postToInstagram.value = val;
    if (accountsCtrl.isPinterestConnected.value) postToPinterest.value = val;
    if (accountsCtrl.isLinkedinConnected.value) postToLinkedin.value = val;
    if (accountsCtrl.isTwitterConnected.value) postToTwitter.value = val;
    if (accountsCtrl.isYoutubeConnected.value) postToYoutube.value = val;
  }

  // Reset Form
  void clearForm() {
    selectedVideoPath.value = '';
    selectedThumbnailPath.value = ''; // 🎯 Clear Thumbnail
    promptController.clear();
    captionController.clear();
    twitterCaptionController.clear();
    youtubeTitleController.clear();
    youtubeDescController.clear();
    youtubeTagsController.clear();
    youtubePrivacy.value = 'public';
    isScheduled.value = false;
    scheduledDateTime.value = null;
  }

  // 🎯 Submit Post Method
  Future<void> submitPost() async {
    if (!canPost) return;

    isSubmitting.value = true;
    try {
      const String url =
          'https://social-backend-1hwz.onrender.com/api/save-post';
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // 🔐 Auth Token Header
      if (userToken != null && userToken!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $userToken';
      }

      // 📁 Video File Attachment
      if (selectedVideoPath.value.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('images', selectedVideoPath.value),
        );
      }

      // 🖼️ YouTube Thumbnail Attachment
      if (selectedThumbnailPath.value.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'youtube_thumbnail',
            selectedThumbnailPath.value,
          ),
        );
      }

      // 🎯 ১. MODE পাস করুন
      if (isScheduled.value) {
        request.fields['mode'] = 'schedule';
      } else {
        request.fields['mode'] = inputMode.value == 1 ? 'ai_agent' : 'manual';
      }

      // 🎯 ২. SCHEDULE TIME পাস করুন
      if (isScheduled.value && scheduledDateTime.value != null) {
        request.fields['schedule_time'] = scheduledDateTime.value!
            .toIso8601String();
      }

      // 🎯 ৩. Text Contents
      request.fields['content'] = captionController.text.trim();
      request.fields['twitter_caption'] = twitterCaptionController.text.trim();
      request.fields['youtube_title'] = youtubeTitleController.text.trim();
      request.fields['youtube_description'] = youtubeDescController.text.trim();
      request.fields['youtube_tags'] = youtubeTagsController.text.trim();
      request.fields['youtube_privacy'] =
          youtubePrivacy.value; // 🎯 Privacy Pass

      // 🎯 ৪. Platforms
      request.fields['facebook'] = postToFacebook.value.toString();
      request.fields['instagram'] = postToInstagram.value.toString();
      request.fields['pinterest'] = postToPinterest.value.toString();
      request.fields['linkedin'] = postToLinkedin.value.toString();
      request.fields['twitter'] = postToTwitter.value.toString();
      request.fields['youtube'] = postToYoutube.value.toString();

      // 🚀 Send Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Post saved/scheduled successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        clearForm();
      } else {
        Get.snackbar(
          'Error',
          'Upload failed: ${response.body}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to publish post: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    promptController.dispose();
    captionController.dispose();
    twitterCaptionController.dispose();
    youtubeTitleController.dispose();
    youtubeDescController.dispose();
    youtubeTagsController.dispose();
    super.onClose();
  }
}
