import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_automation/controllers/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';

// 📂 কাস্টম ফাইল ইম্পোর্ট
import 'package:social_media_automation/constants/app_colors.dart';
import 'package:social_media_automation/widgets/smart_button.dart';

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
  var isTwitterConnected = false.obs; // 👈 টুইটার কানেকশন স্ট্যাটাস

  // 🎯 ফেসবুক, ইনস্টাগ্রাম, লিঙ্কডইন, ইউটিউব, হোয়াটসঅ্যাপ ও টুইটারের নাম/নম্বর
  var facebookPageName = ''.obs;
  var instagramPageName = ''.obs;
  var linkedinProfileName = ''.obs;
  var youtubeChannelName = ''.obs;
  var whatsappNumber = ''.obs;
  var twitterProfileName = ''.obs; // 👈 টুইটার প্রোফাইল নেম

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

  // 🔐 সেফ পদ্ধতিতে UserId নেওয়ার হেলপার
  String _getUserId() {
    if (Get.isRegistered<AuthController>()) {
      final controller = Get.find<AuthController>();
      if (controller.userId.value.isNotEmpty) {
        return controller.userId.value;
      }
    }
    return '';
  }

  // 🔑 সেফ পদ্ধতিতে Auth Token নেওয়ার হেলপার
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // 🔄 ডাটাবেজ থেকে কানেকশন স্ট্যাটাস ও পেজ/প্রোফাইলের নাম চেক করা
  Future<void> fetchConnectionStatus() async {
    try {
      var userId = _getUserId();

      // র্যামে না থাকলে সরাসরি SharedPreferences থেকে লোড
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

        facebookPageName.value = ''; // রিফ্রেশ করার সময় নাম রিসেট
        instagramPageName.value = '';
        linkedinProfileName.value = '';
        youtubeChannelName.value = '';
        whatsappNumber.value = '';
        twitterProfileName.value = ''; // 👈 রিসেট

        // 🎯 JSON Response Handling
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

        // রিয়েলটাইম স্টেট আপডেট
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

  // 🔗 ফেসবুক/ইনস্টাগ্রাম কানেক্ট (Meta OAuth)
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

  // 💼 লিঙ্কডইন কানেক্ট (LinkedIn OAuth)
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

  // 🎥 ইউটিউব কানেক্ট (Google OAuth)
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

  // 🐦 টুইটার কানেক্ট (Twitter/X OAuth)
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

  // 💬 হোয়াটসঅ্যাপ কানেক্ট (Dialog Box & API Call)
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

  // 📤 ব্যাকএন্ডে হোয়াটসঅ্যাপ নম্বর আপডেট করার রিকোয়েস্ট
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

  // ⚠️ কনফার্মেশন পপ-আপ
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

  // ❌ ডিসকানেক্ট রিকোয়েস্ট (ডাটাবেস থেকে রিমুভ)
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

class AccountsView extends StatelessWidget {
  const AccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AccountsViewController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('সোশ্যাল অ্যাকাউন্টস'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchConnectionStatus(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'আপনার সোশ্যাল মিডিয়া ও মেসেজিং অ্যাকাউন্টগুলো ম্যানেজ করুন',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // ১. ফেসবুক পেজ কার্ড
          Obx(
            () => _buildAccountCard(
              platformName:
                  controller.isFacebookConnected.value &&
                      controller.facebookPageName.value.isNotEmpty
                  ? controller.facebookPageName.value
                  : 'Facebook Page',
              icon: Icons.facebook,
              iconColor: const Color(0xFF1877F2),
              isConnected: controller.isFacebookConnected.value,
              onConnect: controller.connectFacebook,
              onDisconnect: () => controller.confirmDisconnect(
                'facebook',
                controller.facebookPageName.value.isNotEmpty
                    ? controller.facebookPageName.value
                    : 'Facebook Page',
              ),
            ),
          ),

          // ২. ইনস্টাগ্রাম অ্যাকাউন্ট কার্ড
          Obx(
            () => _buildAccountCard(
              platformName:
                  controller.isInstagramConnected.value &&
                      controller.instagramPageName.value.isNotEmpty
                  ? controller.instagramPageName.value
                  : 'Instagram Business',
              icon: Icons.camera_alt,
              iconColor: Colors.pink,
              isConnected: controller.isInstagramConnected.value,
              onConnect: controller.connectFacebook,
              onDisconnect: () => controller.confirmDisconnect(
                'instagram',
                controller.instagramPageName.value.isNotEmpty
                    ? controller.instagramPageName.value
                    : 'Instagram Business',
              ),
            ),
          ),

          // ৩. ইউটিউব চ্যানেল কার্ড
          Obx(
            () => _buildAccountCard(
              platformName:
                  controller.isYoutubeConnected.value &&
                      controller.youtubeChannelName.value.isNotEmpty
                  ? controller.youtubeChannelName.value
                  : 'YouTube Channel',
              icon: Icons.play_arrow_rounded,
              iconColor: Colors.red,
              isConnected: controller.isYoutubeConnected.value,
              onConnect: controller.connectYoutube,
              onDisconnect: () => controller.confirmDisconnect(
                'youtube',
                controller.youtubeChannelName.value.isNotEmpty
                    ? controller.youtubeChannelName.value
                    : 'YouTube Channel',
              ),
            ),
          ),

          // ৪. টিকটক অ্যাকাউন্ট কার্ড
          Obx(
            () => _buildAccountCard(
              platformName: 'TikTok Profile',
              icon: Icons.music_note,
              iconColor: Colors.black,
              isConnected: controller.isTiktokConnected.value,
              onConnect: () => controller.toggleConnection('tiktok', true),
              onDisconnect: () =>
                  controller.confirmDisconnect('tiktok', 'TikTok Profile'),
            ),
          ),

          // ৫. পিন্টারেস্ট কার্ড
          Obx(
            () => _buildAccountCard(
              platformName: 'Pinterest Profile',
              icon: Icons.push_pin,
              iconColor: Colors.redAccent,
              isConnected: controller.isPinterestConnected.value,
              onConnect: () => controller.toggleConnection('pinterest', true),
              onDisconnect: () => controller.confirmDisconnect(
                'pinterest',
                'Pinterest Profile',
              ),
            ),
          ),

          // ৬. লিংকডইন কার্ড
          Obx(
            () => _buildAccountCard(
              platformName:
                  controller.isLinkedinConnected.value &&
                      controller.linkedinProfileName.value.isNotEmpty
                  ? controller.linkedinProfileName.value
                  : 'LinkedIn Profile',
              icon: Icons.work,
              iconColor: Colors.blue,
              isConnected: controller.isLinkedinConnected.value,
              onConnect: controller.connectLinkedin,
              onDisconnect: () => controller.confirmDisconnect(
                'linkedin',
                controller.linkedinProfileName.value.isNotEmpty
                    ? controller.linkedinProfileName.value
                    : 'LinkedIn Profile',
              ),
            ),
          ),

          // ৭. হোয়াটসঅ্যাপ বিজনেস কার্ড (🎯 Dynamic WhatsApp Dialog & API Integrated)
          Obx(
            () => _buildAccountCard(
              platformName:
                  controller.isWhatsappConnected.value &&
                      controller.whatsappNumber.value.isNotEmpty
                  ? 'WhatsApp (${controller.whatsappNumber.value})'
                  : 'WhatsApp Business',
              icon: Icons.chat,
              iconColor: Colors.green,
              isConnected: controller.isWhatsappConnected.value,
              onConnect: controller.showWhatsappDialog,
              onDisconnect: () => controller.confirmDisconnect(
                'whatsapp',
                controller.whatsappNumber.value.isNotEmpty
                    ? 'WhatsApp (${controller.whatsappNumber.value})'
                    : 'WhatsApp Business',
              ),
            ),
          ),

          // ৮. টুইটার (X) অ্যাকাউন্ট কার্ড 👈 নতুন যুক্ত করা হয়েছে
          Obx(
            () => _buildAccountCard(
              platformName:
                  controller.isTwitterConnected.value &&
                      controller.twitterProfileName.value.isNotEmpty
                  ? controller.twitterProfileName.value
                  : 'Twitter / X Profile',
              icon: Icons.alternate_email,
              iconColor: const Color(0xFF1DA1F2),
              isConnected: controller.isTwitterConnected.value,
              onConnect: controller.connectTwitter,
              onDisconnect: () => controller.confirmDisconnect(
                'twitter',
                controller.twitterProfileName.value.isNotEmpty
                    ? controller.twitterProfileName.value
                    : 'Twitter / X Profile',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard({
    required String platformName,
    required IconData icon,
    required Color iconColor,
    required bool isConnected,
    required VoidCallback onConnect,
    required VoidCallback onDisconnect,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    platformName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConnected ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isConnected ? 'Connected' : 'Not Connected',
                        style: TextStyle(
                          fontSize: 13,
                          color: isConnected ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SmartButton(
              text: isConnected ? 'Disconnect' : 'Connect',
              backgroundColor: isConnected
                  ? AppColors.dangerLight
                  : AppColors.primary,
              textColor: isConnected ? AppColors.danger : Colors.white,
              onPressed: isConnected ? onDisconnect : onConnect,
            ),
          ],
        ),
      ),
    );
  }
}
