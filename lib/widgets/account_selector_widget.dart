import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ai_video_controller.dart';

class AccountSelectorWidget extends StatelessWidget {
  final AiVideoController controller;

  const AccountSelectorWidget({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<Map<String, dynamic>> allPlatforms = [
        {
          'name': 'Facebook Page',
          'icon': Icons.facebook,
          'color': Colors.blue,
          'isConnected': controller.accountsCtrl.isFacebookConnected.value,
          'isSelected': controller.postToFacebook.value,
          'onToggle': (bool val) => controller.postToFacebook.value = val,
        },
        {
          'name': 'Instagram Business',
          'icon': Icons.camera_alt,
          'color': Colors.pink,
          'isConnected': controller.accountsCtrl.isInstagramConnected.value,
          'isSelected': controller.postToInstagram.value,
          'onToggle': (bool val) => controller.postToInstagram.value = val,
        },
        {
          'name': 'YouTube Channel',
          'icon': Icons.video_library,
          'color': Colors.red,
          'isConnected': controller.accountsCtrl.isYoutubeConnected.value,
          'isSelected': controller.postToYoutube.value,
          'onToggle': (bool val) => controller.postToYoutube.value = val,
        },
        {
          'name': 'Pinterest Profile',
          'icon': Icons.pin_drop,
          'color': Colors.redAccent,
          'isConnected': controller.accountsCtrl.isPinterestConnected.value,
          'isSelected': controller.postToPinterest.value,
          'onToggle': (bool val) => controller.postToPinterest.value = val,
        },
        {
          'name': 'LinkedIn Profile',
          'icon': Icons.work,
          'color': Colors.blue.shade700,
          'isConnected': controller.accountsCtrl.isLinkedinConnected.value,
          'isSelected': controller.postToLinkedin.value,
          'onToggle': (bool val) => controller.postToLinkedin.value = val,
        },
        {
          'name': 'Twitter / X',
          'icon': Icons.tag,
          'color': Colors.lightBlue,
          'isConnected': controller.accountsCtrl.isTwitterConnected.value,
          'isSelected': controller.postToTwitter.value,
          'onToggle': (bool val) => controller.postToTwitter.value = val,
        },
      ];

      final connectedPlatforms = allPlatforms
          .where((p) => p['isConnected'] == true)
          .toList();
      int selectedCount = connectedPlatforms
          .where((p) => p['isSelected'] == true)
          .length;
      bool isAllSelected =
          connectedPlatforms.isNotEmpty &&
          selectedCount == connectedPlatforms.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Target Platforms',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              if (connectedPlatforms.isNotEmpty)
                TextButton.icon(
                  onPressed: () => controller.toggleSelectAll(!isAllSelected),
                  icon: Icon(
                    isAllSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 18,
                  ),
                  label: const Text(
                    'Select All',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: allPlatforms.map((platform) {
              final bool isConnected = platform['isConnected'] as bool;
              final bool isSelected = platform['isSelected'] as bool;
              final String platformName = platform['name'] as String;
              final IconData icon = platform['icon'] as IconData;
              final Color color = platform['color'] as Color;
              final Function(bool) onToggle =
                  platform['onToggle'] as Function(bool);

              if (isConnected) {
                return FilterChip(
                  avatar: Icon(icon, size: 16, color: color),
                  label: Text(
                    platformName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.deepPurple.shade100,
                  checkmarkColor: Colors.deepPurple,
                  onSelected: (val) => onToggle(val),
                );
              } else {
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showConnectDialog(context, platformName),
                  child: Opacity(
                    opacity: 0.45,
                    child: Chip(
                      backgroundColor: Colors.grey.shade200,
                      avatar: Icon(icon, size: 16, color: Colors.grey.shade700),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            platformName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.add_circle_outline,
                            size: 14,
                            color: Colors.deepPurple,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }).toList(),
          ),
        ],
      );
    });
  }

  void _showConnectDialog(BuildContext context, String platformName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.link_off, color: Colors.orangeAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$platformName Not Connected',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            'আপনি এখনো $platformName কানেক্ট করেননি। পোস্ট করতে হলে প্রথমে আপনার অ্যাকাউন্টটি কানেক্ট করে নিন।',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.toNamed('/accounts');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text(
              'Connect Now',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
