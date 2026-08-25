import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'template_editor_view.dart';

class TemplatesView extends StatefulWidget {
  const TemplatesView({super.key});

  @override
  State<TemplatesView> createState() => _TemplatesViewState();
}

class _TemplatesViewState extends State<TemplatesView> {
  String selectedCategory = 'All';

  final List<String> categories = ['All', 'Food', 'Real Estate', 'Tech'];

  // 📦 আপনার ২০টি টেমপ্লেট ইমেজের লিস্ট
  final List<Map<String, dynamic>> templatesList = [
    {
      'id': 'food_01',
      'category': 'Food',
      'title': 'Delicious Food Menu',
      'layout_type': 'food_purple_curved',
      'preview_image': 'assets/images/sample1.jpg', // 👈 আপনার দেওয়া ইমেজের পাথ
      'data': {
        'title': 'FOOD MENU',
        'subtitle': 'Delicious',
        'offer': '50% OFF',
        'btn_text': 'ORDER NOW',
      },
    },
    {
      'id': 'food_02',
      'category': 'Food',
      'title': 'Healthy Vegetable Salad',
      'layout_type': 'food_green_salad',
      'preview_image': 'assets/images/sample2.jpg', // 👈 আপনার দেওয়া ইমেজের পাথ
      'data': {
        'title': 'SALAD',
        'subtitle': 'Healthy Vegetable',
        'offer': 'ONLY \$5',
        'btn_text': 'ORDER NOW',
        'phone': '00 123 123 1234',
      },
    },
    {
      'id': 'real_01',
      'category': 'Real Estate',
      'title': 'Modern Home For Sale',
      'layout_type': 'real_estate_curve',
      'preview_image': 'assets/images/sample3.jpg', // 👈 আপনার দেওয়া ইমেজের পাথ
      'data': {
        'title': 'HOME',
        'subtitle': 'Modern',
        'status': 'For SALE',
        'price': '\$ 2,00,000.00',
        'phone': '1234 567 890',
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCategory == 'All'
        ? templatesList
        : templatesList
              .where((e) => e['category'] == selectedCategory)
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Templates'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 🏷️ Category Selection Bar
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedCategory = cat),
                  ),
                );
              },
            ),
          ),

          // 🔲 Templates Grid (এখানে আপনার দেওয়া আসল ইমেজ শো করবে)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final tpl = filtered[index];
                return GestureDetector(
                  onTap: () =>
                      Get.to(() => TemplateEditorView(templateInfo: tpl)),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 🖼️ আপনার আসল টেমপ্লেট প্রিভিউ ইমেজ
                        Expanded(
                          child: Image.asset(
                            tpl['preview_image'],
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            tpl['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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
