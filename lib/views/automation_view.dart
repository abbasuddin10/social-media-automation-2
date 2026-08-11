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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 3 Main Tabs (Full Width) ---
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
                    borderRadius: BorderRadius.circular(8),
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

            // --- Tab 1: AI Agent Mode ---
            Obx(() {
              if (controller.selectedTab.value == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tell the agent your business details or what to post about:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.aiPromptController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'e.g., Our new organic juice has arrived...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Add Images (Optional):',
                            style: TextStyle(
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
                            backgroundColor: Colors.deepPurple.shade50,
                            foregroundColor: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildImagePreviewList(),
                  ],
                );
              }
              // --- Tab 2: Manual Post ---
              else if (controller.selectedTab.value == 1) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Write your own caption or post:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: controller.askGeminiForHelp,
                          icon: const Icon(
                            Icons.auto_awesome,
                            color: Colors.amber,
                            size: 18,
                          ),
                          label: const Text('Ask Gemini AI'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: controller.manualPromptController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Write caption directly here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Add Images (Optional):',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildImagePreviewList(),
                  ],
                );
              }
              // --- Tab 3: Schedule Mode ---
              else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter business details or prompt for daily auto-posting:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.schedulePromptController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'e.g., Daily health tips and juice ads...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurple.shade200),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Daily Post Time:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                controller.pickScheduleTime(context),
                            icon: const Icon(
                              Icons.access_time,
                              color: Colors.deepPurple,
                              size: 18,
                            ),
                            label: Obx(
                              () => Text(
                                controller.scheduleTime.value.format(context),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Upload Multiple Images for Auto-Post:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: controller.pickMultipleImages,
                          icon: const Icon(Icons.library_add, size: 16),
                          label: const Text('Add Images'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildImagePreviewList(),
                  ],
                );
              }
            }),
            const SizedBox(height: 24),

            // --- Social Accounts Selection Section ---
            const Divider(),
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
                  ),
                  CheckboxListTile(
                    title: const Text('Instagram Business'),
                    value: controller.postToInstagram.value,
                    onChanged: (val) => controller.postToInstagram.value = val!,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Pinterest Profile'),
                    value: controller.postToPinterest.value,
                    onChanged: (val) => controller.postToPinterest.value = val!,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Obx(
                          () => Text(
                            controller.selectedTab.value == 2
                                ? '🚀 Save Schedule & Start Auto-Post'
                                : '🚀 Run Post Now',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildImagePreviewList() {
    return Obx(
      () => controller.uploadedImages.isEmpty
          ? const Text(
              'No images selected.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            )
          : SizedBox(
              height: 75,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.uploadedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 75,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              'Img ${index + 1}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 18,
                          ),
                          onPressed: () => controller.removeImage(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
