import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountsViewController extends GetxController {
  // সোশ্যাল মিডিয়াগুলোর কানেকশন স্ট্যাটাস অবজারভেবল (.obs) করা হলো
  var isFacebookConnected = true.obs;
  var isInstagramConnected = false.obs;
  var isYoutubeConnected = false.obs;
  var isTiktokConnected = false.obs;
  var isPinterestConnected = false.obs;
  var isLinkedinConnected = false.obs;
  var isWhatsappConnected = false.obs;

  // ফেসবুক পেজ কানেক্ট করার ফাংশন

  // ফেসবুক কানেক্ট বাটনে ক্লিক করার ফাংশন
  Future<void> connectFacebook() async {
    // ১. আপনার অ্যাপের লোকাল স্টোরেজ (SharedPreferences বা GetStorage) থেকে লগইন করা ইউজারের আইডি নিন
    final userId = 1; // এটি আপনার অ্যাপের ডায়নামিক ইউজার আইডি হবে

    // ২. ব্যাকএন্ড লিংকের সাথে user_id যুক্ত করুন
    final url = Uri.parse(
      'https://social-backend-1hwz.onrender.com/auth/facebook?user_id=$userId',
    );

    // ৩. ব্রাউজার বা এক্সটার্নাল অ্যাপে ওপেন করুন
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // ব্রাউজারে ওপেন করার জন্য
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  // যেকোনো প্ল্যাটফর্ম কানেক্ট বা ডিসকানেক্ট টগল করার ফাংশন
  void toggleConnection(String platform, bool status) {
    if (platform == 'facebook') isFacebookConnected.value = status;
    if (platform == 'instagram') isInstagramConnected.value = status;
    if (platform == 'youtube') isYoutubeConnected.value = status;
    if (platform == 'tiktok') isTiktokConnected.value = status;
    if (platform == 'pinterest') isPinterestConnected.value = status;
    if (platform == 'linkedin') isLinkedinConnected.value = status;
    if (platform == 'whatsapp') isWhatsappConnected.value = status;
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'আপনার সোশ্যাল মিডিয়া ও মেসেজিং অ্যাকাউন্টগুলো ম্যানেজ করুন',
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
                  controller.toggleConnection('facebook', false),
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
              onDisconnect: () =>
                  controller.toggleConnection('instagram', false),
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
              onDisconnect: () => controller.toggleConnection('youtube', false),
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
              onDisconnect: () => controller.toggleConnection('tiktok', false),
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
              onDisconnect: () =>
                  controller.toggleConnection('pinterest', false),
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
                  controller.toggleConnection('linkedin', false),
            ),
          ),

          // ৭. হোয়াটসঅ্যাপ বিজনেস কার্ড
          Obx(
            () => _buildAccountCard(
              platformName: 'WhatsApp Business',
              icon: Icons.chat,
              iconColor: Colors.green,
              isConnected: controller.isWhatsappConnected.value,
              onConnect: () => controller.toggleConnection('whatsapp', true),
              onDisconnect: () =>
                  controller.toggleConnection('whatsapp', false),
            ),
          ),
        ],
      ),
    );
  }

  // স্মার্ট কার্ড ইউআই উইজেট
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
