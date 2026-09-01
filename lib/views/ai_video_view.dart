import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ai_video_controller.dart';
import '../widgets/account_selector_widget.dart';
import '../widgets/youtube_metadata_form.dart';
import '../widgets/post_schedule_picker.dart';
import '../widgets/smart_button.dart';

class AiVideoView extends StatefulWidget {
  const AiVideoView({Key? key}) : super(key: key);

  @override
  State<AiVideoView> createState() => _AiVideoViewState();
}

class _AiVideoViewState extends State<AiVideoView> {
  late final AiVideoController controller;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AiVideoController());
  }

  // 🎯 টাইপিং অ্যানিমেশন
  void _startTypingAnimation(String fullText) {
    _typingTimer?.cancel();
    controller.captionController.clear();

    int index = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (index < fullText.length) {
        controller.captionController.text = fullText.substring(0, index + 1);
        controller.captionController.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.captionController.text.length),
        );
        index++;
      } else {
        timer.cancel();
      }
    });
  }

  // 🎯 জেনারেট বাটন অ্যাকশন
  Future<void> _handleGenerateCaption() async {
    FocusScope.of(context).unfocus();
    final result = await controller.generateAiContent();

    if (result != null &&
        result['caption'] != null &&
        result['caption']!.isNotEmpty) {
      _startTypingAnimation(result['caption']!);
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'AI Content Studio',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 ১. মোড সিলেকশন টগল
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        title: 'Custom Video',
                        icon: Icons.video_collection_rounded,
                        isSelected: controller.inputMode.value == 0,
                        onTap: () => controller.inputMode.value = 0,
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        title: 'AI Generator',
                        icon: Icons.auto_awesome_rounded,
                        isSelected: controller.inputMode.value == 1,
                        onTap: () => controller.inputMode.value = 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🎯 ২. কাস্টম ভিডিও ফাইল সিলেক্টর
            Obx(() {
              if (controller.inputMode.value == 0) {
                return Column(
                  children: [
                    if (controller.selectedVideoPath.value.isEmpty)
                      InkWell(
                        onTap: controller.pickVideo,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.deepPurple.shade100,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.deepPurple.shade50,
                                child: const Icon(
                                  Icons.cloud_upload_rounded,
                                  color: Colors.deepPurple,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Upload your video',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to select MP4 or MOV files from your storage',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.green.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.movie_creation_rounded,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                controller.selectedVideoPath.value
                                    .split('/')
                                    .last,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.cancel_rounded,
                                color: Colors.redAccent,
                              ),
                              onPressed: controller.removeVideo,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // 🎯 ৩. AI Prompt Card (গ্রেডিয়েন্ট ডিজাইন)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade800, Colors.indigo.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.amberAccent,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'AI Prompt Assistant',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.promptController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'What is your post or video about?...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.12),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amberAccent,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: controller.isGeneratingAi.value
                            ? null
                            : _handleGenerateCaption,
                        icon: controller.isGeneratingAi.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black87,
                                ),
                              )
                            : const Icon(Icons.flash_on_rounded, size: 20),
                        label: Text(
                          controller.isGeneratingAi.value
                              ? 'Generating Content...'
                              : (controller.captionController.text.isEmpty
                                    ? 'Generate Content'
                                    : 'Regenerate Content'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🎯 ৪. সাধারণ ক্যাপশন এডিটর (Facebook, Instagram, etc.)
            _buildCardWrapper(
              title: 'Main Caption (FB, Insta, LinkedIn)',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => IconButton(
                      icon: controller.isGeneratingAi.value
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.refresh_rounded,
                              color: Colors.deepPurple,
                              size: 20,
                            ),
                      onPressed: controller.isGeneratingAi.value
                          ? null
                          : _handleGenerateCaption,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: () {
                      _typingTimer?.cancel();
                      controller.captionController.clear();
                    },
                  ),
                ],
              ),
              child: TextField(
                controller: controller.captionController,
                maxLines: 4,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Generated caption will appear here dynamically...',
                  border: InputBorder.none,
                ),
              ),
            ),

            // 🎯 ৫. টুইটার ক্যাপশন মেটাডাটা
            Obx(() {
              if (controller.postToTwitter.value) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: _buildCardWrapper(
                    title: 'Twitter (X) Post',
                    accentColor: Colors.blueAccent,
                    trailing: ValueListenableBuilder(
                      valueListenable: controller.twitterCaptionController,
                      builder: (context, value, child) {
                        int count =
                            controller.twitterCaptionController.text.length;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: count > 280
                                ? Colors.red.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count/280',
                            style: TextStyle(
                              fontSize: 11,
                              color: count > 280
                                  ? Colors.red
                                  : Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                    child: TextField(
                      controller: controller.twitterCaptionController,
                      maxLines: 3,
                      maxLength: 280,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Short & punchy tweet...',
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // 🎯 ৬. ইউটিউব মেটাডাটা ও থাম্বনেল সেকশন
            Obx(() {
              if (controller.postToYoutube.value) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      // ইউটিউব থাম্বনেল অপশনাল আপলোডার
                      _buildCardWrapper(
                        title: 'YouTube Custom Thumbnail',
                        accentColor: Colors.redAccent,
                        child: Obx(() {
                          if (controller.selectedThumbnailPath.value.isEmpty) {
                            return InkWell(
                              onTap: controller.pickThumbnail,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.shade100,
                                  ),
                                ),
                                child: Column(
                                  children: const [
                                    Icon(
                                      Icons.add_photo_alternate_rounded,
                                      color: Colors.redAccent,
                                      size: 32,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Upload Custom Thumbnail (Optional)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(
                                      controller.selectedThumbnailPath.value,
                                    ),
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.black.withOpacity(
                                      0.6,
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      onPressed: controller.removeThumbnail,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        }),
                      ),
                      const SizedBox(height: 16),
                      // মূল ইউটিউব ফর্ম
                      YoutubeMetadataForm(controller: controller),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 20),

            // 🎯 ৭. সোশ্যাল অ্যাকাউন্ট সিলেকশন
            AccountSelectorWidget(controller: controller),
            const SizedBox(height: 16),

            // 🎯 ৮. টাইম শিডিউলার
            PostSchedulePicker(controller: controller),
            const SizedBox(height: 28),

            // 🎯 ৯. ফাইনাল পাবলিশ বাটন
            SmartButton(controller: controller),
          ],
        ),
      ),
    );
  }

  // Helper Widget: কাস্টম টগল বাটন
  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget: ক্লিন কার্ড র‍্যাপার
  Widget _buildCardWrapper({
    required String title,
    required Widget child,
    Widget? trailing,
    Color accentColor = Colors.grey,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const Divider(height: 16),
          child,
        ],
      ),
    );
  }
}
