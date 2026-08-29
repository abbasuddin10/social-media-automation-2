import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'automation_agent_view.dart';
import '../controllers/automation_controller.dart';

class AutomationView extends StatelessWidget {
  AutomationView({super.key});

  final AutomationController controller = Get.put(AutomationController());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchScheduleOnlyPosts();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Social Automation'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 4 Main Tabs ---
            LayoutBuilder(
              builder: (context, constraints) {
                final double buttonWidth = (constraints.maxWidth - 6) / 4;
                return Obx(
                  () => ToggleButtons(
                    isSelected: [
                      controller.selectedTab.value == 0,
                      controller.selectedTab.value == 1,
                      controller.selectedTab.value == 2,
                      controller.selectedTab.value == 3,
                    ],
                    onPressed: (index) {
                      controller.selectedTab.value = index;
                      if (index == 3) {
                        controller.fetchScheduleOnlyPosts();
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    fillColor: Colors.deepPurple.shade100,
                    selectedColor: Colors.deepPurple.shade900,
                    color: Colors.black87,
                    constraints: BoxConstraints(
                      minHeight: 48,
                      minWidth: buttonWidth,
                    ),
                    children: const [
                      Text(
                        '🤖 Fully AI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '✨ AI Caption',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '✍️ Manual',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '⏰ Schedule',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // --- Dynamic Content View ---
            Obx(() {
              if (controller.selectedTab.value == 0) {
                return _buildFullyAiTab();
              } else if (controller.selectedTab.value == 1) {
                return _buildAiCaptionTab();
              } else if (controller.selectedTab.value == 2) {
                return _buildManualTab();
              } else {
                return _buildScheduleTab(context);
              }
            }),

            // --- Social Accounts Selection & Bottom Submit Button ---
            Obx(() {
              if (controller.selectedTab.value == 0) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Divider(),

                  const Text(
                    'Select Social Accounts:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  CheckboxListTile(
                    title: const Text('Select All Accounts'),
                    value: controller.selectAll.value,
                    onChanged: (val) => controller.toggleSelectAll(val!),
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.deepPurple,
                  ),
                  Column(
                    children: [
                      CheckboxListTile(
                        title: const Text('Facebook Page'),
                        value: controller.postToFacebook.value,
                        onChanged: (val) =>
                            controller.postToFacebook.value = val!,
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.deepPurple,
                      ),
                      CheckboxListTile(
                        title: const Text('Instagram Business'),
                        value: controller.postToInstagram.value,
                        onChanged: (val) =>
                            controller.postToInstagram.value = val!,
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.deepPurple,
                      ),
                      CheckboxListTile(
                        title: const Text('Pinterest Profile'),
                        value: controller.postToPinterest.value,
                        onChanged: (val) =>
                            controller.postToPinterest.value = val!,
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.deepPurple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // সোশ্যাল অ্যাকাউন্ট সিলেক্টের পরে সাবমিট/সেভ বাটন
                  if (controller.selectedTab.value == 3) ...[
                    if (controller.scheduledPreviewList.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.confirmAndSaveSchedulePosts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  '✅ Confirm & Save All Schedule Posts (${controller.scheduledPreviewList.length} Days)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                '🚀 Run Post Now',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              );
            }),

            // --- Active Scheduled Posts Section ---
            Obx(() {
              if (controller.selectedTab.value != 3) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Divider(thickness: 1.5),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: Colors.deepPurple,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Active Scheduled Posts',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => Text(
                          '${controller.scheduledOnlyPosts.length} Active',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildScheduledPostsList(context),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFullyAiTab() {
    return const AutomationAgentView();
  }

  Widget _buildAiCaptionTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tell the agent your business details or what to post about:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.aiPromptController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'e.g., Our new organic juice has arrived...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isGeneratingAi.value
                  ? null
                  : controller.handleAiPreviewGeneration,
              icon: controller.isGeneratingAi.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.deepPurple,
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(
                controller.isGeneratingAi.value
                    ? 'Generating AI Caption...'
                    : 'Generate & Preview Caption',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade50,
                foregroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        Obx(
          () => controller.isAiCaptionGenerated.value
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    const Text(
                      'Generated Caption (Edit if needed):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller.aiGeneratedCaptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => Text(
                  'Add Images (${controller.uploadedImages.length}):',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: controller.pickMultipleImages,
              icon: const Icon(Icons.add_photo_alternate, size: 16),
              label: const Text('Add Images'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade50,
                foregroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildImagePreviewList(),
      ],
    );
  }

  Widget _buildManualTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Write your own caption or post:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller.manualPromptController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Write caption directly here...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => Text(
                  'Add Images (${controller.uploadedImages.length}):',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: controller.pickMultipleImages,
              icon: const Icon(Icons.image, size: 16),
              label: const Text('Select Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildImagePreviewList(),
      ],
    );
  }

  Widget _buildScheduleTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Describe Your Business or Post Subject:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.schedulePromptController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                'e.g., We sell handcrafted leather bags. Auto-generate daily promotional captions...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        // Time Picker Container
        InkWell(
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: controller.selectedTime.value ?? TimeOfDay.now(),
            );
            if (pickedTime != null) controller.selectedTime.value = pickedTime;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
              color: Colors.purple.shade50.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_filled,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => Text(
                        controller.selectedTime.value == null
                            ? 'Select Daily Posting Time'
                            : 'Posting Time: ${controller.selectedTime.value!.format(context)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Image Selection Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                'Selected Images (${controller.uploadedImages.length}):',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: controller.pickMultipleImages,
              icon: const Icon(Icons.add_photo_alternate, size: 16),
              label: const Text('Add Images'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildImagePreviewList(),

        const SizedBox(height: 16),

        // AI Captions Generate Button
        SizedBox(
          width: double.infinity,
          child: Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isGeneratingScheduleCaptions.value
                  ? null
                  : controller.generateSchedulePreviewList,
              icon: controller.isGeneratingScheduleCaptions.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                controller.isGeneratingScheduleCaptions.value
                    ? 'Generating AI Captions for each image...'
                    : '✨ Generate AI Captions for All Days',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),

        // Schedule Preview Cards List
        Obx(() {
          if (controller.scheduledPreviewList.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Review & Edit Schedule Captions:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.scheduledPreviewList.length,
                itemBuilder: (context, index) {
                  var item = controller.scheduledPreviewList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Day ${item['day']} Scheduled Post',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(item['imagePath']),
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: item['captionController'],
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Editable AI Caption',
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildScheduledPostsList(BuildContext context) {
    return Obx(() {
      if (controller.isFetchingSchedule.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: Colors.deepPurple),
          ),
        );
      }

      if (controller.scheduledOnlyPosts.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Column(
            children: [
              Icon(Icons.event_note, color: Colors.grey, size: 40),
              SizedBox(height: 8),
              Text(
                'ডাটাবেসে কোনো শিডিউল করা পোস্ট নেই।',
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.scheduledOnlyPosts.length,
        itemBuilder: (context, index) {
          final post = controller.scheduledOnlyPosts[index];

          String? imageUrl;
          if (post['images'] != null &&
              post['images'] is List &&
              (post['images'] as List).isNotEmpty) {
            imageUrl = post['images'][0].toString();
          } else if (post['images'] is String &&
              (post['images'] as String).isNotEmpty) {
            imageUrl = post['images'];
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null && imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.deepPurple.shade100,
                          child: const Icon(
                            Icons.image,
                            color: Colors.deepPurple,
                          ),
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        color: Colors.deepPurple.shade100,
                        child: const Icon(
                          Icons.schedule,
                          color: Colors.deepPurple,
                        ),
                      ),
              ),
              title: Text(
                post['content'] ?? 'No Caption',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      post['scheduled_at'] != null
                          ? post['scheduled_at'].toString().split('T')[0]
                          : 'Pending Time',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.deepPurple,
                      size: 20,
                    ),
                    onPressed: () => _showEditDialog(context, post),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () =>
                        _showDeleteConfirmDialog(context, post['id']),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showEditDialog(BuildContext context, dynamic post) {
    TextEditingController editCaptionController = TextEditingController(
      text: post['content'] ?? '',
    );

    RxList<File> tempSelectedImages = <File>[].obs;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Edit Scheduled Post',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Caption:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: editCaptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final List<XFile> images = await picker.pickMultiImage();
                    if (images.isNotEmpty) {
                      tempSelectedImages.assignAll(
                        images.map((e) => File(e.path)),
                      );
                    }
                  },
                  icon: const Icon(Icons.image, size: 18),
                  label: const Text('Change/Replace Image'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(height: 6),
                Obx(
                  () => tempSelectedImages.isNotEmpty
                      ? Text(
                          '${tempSelectedImages.length} new image(s) selected',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.updateScheduledPost(
                  postId: post['id'],
                  content: editCaptionController.text.trim(),
                  newImages: tempSelectedImages.isEmpty
                      ? null
                      : tempSelectedImages,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, dynamic postId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Schedule Post?'),
          content: const Text(
            'আপনি কি নিশ্চিত যে এই শিডিউল পোস্টটি মুছে ফেলতে চান?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteScheduledPost(postId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePreviewList() {
    return Obx(
      () => controller.uploadedImages.isEmpty
          ? const Text(
              'No images selected.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.uploadedImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.image,
                                      color: Colors.deepPurple,
                                      size: 26,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.selectedTab.value == 3
                                          ? 'Day ${index + 1}'
                                          : 'Img ${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () => controller.removeImage(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
