import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_media_automation/constants/app_colors.dart';
import 'package:social_media_automation/controllers/accounts_view_controller.dart';

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

          // ৭. হোয়াটসঅ্যাপ বিজনেস কার্ড
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

          // ৮. টুইটার (X) অ্যাকাউন্ট কার্ড
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected
                    ? Colors.red.shade100
                    : AppColors.primary,
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
