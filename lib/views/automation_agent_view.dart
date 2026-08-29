import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ai_agent_controller.dart';

class AutomationAgentView extends StatelessWidget {
  const AutomationAgentView({super.key});

  @override
  Widget build(BuildContext context) {
    final AIAgentController controller = Get.put(AIAgentController());

    return SingleChildScrollView(
      // padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎯 1. AI Command Box with Refresh Button
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text(
                            'AI Assistant Agent',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () => controller.fetchAllScheduledPosts(),
                        tooltip: 'Refresh Scheduled Posts',
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  //const SizedBox(height: 5),
                  TextField(
                    controller: controller.aiPromptController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'যেকোনো কমান্ড লিখুন...\n• "আগামী ৭ দিনের জন্য টেক পোস্ট রেডি করো"\n• "আজকে এখনই একটা আইফোন নিয়ে পোস্ট দাও"\n• "আগের সব পোস্ট ডিলিট করো"',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: Obx(
                      () => ElevatedButton.icon(
                        onPressed: controller.isAnalyzing.value
                            ? null
                            : () => controller.processUserInstruction(
                                controller.aiPromptController.text,
                              ),
                        icon: controller.isAnalyzing.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.bolt_rounded),
                        label: Text(
                          controller.isAnalyzing.value
                              ? 'AI Is Planning...'
                              : 'Execute Instruction',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🎯 2. Generated Plan Preview (Click to Edit)
          Obx(() {
            if (controller.generatedRule.isEmpty) return const SizedBox();

            final plan = controller.generatedRule;
            final List posts = plan['posts'] ?? [];
            final String intent = plan['intent'] ?? 'CREATE_POSTS';

            return Card(
              color: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.deepPurple.shade200, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "📌 ${plan['intent_summary'] ?? 'Generated AI Plan'}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => controller.generatedRule.clear(),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    if (intent == 'DELETE_POSTS') ...[
                      const Text(
                        "⚠️ এই কমান্ড এক্সিকিউট করলে ডাটাবেসে থাকা আগের সকল পেন্ডিং পোস্ট মুছে যাবে।",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (posts.isNotEmpty) ...[
                      const Text(
                        "💡 ক্লিক করে এডিট করুন",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          var post = posts[index];
                          List platforms = post['platforms'] ?? [];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _showManagePostBottomSheet(
                                context,
                                controller,
                                post,
                                isPreview: true,
                                index: index,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Chip(
                                          label: Text(
                                            "Day ${post['day_number'] ?? (index + 1)}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Colors.deepPurple,
                                          padding: EdgeInsets.zero,
                                        ),
                                        Text(
                                          post['scheduled_at'] ?? 'Instant',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      post['content'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text(
                                          "Target: ",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Wrap(
                                          spacing: 4,
                                          children: platforms
                                              .map<Widget>(
                                                (p) => Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    p.toString().toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.savePlanToDB(),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: Text(
                          intent == 'DELETE_POSTS'
                              ? 'Confirm Delete'
                              : 'Confirm & Save (${posts.length}) Posts',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: intent == 'DELETE_POSTS'
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // 🎯 3. Live Active Scheduled Posts Grid/List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📅 Active Scheduled Posts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Obx(
                () => Text(
                  '${controller.scheduledPosts.length} Active',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Obx(() {
            if (controller.isFetchingPosts.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.scheduledPosts.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ডাটাবেসে কোনো একটিভ বা শিডিউল করা পোস্ট নেই।',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.scheduledPosts.length,
              itemBuilder: (context, index) {
                final item = controller.scheduledPosts[index];
                List platforms =
                    item['platforms'] ?? ['facebook', 'instagram', 'pinterest'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showManagePostBottomSheet(
                      context,
                      controller,
                      item,
                      isPreview: false,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['scheduled_at'] ?? 'Instant',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['content'] ?? 'No Caption',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                "Accounts: ",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Wrap(
                                spacing: 4,
                                children: platforms
                                    .map<Widget>(
                                      (plat) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple.shade50,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          plat.toString().toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  // 🎯 Manage (Edit/Delete/Accounts) BottomSheet
  void _showManagePostBottomSheet(
    BuildContext context,
    AIAgentController controller,
    dynamic item, {
    required bool isPreview,
    int? index,
  }) {
    TextEditingController editController = TextEditingController(
      text: item['content'],
    );
    List currentPlatforms = List.from(item['platforms'] ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 20,
              left: 16,
              right: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "⚙️ Manage Post",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                        if (isPreview) {
                          List posts = controller.generatedRule['posts'];
                          posts.removeAt(index!);
                          controller.generatedRule.refresh();
                        } else {
                          controller.deleteSinglePost(item['id'].toString());
                        }
                      },
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                const Text(
                  "📝 Post Caption",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: editController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Edit your caption here...",
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "📱 Select Target Accounts",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 10,
                  children: ['facebook', 'instagram', 'pinterest'].map((
                    platform,
                  ) {
                    return FilterChip(
                      label: Text(
                        platform.toUpperCase(),
                        style: const TextStyle(fontSize: 11),
                      ),
                      selected: currentPlatforms.contains(platform),
                      selectedColor: Colors.deepPurple.shade100,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            currentPlatforms.add(platform);
                          } else {
                            currentPlatforms.remove(platform);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (isPreview) {
                        item['content'] = editController.text;
                        item['platforms'] = currentPlatforms;
                        controller.generatedRule.refresh();
                      } else {
                        await controller.updateSinglePost(
                          postId: item['id'],
                          updatedContent: editController.text,
                          platforms: currentPlatforms.cast<String>(),
                        );
                      }
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Save Changes"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
