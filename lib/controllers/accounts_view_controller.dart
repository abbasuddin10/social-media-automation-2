import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_automation/controllers/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountsViewController extends GetxController
    with WidgetsBindingObserver {
  // সোশ্যাল মিডিয়াগুলোর কানেকশন স্ট্যাটাস
  var isFacebookConnected = false.obs;
  var isInstagramConnected = false.obs;
  var isYoutubeConnected = false.obs;
  var isTiktokConnected = false.obs;
  var isPinterestConnected = false.obs;
  var isLinkedinConnected = false.obs;
  var isWhatsappConnected = false.obs;
  var isTwitterConnected = false.obs;

  // সোশ্যাল মিডিয়া প্রোফাইল নেম
  var facebookPageName = ''.obs;
  var instagramPageName = ''.obs;
  var linkedinProfileName = ''.obs;
  var youtubeChannelName = ''.obs;
  var whatsappNumber = ''.obs;
  var twitterProfileName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchConnectionStatus();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchConnectionStatus();
    }
  }

  String _getUserId() {
    if (Get.isRegistered<AuthController>()) {
      final controller = Get.find<AuthController>();
      if (controller.userId.value.isNotEmpty) {
        return controller.userId.value;
      }
    }
    return '';
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> fetchConnectionStatus() async {
    try {
      var userId = _getUserId();

      if (userId.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getString('userId') ?? '';
        if (Get.isRegistered<AuthController>()) {
          Get.find<AuthController>().userId.value = userId;
        }
      }

      if (userId.isEmpty) return;

      final response = await http.get(
        Uri.parse(
          'https://social-backend-1hwz.onrender.com/user/accounts?user_id=$userId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<String> connectedPlatforms = [];

        facebookPageName.value = '';
        instagramPageName.value = '';
        linkedinProfileName.value = '';
        youtubeChannelName.value = '';
        whatsappNumber.value = '';
        twitterProfileName.value = '';

        List accountsList = [];
        if (data is Map && data.containsKey('accounts')) {
          accountsList = data['accounts'] ?? [];
        } else if (data is List) {
          accountsList = data;
        }

        for (var item in accountsList) {
          if (item is Map) {
            String platform =
                item['platform']?.toString().toLowerCase().trim() ?? '';
            connectedPlatforms.add(platform);

            if (platform == 'facebook' && item['page_name'] != null) {
              facebookPageName.value = item['page_name'].toString();
            }
            if (platform == 'instagram' && item['page_name'] != null) {
              instagramPageName.value = item['page_name'].toString();
            }
            if (platform == 'linkedin' && item['page_name'] != null) {
              linkedinProfileName.value = item['page_name'].toString();
            }
            if (platform == 'youtube' && item['page_name'] != null) {
              youtubeChannelName.value = item['page_name'].toString();
            }
            if (platform == 'whatsapp' && item['page_name'] != null) {
              whatsappNumber.value = item['page_name'].toString();
            }
            if ((platform == 'twitter' || platform == 'x') &&
                item['page_name'] != null) {
              twitterProfileName.value = item['page_name'].toString();
            }
          } else if (item is String) {
            connectedPlatforms.add(item.toLowerCase().trim());
          }
        }

        isFacebookConnected.value = connectedPlatforms.contains('facebook');
        isInstagramConnected.value = connectedPlatforms.contains('instagram');
        isYoutubeConnected.value = connectedPlatforms.contains('youtube');
        isTiktokConnected.value = connectedPlatforms.contains('tiktok');
        isPinterestConnected.value = connectedPlatforms.contains('pinterest');
        isLinkedinConnected.value = connectedPlatforms.contains('linkedin');
        isWhatsappConnected.value = connectedPlatforms.contains('whatsapp');
        isTwitterConnected.value =
            connectedPlatforms.contains('twitter') ||
            connectedPlatforms.contains('x');

        _refreshAllStates();
      }
    } catch (e) {
      debugPrint('Error fetching status: $e');
    }
  }

  Future<void> connectFacebook() async {
    var userId = _getUserId();
    if (userId.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';
    }

    if (userId.isEmpty) {
      Get.snackbar('এরর', 'ইউজার আইডি পাওয়া যায়নি! অনুগ্রহ করে লগইন করুন।');
      return;
    }

    final url = Uri.parse(
      'https://social-backend-1hwz.onrender.com/auth/facebook?user_id=$userId',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> connectLinkedin() async {
    var userId = _getUserId();
    if (userId.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';
    }

    if (userId.isEmpty) {
      Get.snackbar('এরর', 'ইউজার আইডি পাওয়া যায়নি! অনুগ্রহ করে লগইন করুন।');
      return;
    }

    final url = Uri.parse(
      'https://social-backend-1hwz.onrender.com/auth/linkedin?user_id=$userId',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> connectYoutube() async {
    var userId = _getUserId();
    if (userId.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';
    }

    if (userId.isEmpty) {
      Get.snackbar('এরর', 'ইউজার আইডি পাওয়া যায়নি! অনুগ্রহ করে লগইন করুন।');
      return;
    }

    final url = Uri.parse(
      'https://social-backend-1hwz.onrender.com/auth/youtube?user_id=$userId',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> connectTwitter() async {
    var userId = _getUserId();
    if (userId.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';
    }

    if (userId.isEmpty) {
      Get.snackbar('এরর', 'ইউজার আইডি পাওয়া যায়নি! অনুগ্রহ করে লগইন করুন।');
      return;
    }

    final url = Uri.parse(
      'https://social-backend-1hwz.onrender.com/auth/twitter?user_id=$userId',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void showWhatsappDialog() {
    final TextEditingController phoneController = TextEditingController(
      text: whatsappNumber.value,
    );

    Get.defaultDialog(
      title: 'WhatsApp Connect',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            const Text(
              'আপনার হোয়াটসঅ্যাপ নম্বরটি কান্ট্রি কোডসহ লিখুন (যেমন: 8801712345678)',
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'WhatsApp Number',
                hintText: '88017xxxxxxxx',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
      ),
      textConfirm: 'Save & Connect',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () async {
        final phone = phoneController.text.trim();
        if (phone.isEmpty) {
          Get.snackbar(
            'ত্রুটি',
            'অনুগ্রহ করে একটি সঠিক হোয়াটসঅ্যাপ নম্বর দিন!',
          );
          return;
        }
        Get.back();
        await updateWhatsappNumber(phone);
      },
    );
  }

  Future<void> updateWhatsappNumber(String phone) async {
    try {
      final token = await _getToken();
      if (token.isEmpty) {
        Get.snackbar(
          'ত্রুটি',
          'অথেন্টিকেশন টোকেন পাওয়া যায়নি! আবার লগইন করুন।',
        );
        return;
      }

      final response = await http.post(
        Uri.parse(
          'https://social-backend-1hwz.onrender.com/api/user/update-whatsapp',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'whatsappNumber': phone}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        isWhatsappConnected.value = true;
        whatsappNumber.value = phone;
        Get.snackbar(
          'সফল',
          'WhatsApp অ্যাকাউন্ট সফলভাবে সংযুক্ত করা হয়েছে!',
          backgroundColor: Colors.green.shade100,
        );
        fetchConnectionStatus();
      } else {
        Get.snackbar(
          'ত্রুটি',
          data['message'] ?? 'হোয়াটসঅ্যাপ আপডেট করতে সমস্যা হয়েছে!',
        );
      }
    } catch (e) {
      debugPrint('WhatsApp Update Error: $e');
      Get.snackbar('ত্রুটি', 'নেটওয়ার্ক কানেকশনে সমস্যা হয়েছে!');
    }
  }

  void confirmDisconnect(String platform, String platformName) {
    Get.defaultDialog(
      title: 'কনফার্মেশন',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      middleText: 'আপনি কি নিশ্চিত যে $platformName ডিসকানেক্ট করতে চান?',
      textConfirm: 'হ্যাঁ, ডিসকানেক্ট করুন',
      textCancel: 'বাতিল',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.black,
      onConfirm: () {
        Get.back();
        disconnectPlatform(platform, platformName);
      },
    );
  }

  Future<void> disconnectPlatform(String platform, String platformName) async {
    try {
      var userId = _getUserId();
      if (userId.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getString('userId') ?? '';
      }

      if (userId.isEmpty) return;

      final response = await http.post(
        Uri.parse('https://social-backend-1hwz.onrender.com/auth/disconnect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'platform': platform}),
      );

      if (response.statusCode == 200) {
        toggleConnection(platform, false);
        if (platform == 'facebook') facebookPageName.value = '';
        if (platform == 'instagram') instagramPageName.value = '';
        if (platform == 'linkedin') linkedinProfileName.value = '';
        if (platform == 'youtube') youtubeChannelName.value = '';
        if (platform == 'whatsapp') whatsappNumber.value = '';
        if (platform == 'twitter' || platform == 'x')
          twitterProfileName.value = '';
        Get.snackbar(
          'সফল',
          '$platformName সফলভাবে ডিসকানেক্ট করা হয়েছে!',
          backgroundColor: Colors.green.shade100,
        );
      } else {
        Get.snackbar('ত্রুটি', 'ডিসকানেক্ট করা সম্ভব হয়নি!');
      }
    } catch (e) {
      debugPrint('Disconnect error: $e');
      toggleConnection(platform, false);
    }
  }

  void toggleConnection(String platform, bool status) {
    if (platform == 'facebook') isFacebookConnected.value = status;
    if (platform == 'instagram') isInstagramConnected.value = status;
    if (platform == 'youtube') isYoutubeConnected.value = status;
    if (platform == 'tiktok') isTiktokConnected.value = status;
    if (platform == 'pinterest') isPinterestConnected.value = status;
    if (platform == 'linkedin') isLinkedinConnected.value = status;
    if (platform == 'whatsapp') isWhatsappConnected.value = status;
    if (platform == 'twitter' || platform == 'x')
      isTwitterConnected.value = status;

    _refreshAllStates();
  }

  void _refreshAllStates() {
    isFacebookConnected.refresh();
    isInstagramConnected.refresh();
    isYoutubeConnected.refresh();
    isTiktokConnected.refresh();
    isPinterestConnected.refresh();
    isLinkedinConnected.refresh();
    isWhatsappConnected.refresh();
    isTwitterConnected.refresh();
    facebookPageName.refresh();
    instagramPageName.refresh();
    linkedinProfileName.refresh();
    youtubeChannelName.refresh();
    whatsappNumber.refresh();
    twitterProfileName.refresh();
  }
}
