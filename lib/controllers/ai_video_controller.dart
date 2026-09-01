import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart' as picker;
import 'package:http/http.dart' as http;
import 'accounts_view_controller.dart';
import 'auth_controller.dart';

class AiVideoController extends GetxController {
  final AccountsViewController accountsCtrl =
      Get.find<AccountsViewController>();

  String? get userToken {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().token.value;
    }
    return null;
  }

  // Input Mode: 0 = Custom Video, 1 = AI Generator
  var inputMode = 0.obs;

  // Media & AI Fields
  var selectedVideoPath = ''.obs;
  var selectedThumbnailPath = ''.obs;
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

  bool get canPost {
    bool hasPlatform =
        postToFacebook.value ||
        postToInstagram.value ||
        postToPinterest.value ||
        postToLinkedin.value ||
        postToTwitter.value ||
        postToYoutube.value;

    bool validMedia =
        inputMode.value == 1 || selectedVideoPath.value.isNotEmpty;

    bool validSchedule =
        !isScheduled.value ||
        (isScheduled.value && scheduledDateTime.value != null);

    return hasPlatform && validMedia && validSchedule;
  }

  Future<void> pickVideo() async {
    picker.FilePickerResult? result = await picker.FilePicker.pickFiles(
      type: picker.FileType.video,
    );

    if (result != null && result.files.isNotEmpty) {
      selectedVideoPath.value = result.files.single.path ?? '';
    }
  }

  void removeVideo() {
    selectedVideoPath.value = '';
  }

  Future<void> pickThumbnail() async {
    picker.FilePickerResult? result = await picker.FilePicker.pickFiles(
      type: picker.FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      selectedThumbnailPath.value = result.files.single.path ?? '';
    }
  }

  void removeThumbnail() {
    selectedThumbnailPath.value = '';
  }

  // 🤖 AI Content & Video Generator
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

      // Tab 0 (Custom Video) হলে শুধু ক্যাপশন এন্ডপয়েন্ট, Tab 1 (AI Generator) হলে ভিডিও+ক্যাপশন এন্ডপয়েন্ট
      final String backendUrl = inputMode.value == 1
          ? 'https://social-backend-1hwz.onrender.com/api/generate-video-content'
          : 'https://social-backend-1hwz.onrender.com/api/generate-caption';

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

          // AI Generator (Tab 1) মোডে জেনারেট হওয়া ভিডিও ইউআরএল/পাথ সেট করা
          if (inputMode.value == 1 && aiData['video_url'] != null) {
            selectedVideoPath.value = aiData['video_url'];
          }

          String caption = aiData['caption'] ?? '';
          String tweet = aiData['twitter_caption'] ?? caption;
          String ytTitle = aiData['youtube_title'] ?? promptText;
          String ytDesc = aiData['youtube_description'] ?? caption;
          String ytTags = aiData['youtube_tags'] ?? '';

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

  void toggleSelectAll(bool val) {
    if (accountsCtrl.isFacebookConnected.value) postToFacebook.value = val;
    if (accountsCtrl.isInstagramConnected.value) postToInstagram.value = val;
    if (accountsCtrl.isPinterestConnected.value) postToPinterest.value = val;
    if (accountsCtrl.isLinkedinConnected.value) postToLinkedin.value = val;
    if (accountsCtrl.isTwitterConnected.value) postToTwitter.value = val;
    if (accountsCtrl.isYoutubeConnected.value) postToYoutube.value = val;
  }

  void clearForm() {
    selectedVideoPath.value = '';
    selectedThumbnailPath.value = '';
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

  Future<void> submitPost() async {
    if (!canPost) return;

    isSubmitting.value = true;
    try {
      const String url =
          'https://social-backend-1hwz.onrender.com/api/save-post';
      var request = http.MultipartRequest('POST', Uri.parse(url));

      if (userToken != null && userToken!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $userToken';
      }

      if (selectedVideoPath.value.isNotEmpty) {
        if (selectedVideoPath.value.startsWith('http')) {
          request.fields['video_url'] = selectedVideoPath.value;
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'images',
              selectedVideoPath.value,
            ),
          );
        }
      }

      if (selectedThumbnailPath.value.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'youtube_thumbnail',
            selectedThumbnailPath.value,
          ),
        );
      }

      if (isScheduled.value) {
        request.fields['mode'] = 'schedule';
      } else {
        request.fields['mode'] = inputMode.value == 1 ? 'ai_agent' : 'manual';
      }

      if (isScheduled.value && scheduledDateTime.value != null) {
        request.fields['schedule_time'] = scheduledDateTime.value!
            .toIso8601String();
      }

      request.fields['content'] = captionController.text.trim();
      request.fields['twitter_caption'] = twitterCaptionController.text.trim();
      request.fields['youtube_title'] = youtubeTitleController.text.trim();
      request.fields['youtube_description'] = youtubeDescController.text.trim();
      request.fields['youtube_tags'] = youtubeTagsController.text.trim();
      request.fields['youtube_privacy'] = youtubePrivacy.value;

      request.fields['facebook'] = postToFacebook.value.toString();
      request.fields['instagram'] = postToInstagram.value.toString();
      request.fields['pinterest'] = postToPinterest.value.toString();
      request.fields['linkedin'] = postToLinkedin.value.toString();
      request.fields['twitter'] = postToTwitter.value.toString();
      request.fields['youtube'] = postToYoutube.value.toString();

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
