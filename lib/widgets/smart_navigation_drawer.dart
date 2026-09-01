import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_media_automation/constants/app_colors.dart';
import 'package:social_media_automation/controllers/auth_controller.dart';
import 'package:social_media_automation/controllers/profile_controller.dart';

class SmartNavigationDrawer extends StatelessWidget {
  const SmartNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // সেফ কন্ট্রোলার লোডার
    final ProfileController profileController =
        Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    final AuthController authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    return Drawer(
      child: Column(
        children: [
          // ১. হেডার: ইউজার প্রোফাইল ও স্টেটাস
          GetBuilder<ProfileController>(
            builder: (controller) {
              final String name = controller.nameController.text;
              final String email = controller.emailController.text;
              final String profilePic = controller.profilePicController.text;

              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppColors.primary),
                currentAccountPicture: Stack(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 34,
                        backgroundImage: profilePic.isNotEmpty
                            ? NetworkImage(profilePic)
                            : null,
                        child: profilePic.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                accountName: Text(
                  name.isNotEmpty ? name : 'Automation User',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                accountEmail: Text(
                  email.isNotEmpty ? email : 'user@example.com',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              );
            },
          ),

          // ২. নেভিগেশন আইটেমস
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  onTap: () {
                    Get.back();
                    if (Get.currentRoute != '/home') Get.toNamed('/home');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Orders & Leads',
                  badge: 'New',
                  onTap: () {
                    Get.back();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.link_rounded,
                  title: 'Connected Platforms',
                  onTap: () {
                    Get.back();
                    Get.toNamed('/accounts');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Automation Rules',
                  onTap: () {
                    Get.back();
                  },
                ),

                const Divider(indent: 16, endIndent: 16),

                _buildDrawerItem(
                  icon: Icons.person_search_outlined,
                  title: 'Hire Experts & Editors',
                  iconColor: Colors.deepPurple,
                  onTap: () {
                    Get.back();
                  },
                ),

                const Divider(indent: 16, endIndent: 16),

                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Get.back();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.headset_mic_outlined,
                  title: 'Support & Live Chat',
                  onTap: () {
                    Get.back();
                    profileController.openLiveSupport(); //[cite: 3]
                  },
                ),
              ],
            ),
          ),

          // ৩. লগআউট বাটন
          SafeArea(
            child: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Get.back();
                  authController.submitAuth(); // অথবা আপনার লগআউট লজিক
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    String? badge,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey.shade700),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            )
          : const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }
}
