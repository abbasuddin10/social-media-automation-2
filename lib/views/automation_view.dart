import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/automation_controller.dart';

class AutomationView extends StatelessWidget {
  AutomationView({super.key});

  final AutomationController controller = Get.put(AutomationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Social Automation'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 3 Main Tabs ---
            LayoutBuilder(
              builder: (context, constraints) {
                final double buttonWidth = (constraints.maxWidth - 4) / 3;
                return Obx(
                  () => ToggleButtons(
                    isSelected: [
                      controller.selectedTab.value == 0,
                      controller.selectedTab.value == 1,
                      controller.selectedTab.value == 2,
                    ],
                    onPressed: (index) => controller.selectedTab.value = index,
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
                        '🤖 AI Agent',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '✍️ Manual',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '⏰ Schedule',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // --- Tab Dynamic Content ---
            Obx(() {
              if (controller.selectedTab.value == 0) {
                return _buildAiAgentTab();
              } else if (controller.selectedTab.value == 1) {
                return _buildManualTab();
              } else {
                return _buildScheduleTab(context);
              }
            }),

            const SizedBox(height: 24),
            const Divider(),

            // --- Social Accounts Selection ---
            const Text(
              'Select Social Accounts:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Obx(
              () => CheckboxListTile(
                title: const Text('Select All Accounts'),
                value: controller.selectAll.value,
                onChanged: (val) => controller.toggleSelectAll(val!),
                contentPadding: EdgeInsets.zero,
                activeColor: Colors.deepPurple,
              ),
            ),
            Obx(
              () => Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Facebook Page'),
                    value: controller.postToFacebook.value,
                    onChanged: (val) => controller.postToFacebook.value = val!,
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.deepPurple,
                  ),
                  CheckboxListTile(
                    title: const Text('Instagram Business'),
                    value: controller.postToInstagram.value,
                    onChanged: (val) => controller.postToInstagram.value = val!,
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.deepPurple,
                  ),
                  CheckboxListTile(
                    title: const Text('Pinterest Profile'),
                    value: controller.postToPinterest.value,
                    onChanged: (val) => controller.postToPinterest.value = val!,
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.deepPurple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Submit Button ---
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Obx(
                () => ElevatedButton(
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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          controller.selectedTab.value == 2
                              ? (controller.uploadedImages.isEmpty
                                    ? '🚀 Save Schedule Post'
                                    : '🚀 Save Schedule (${controller.uploadedImages.length} Days Auto Post)')
                              : '🚀 Run Post Now',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Tab 1: AI Agent ---
  Widget _buildAiAgentTab() {
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

        // 🎯 AI Caption Preview Button
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

        // 🎯 Editable AI Generated Caption Field (Visible after generation)
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

  // --- Tab 2: Manual ---
  Widget _buildManualTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Write your own caption or post:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
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

  // --- Tab 3: Schedule View ---
  Widget _buildScheduleTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Describe Your Business or Post Subject:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 4),
        const Text(
          'Each image will be scheduled for consecutive days at your selected daily time.',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.schedulePromptController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                'e.g., We sell handcrafted leather bags. Auto-generate daily promotional captions...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Daily Schedule Time:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: controller.selectedTime.value ?? TimeOfDay.now(),
            );

            if (pickedTime != null) {
              controller.selectedTime.value = pickedTime;
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
              color: Colors.purple.shade50.withOpacity(0.3),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: controller.selectedTime.value == null
                              ? Colors.black87
                              : Colors.deepPurple.shade900,
                        ),
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

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                'Selected Images (${controller.uploadedImages.length} Days):',
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
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

  // --- Image Preview List ---
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
                                      controller.selectedTab.value == 2
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
