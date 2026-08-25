import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import 'accounts_view.dart';
import 'faq_chat_view.dart'; // 👈 FAQ AI Chat View ইমপোর্ট করা হলো

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.deepPurple),
            onPressed: () => controller.fetchUserProfile(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepPurple),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ------------------ 1. MODERN WHITE HEADER SECTION ------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 15,
                  bottom: 25,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 🖼️ প্রোফাইল পিকচার + গ্যালারি আপলোড বাটন
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple,
                                Colors.deepPurple.shade200,
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 37,
                              backgroundColor: Colors.deepPurple.shade50,
                              backgroundImage:
                                  controller
                                      .profilePicController
                                      .text
                                      .isNotEmpty
                                  ? NetworkImage(
                                      controller.profilePicController.text,
                                    )
                                  : null,
                              child:
                                  controller.profilePicController.text.isEmpty
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 45,
                                      color: Colors.deepPurple,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        // 📷 ক্যামেরা আইকন (আপলোড লোডার)
                        Obx(
                          () => InkWell(
                            onTap: controller.isUploadingImage.value
                                ? null
                                : () => controller.pickAndUploadImage(),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: controller.isUploadingImage.value
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 👤 নাম + এডিট বাটন
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.nameController.text.isEmpty
                              ? "User Name"
                              : controller.nameController.text,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          icon: Icon(
                            Icons.edit_note_rounded,
                            color: Colors.deepPurple.shade400,
                            size: 22,
                          ),
                          onPressed: () => _openEditDialog(
                            title: "Edit Full Name",
                            controller: controller.nameController,
                            onSave: () => controller.updateUserProfile(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 📧 ইমেইল ও ইউজার আইডি
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoChip(
                            icon: Icons.fingerprint_rounded,
                            title: "User ID",
                            value: controller.userIdController.text,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInfoChip(
                            icon: Icons.email_outlined,
                            title: "Email",
                            value: controller.emailController.text,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ------------------ 2. LOWER BODY SECTION ------------------
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔑 পাসওয়ার্ড রিসেট
                    _buildMenuTile(
                      icon: Icons.lock_reset_rounded,
                      title: "Password & Security",
                      subtitle: "Reset password using OTP",
                      onTap: () => controller.openResetPasswordDialog(),
                    ),

                    const SizedBox(height: 12),

                    // 🔗 কানেক্টেড প্লাটফর্ম
                    Obx(() {
                      final count = controller.connectedAccounts.length;
                      return _buildMenuTile(
                        icon: Icons.hub_outlined,
                        title: "Connected Platforms",
                        subtitle: count > 0
                            ? "$count platform(s) connected"
                            : "Manage social accounts & pages",
                        onTap: () => Get.to(() => const AccountsView()),
                      );
                    }),

                    const SizedBox(height: 12),

                    // 💬 লাইভ সাপোর্ট (WhatsApp integration)
                    _buildMenuTile(
                      icon: Icons.headset_mic_rounded,
                      iconColor: Colors.green,
                      title: "Live Support",
                      subtitle: "Chat directly with support team",
                      onTap: () => controller.openLiveSupport(),
                    ),

                    const SizedBox(height: 12),

                    // 🤖 FAQ / AI সাহায্য
                    _buildMenuTile(
                      icon: Icons.auto_awesome_rounded,
                      iconColor: Colors.amber.shade700,
                      title: "Frequently Asked Questions",
                      subtitle: "Instant Help Powered by AI",
                      onTap: () => Get.to(() => const FaqChatView()),
                    ),

                    const SizedBox(height: 12),

                    // 🗑️ অ্যাকাউন্ট ডিলিট
                    _buildMenuTile(
                      icon: Icons.delete_forever_rounded,
                      iconColor: Colors.redAccent,
                      title: "Delete Account",
                      subtitle: "Permanently wipe your account data",
                      titleColor: Colors.redAccent,
                      onTap: () => controller.openDeleteAccountDialog(),
                    ),

                    const SizedBox(height: 30),

                    // 📱 অ্যাপ ভার্সন
                    const Center(
                      child: Text(
                        "App Version 1.0.0",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // 🛠️ মেনু আইটেম রি-ইউজেবল উইজেট
  Widget _buildMenuTile({
    required IconData icon,
    Color iconColor = Colors.deepPurple,
    required String title,
    required String subtitle,
    Color titleColor = Colors.black87,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: titleColor,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  // 🛠️ ইমেইল ও আইডি চিপ হেলপার মেথড
  Widget _buildInfoChip({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? "N/A" : value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✏️ এডিট করার জন্য ডায়ালগ পপআপ
  void _openEditDialog({
    required String title,
    required TextEditingController controller,
    required Function onSave,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      contentPadding: const EdgeInsets.all(16),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          hintText: "Enter value here",
        ),
      ),
      textConfirm: "Save",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.deepPurple,
      onConfirm: () {
        onSave();
        Get.back();
      },
    );
  }
}
