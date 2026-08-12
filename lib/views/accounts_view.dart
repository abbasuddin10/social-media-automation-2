import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:social_media_automation/controllers/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountsViewController extends GetxController
    with WidgetsBindingObserver {
  // সোশ্যাল মিডিয়াগুলোর কানেকশন স্ট্যাটাস (.obs)
  var isFacebookConnected = false.obs;
  var isInstagramConnected = false.obs;
  var isYoutubeConnected = false.obs;
  var isTiktokConnected = false.obs;
  var isPinterestConnected = false.obs;
  var isLinkedinConnected = false.obs;
  var isWhatsappConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 📱 ইউজার ব্রাউজার থেকে অ্যাপে ব্যাক করলে স্বয়ংক্রিয় রিফ্রেশ ট্র্যাকিং শুরু
    WidgetsBinding.instance.addObserver(this);
    fetchConnectionStatus();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // 🔄 ব্রাউজার থেকে অ্যাপে ফিরে আসলেই ব্যাকএন্ড চেক করবে
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchConnectionStatus();
    }
  }

  // 🔐 সেফ পদ্ধতিতে AuthController থেকে UserId নেওয়ার হেলপার
  String _getUserId() {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().userId.value;
    }
    return '';
  }

  // 🔄 ডাটাবেজ থেকে কানেকশন স্ট্যাটাস চেক করার ফাংশন
  Future<void> fetchConnectionStatus() async {
    try {
      final userId = _getUserId();
      if (userId.isEmpty) return;

      final response = await http.get(
        Uri.parse(
          'https://social-backend-1hwz.onrender.com/user/accounts?user_id=$userId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<String> connectedPlatforms = [];

        // ডাটাবেজ থেকে অ্যারে বা ম্যাপ যা-ই আসুক সেফ পার্সিং
        if (data is List) {
          for (var item in data) {
            if (item is String) {
              connectedPlatforms.add(item.toLowerCase().trim());
            } else if (item is Map && item['platform'] != null) {
              connectedPlatforms.add(
                item['platform'].toString().toLowerCase().trim(),
              );
            }
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

        _refreshAllStates();
      }
    } catch (e) {
      debugPrint('Error fetching status: $e');
    }
  }

  // 🔗 ফেসবুক কানেক্ট করার ফাংশন
  Future<void> connectFacebook() async {
    final userId = _getUserId();

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

  // ⚠️ ১. ডিসকানেক্ট করার আগে কনফার্মেশন পপ-আপ ডায়ালগ
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
        Get.back(); // ডায়ালগ বন্ধ করা
        disconnectPlatform(platform, platformName); // ডিসকানেক্ট এপিআই কল
      },
    );
  }

  // ❌ ২. ব্যাকএন্ড এপিআই-তে ডিসকানেক্ট রিকোয়েস্ট পাঠানো
  Future<void> disconnectPlatform(String platform, String platformName) async {
    try {
      final userId = _getUserId();
      if (userId.isEmpty) return;

      final response = await http.post(
        Uri.parse('https://social-backend-1hwz.onrender.com/auth/disconnect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'platform': platform}),
      );

      if (response.statusCode == 200) {
        toggleConnection(platform, false);
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
      // নেটওয়ার্ক সমস্যা হলেও UI আপডেট
      toggleConnection(platform, false);
    }
  }

  // স্টেট টগল ও রিফ্রেশ
  void toggleConnection(String platform, bool status) {
    if (platform == 'facebook') isFacebookConnected.value = status;
    if (platform == 'instagram') isInstagramConnected.value = status;
    if (platform == 'youtube') isYoutubeConnected.value = status;
    if (platform == 'tiktok') isTiktokConnected.value = status;
    if (platform == 'pinterest') isPinterestConnected.value = status;
    if (platform == 'linkedin') isLinkedinConnected.value = status;
    if (platform == 'whatsapp') isWhatsappConnected.value = status;

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
        backgroundColor: Colors.deepPurple,
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
              platformName: 'Facebook Page',
              icon: Icons.facebook,
              iconColor: const Color(0xFF1877F2),
              isConnected: controller.isFacebookConnected.value,
              onConnect: controller.connectFacebook,
              onDisconnect: () =>
                  controller.confirmDisconnect('facebook', 'Facebook Page'),
            ),
          ),

          // ২. ইনস্টাগ্রাম অ্যাকাউন্ট কার্ড
          Obx(
            () => _buildAccountCard(
              platformName: 'Instagram Business',
              icon: Icons.camera_alt,
              iconColor: Colors.pink,
              isConnected: controller.isInstagramConnected.value,
              onConnect: () => controller.toggleConnection('instagram', true),
              onDisconnect: () => controller.confirmDisconnect(
                'instagram',
                'Instagram Business',
              ),
            ),
          ),

          // ৩. ইউটিউব চ্যানেল কার্ড
          Obx(
            () => _buildAccountCard(
              platformName: 'YouTube Channel',
              icon: Icons.play_arrow_rounded,
              iconColor: Colors.red,
              isConnected: controller.isYoutubeConnected.value,
              onConnect: () => controller.toggleConnection('youtube', true),
              onDisconnect: () =>
                  controller.confirmDisconnect('youtube', 'YouTube Channel'),
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
              platformName: 'LinkedIn Profile',
              icon: Icons.work,
              iconColor: Colors.blue,
              isConnected: controller.isLinkedinConnected.value,
              onConnect: () => controller.toggleConnection('linkedin', true),
              onDisconnect: () =>
                  controller.confirmDisconnect('linkedin', 'LinkedIn Profile'),
            ),
          ),

          // ৭. হোয়াটসঅ্যাপ বিজনেস কার্ড
          Obx(
            () => _buildAccountCard(
              platformName: 'WhatsApp Business',
              icon: Icons.chat,
              iconColor: Colors.green,
              isConnected: controller.isWhatsappConnected.value,
              onConnect: () => controller.toggleConnection('whatsapp', true),
              onDisconnect: () =>
                  controller.confirmDisconnect('whatsapp', 'WhatsApp Business'),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected
                    ? Colors.red.shade50
                    : Colors.deepPurple,
                foregroundColor: isConnected ? Colors.red : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: isConnected ? onDisconnect : onConnect,
              child: Text(isConnected ? 'Disconnect' : 'Connect'),
            ),
          ],
        ),
      ),
    );
  }
}
