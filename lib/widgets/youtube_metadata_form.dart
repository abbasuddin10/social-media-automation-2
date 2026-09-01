import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ai_video_controller.dart';

class YoutubeMetadataForm extends StatelessWidget {
  final AiVideoController controller;

  const YoutubeMetadataForm({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.video_library, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'YouTube Extra Metadata',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const Divider(),
            TextField(
              controller: controller.youtubeTitleController,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Video Title *',
                hintText: 'Enter YouTube video title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.youtubeDescController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Video Description',
                hintText: 'Detailed description for YouTube',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.youtubeTagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (Comma separated)',
                hintText: 'gaming, tech, flutter, ai',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.youtubePrivacy.value,
                decoration: const InputDecoration(
                  labelText: 'Privacy Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'public', child: Text('Public')),
                  DropdownMenuItem(value: 'unlisted', child: Text('Unlisted')),
                  DropdownMenuItem(value: 'private', child: Text('Private')),
                ],
                onChanged: (val) =>
                    controller.youtubePrivacy.value = val ?? 'public',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
