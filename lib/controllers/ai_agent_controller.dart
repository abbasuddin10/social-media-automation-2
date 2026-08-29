import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth_controller.dart';

class AIAgentController extends GetxController {
  // 🎯 Input & States
  final aiPromptController = TextEditingController();
  var isAnalyzing = false.obs;
  var isLoading = false.obs;
  var isFetchingPosts = false.obs;

  var generatedRule = {}.obs;
  var scheduledPosts = <dynamic>[].obs; // ডাটাবেসে থাকা সব পোস্টের লিস্ট

  @override
  void onInit() {
    super.onInit();
    fetchAllScheduledPosts(); // স্ক্রিন ওপেন হলেই সব পোস্ট লোড হবে
  }

  // 🔄 ১. ডাটাবেস থেকে সব পেন্ডিং পোস্ট ফেচ করা
  Future<void> fetchAllScheduledPosts() async {
    try {
      isFetchingPosts.value = true;
      final AuthController authController = Get.find<AuthController>();
      String token = authController.token.value;

      final response = await http.get(
        // 👈 URL-এর শেষে ?mode=ai_agent যোগ করা হয়েছে
        Uri.parse(
          'https://social-backend-1hwz.onrender.com/api/get-scheduled-posts?mode=ai_agent',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true) {
          scheduledPosts.assignAll(data['posts']); // ডাটা আপডেট করা
        }
      } else {
        debugPrint("Fetch Error Code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      isFetchingPosts.value = false;
    }
  }

  // 🤖 ২. AI Agent Instruction Parser
  Future<void> processUserInstruction(String userPrompt) async {
    if (userPrompt.trim().isEmpty) {
      Get.snackbar(
        'Warning',
        'দয়া করে এআই এজেন্টের জন্য কিছু নির্দেশ লিখুন',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isAnalyzing.value = true;
      final AuthController authController = Get.find<AuthController>();
      String token = authController.token.value;

      final response = await http.post(
        Uri.parse(
          'https://social-backend-1hwz.onrender.com/api/generate-user-plan',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'user_prompt': userPrompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          generatedRule.value = data['plan'];
        } else {
          Get.snackbar('Error', 'প্ল্যান তৈরি করা সম্ভব হয়নি');
        }
      } else {
        Get.snackbar(
          'Error',
          'সার্ভারে সমস্যা হয়েছে (${response.statusCode})',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Connection Error',
        'সার্ভারের সাথে যোগাযোগ করা যাচ্ছে না: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isAnalyzing.value = false;
    }
  }

  // 💾 ৩. AI Agent Plan Save / Bulk Delete (ai_agent_controller.dart)
  Future<void> savePlanToDB() async {
    if (generatedRule.isEmpty) return;

    try {
      final AuthController authController = Get.find<AuthController>();
      String token = authController.token.value;

      String intent = (generatedRule['intent'] ?? '').toString().toUpperCase();
      bool isDeleteAction =
          generatedRule['is_delete'] == true ||
          intent.contains('DELETE') ||
          intent.contains('CLEAR') ||
          intent.contains('REMOVE') ||
          intent.contains('CANCEL');

      // 🗑️ ডিলিট ইন্টেন্ট শনাক্ত হলে পপ-আপ দেখাবে
      if (isDeleteAction) {
        String dialogMessage =
            "আপনি কি নিশ্চিত? এটি আপনার সকল শিডিউল পোস্ট স্থায়ীভাবে মুছে ফেলবে!";

        if (generatedRule['delete_scope'] == 'SPECIFIC_DATE' &&
            generatedRule['target_date'] != null) {
          dialogMessage =
              "আপনি কি নিশ্চিত? ${generatedRule['target_date']} তারিখের শিডিউল পোস্টটি মুছে ফেলা হবে!";
        }

        Get.defaultDialog(
          title: "⚠️ ডিলিট কনফার্মেশন",
          titleStyle: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 10.0,
            ),
            child: Text(
              dialogMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          textConfirm: "হ্যাঁ, ডিলিট করুন",
          textCancel: "বাতিল",
          confirmTextColor: Colors.white,
          buttonColor: Colors.red,
          cancelTextColor: Colors.black,
          onConfirm: () async {
            Get.back(); // ডায়ালগ বন্ধ করবে

            try {
              isLoading.value = true;
              final response = await http.delete(
                Uri.parse(
                  'https://social-backend-1hwz.onrender.com/api/delete-all-posts',
                ),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
              );

              if (response.statusCode == 200) {
                Get.snackbar(
                  "Deleted 🎉",
                  "আপনার নির্দেশ অনুযায়ী পোস্ট সফলভাবে মুছে ফেলা হয়েছে!",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );

                generatedRule.clear();
                aiPromptController.clear();
                fetchAllScheduledPosts();
              } else {
                Get.snackbar(
                  "Error",
                  "ডিলিট করতে সমস্যা হয়েছে: ${response.statusCode}",
                );
              }
            } catch (e) {
              Get.snackbar(
                "Error",
                "সার্ভার সমস্যা: $e",
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            } finally {
              isLoading.value = false;
            }
          },
        );
        return;
      }

      // 📝 পোস্ট সেভ/আপডেট করার লজিক (Create/Update Posts)
      isLoading.value = true;
      List posts = generatedRule['posts'] ?? [];
      if (posts.isEmpty) {
        Get.snackbar(
          "Warning",
          "সেভ করার মতো কোনো পোস্ট নেই!",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      final response = await http.post(
        Uri.parse(
          'https://social-backend-1hwz.onrender.com/api/confirm-save-plan',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'posts': posts}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = jsonDecode(response.body);
        Get.snackbar(
          "Success 🎉",
          data['message'] ?? "পোস্টগুলো সফলভাবে প্রসেস করা হয়েছে!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        generatedRule.clear();
        aiPromptController.clear();
        fetchAllScheduledPosts();
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "সার্ভার সমস্যা: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (generatedRule['is_delete'] != true) {
        isLoading.value = false;
      }
    }
  }

  // 🗑️ ৪. একক কোনো পোস্ট ডাটাবেস থেকে ডিলিট করা (পপ-আপ সহ)
  Future<void> deleteSinglePost(dynamic postId) async {
    Get.defaultDialog(
      title: "⚠️ নিশ্চিতকরণ",
      titleStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      middleText: "আপনি কি নিশ্চিত যে এই পোস্টটি মুছে ফেলতে চান?",
      middleTextStyle: const TextStyle(fontSize: 14),
      textConfirm: "হ্যাঁ, ডিলিট করুন",
      textCancel: "বাতিল",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.black,
      onConfirm: () async {
        Get.back(); // ডায়ালগ বন্ধ করবে

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
            Get.snackbar(
              "Deleted",
              "পোস্টটি ডাটাবেস থেকে মুছে ফেলা হয়েছে",
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
            fetchAllScheduledPosts(); // রিফ্রেশ
          } else {
            Get.snackbar(
              "Error",
              "ডিলিট হতে ব্যর্থ হয়েছে (${response.statusCode})",
            );
          }
        } catch (e) {
          debugPrint("Delete Error: $e");
        }
      },
    );
  }

  // ✏️ ৫. কোনো পোস্ট ডাটাবেসে এডিট/আপডেট করা
  Future<void> updateSinglePost({
    required dynamic postId,
    required String updatedContent,
    List<String>? platforms,
    String? scheduledAt,
  }) async {
    try {
      final AuthController authController = Get.find<AuthController>();
      String token = authController.token.value;

      final response = await http.put(
        Uri.parse(
          'https://social-backend-1hwz.onrender.com/api/update-post/$postId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'content': updatedContent,
          if (platforms != null) 'target_platforms': platforms,
          if (scheduledAt != null) 'scheduled_at': scheduledAt,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "Updated 🎉",
          "পোস্টটি সফলভাবে আপডেট করা হয়েছে",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        fetchAllScheduledPosts(); // ডাটা রিফ্রেশ
      } else {
        Get.snackbar(
          "Error",
          "আপডেট হতে ব্যর্থ হয়েছে (${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  @override
  void onClose() {
    aiPromptController.dispose();
    super.onClose();
  }
}
