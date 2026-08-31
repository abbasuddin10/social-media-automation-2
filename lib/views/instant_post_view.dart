import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:social_media_automation/controllers/accounts_view_controller.dart';
import 'package:social_media_automation/controllers/accounts_view_controller.dart';
import '../controllers/instant_post_controller.dart';

class InstantPostView extends GetView<InstantPostController> {
  const InstantPostView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(InstantPostController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instant Post'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _ImagePickerSection(),
                        const SizedBox(height: 16),
                        const _ModeToggleSection(),
                        const SizedBox(height: 16),
                        const _InputSection(),
                        const SizedBox(height: 16),
                        const _AccountSelectorSection(),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: _PublishButtonSection(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ImagePickerSection extends GetView<InstantPostController> {
  const _ImagePickerSection();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
        onTap: controller.captureImageFromCamera,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: controller.selectedImage.value != null
                  ? Colors.deepPurple
                  : Colors.deepPurple.shade200,
              width: 1.5,
            ),
          ),
          child: controller.selectedImage.value != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        controller.selectedImage.value!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.green,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.cameraswitch,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: controller.captureImageFromCamera,
                        ),
                      ),
                    ),
                  ],
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_rounded,
                      size: 40,
                      color: Colors.deepPurple,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to Capture Photo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ModeToggleSection extends GetView<InstantPostController> {
  const _ModeToggleSection();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SegmentedButton<bool>(
        segments: const [
          ButtonSegment<bool>(
            value: false,
            label: Text('Manual'),
            icon: Icon(Icons.edit_note),
          ),
          ButtonSegment<bool>(
            value: true,
            label: Text('AI Mode'),
            icon: Icon(Icons.auto_awesome),
          ),
        ],
        selected: {controller.isAiMode.value},
        onSelectionChanged: (Set<bool> newSelection) {
          controller.isAiMode.value = newSelection.first;
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class _InputSection extends GetView<InstantPostController> {
  const _InputSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isAiMode.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller.promptInputController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'AI Prompt',
                hintText: 'Describe your topic...',
                prefixIcon: const Icon(
                  Icons.psychology,
                  color: Colors.deepPurple,
                ),
                suffixIcon: IconButton(
                  icon: controller.isLoadingAi.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.deepPurple,
                        ),
                  onPressed: controller.isLoadingAi.value
                      ? null
                      : controller.generateWithAi,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (controller.captionText.value.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Generated Output:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.refresh,
                          size: 18,
                          color: Colors.deepPurple,
                        ),
                        onPressed: controller.isLoadingAi.value
                            ? null
                            : controller.regenerateWithAi,
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.red,
                        ),
                        onPressed: controller.clearCaption,
                      ),
                    ],
                  ),
                ],
              ),
              TextField(
                controller: controller.captionInputController,
                maxLines: 3,
                onChanged: (val) => controller.captionText.value = val,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        );
      }

      return Column(
        children: [
          TextField(
            controller: controller.captionInputController,
            maxLines: 3,
            onChanged: (val) => controller.captionText.value = val,
            decoration: InputDecoration(
              labelText: 'Caption',
              hintText: 'Write caption...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller.hashtagInputController,
            onChanged: (val) => controller.hashtagText.value = val,
            decoration: InputDecoration(
              labelText: 'Hashtags',
              hintText: '#trending #nature',
              prefixIcon: const Icon(Icons.tag, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _AccountSelectorSection extends GetView<InstantPostController> {
  const _AccountSelectorSection();

  bool _getIsConnected(String key, AccountsViewController accountsCtrl) {
    switch (key) {
      case 'facebook':
        return accountsCtrl.isFacebookConnected.value;
      case 'instagram':
        return accountsCtrl.isInstagramConnected.value;
      case 'youtube':
        return accountsCtrl.isYoutubeConnected.value;
      case 'linkedin':
        return accountsCtrl.isLinkedinConnected.value;
      case 'twitter':
        return accountsCtrl.isTwitterConnected.value;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsCtrl = controller.accountsController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          int totalConnected = 0;
          if (accountsCtrl.isFacebookConnected.value) totalConnected++;
          if (accountsCtrl.isInstagramConnected.value) totalConnected++;
          if (accountsCtrl.isYoutubeConnected.value) totalConnected++;
          if (accountsCtrl.isLinkedinConnected.value) totalConnected++;
          if (accountsCtrl.isTwitterConnected.value) totalConnected++;

          bool isAllSelected =
              controller.selectedAccounts.length == totalConnected &&
              totalConnected > 0;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Target Platforms',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () =>
                    controller.toggleSelectAllAccounts(!isAllSelected),
                icon: Icon(
                  isAllSelected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 18,
                  color: Colors.deepPurple,
                ),
                label: const Text('Select All', style: TextStyle(fontSize: 12)),
              ),
            ],
          );
        }),
        Obx(
          () => Wrap(
            spacing: 6.0,
            runSpacing: -4.0,
            children: controller.connectedAccounts.map((acc) {
              final String key = acc['key']!;
              final String platformName = acc['platform']!;
              final isConnected = _getIsConnected(key, accountsCtrl);
              final isSelected = controller.selectedAccounts.contains(key);

              return FilterChip(
                visualDensity: VisualDensity.compact,
                avatar: !isConnected
                    ? const Icon(Icons.lock, size: 12, color: Colors.grey)
                    : null,
                label: Text(platformName, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                selectedColor: Colors.deepPurple.shade100,
                checkmarkColor: Colors.deepPurple,
                onSelected: (_) => controller.toggleAccountSelection(
                  key,
                  isConnected,
                  platformName,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PublishButtonSection extends GetView<InstantPostController> {
  const _PublishButtonSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isReadyToPost =
          controller.selectedImage.value != null &&
          controller.selectedAccounts.isNotEmpty;

      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isReadyToPost
                ? Colors.deepPurple
                : Colors.grey.shade300,
            foregroundColor: isReadyToPost
                ? Colors.white
                : Colors.grey.shade600,
            elevation: isReadyToPost ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: isReadyToPost && !controller.isLoading.value
              ? controller.publishPost
              : null,
          icon: controller.isLoading.value
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.rocket_launch, size: 20),
          label: Text(
            controller.isLoading.value ? 'Publishing...' : 'One Click Publish',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      );
    });
  }
}
