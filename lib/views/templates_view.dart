import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'template_editor_view.dart';

class TemplatesView extends StatefulWidget {
  const TemplatesView({super.key});

  @override
  State<TemplatesView> createState() => _TemplatesViewState();
}

class _TemplatesViewState extends State<TemplatesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ---------------- READY-MADE TAB STATE ----------------
  String selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final List<String> categories = ['All', 'Food', 'Real Estate', 'Tech'];

  final List<Map<String, dynamic>> templatesList = [
    {
      'id': 'food_01',
      'category': 'Food',
      'title': 'Delicious Food Menu',
      'layout_type': 'food_purple_curved',
      'preview_image': 'assets/images/sample1.jpg',
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
      'preview_image': 'assets/images/sample2.jpg',
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
      'preview_image': 'assets/images/sample3.jpg',
      'data': {
        'title': 'HOME',
        'subtitle': 'Modern',
        'status': 'For SALE',
        'price': '\$ 2,00,000.00',
        'phone': '1234 567 890',
      },
    },
  ];

  // ---------------- AI GENERATE TAB STATE ----------------
  File? _userUploadedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _aiPromptCtrl = TextEditingController();

  bool _isGenerating = false;
  bool _hasGenerated = false;

  // AI Captions Controllers for Editable Text
  final TextEditingController _fbCaptionCtrl = TextEditingController();
  final TextEditingController _instaCaptionCtrl = TextEditingController();
  final TextEditingController _linkedinCaptionCtrl = TextEditingController();
  final TextEditingController _pinterestCaptionCtrl = TextEditingController();

  // Social Media Checkbox Selection (YouTube Excluded)
  bool postToFacebook = true;
  bool postToInstagram = true;
  bool postToLinkedIn = false;
  bool postToPinterest = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _aiPromptCtrl.dispose();
    _fbCaptionCtrl.dispose();
    _instaCaptionCtrl.dispose();
    _linkedinCaptionCtrl.dispose();
    _pinterestCaptionCtrl.dispose();
    super.dispose();
  }

  // Pick User Image
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _userUploadedImage = File(image.path);
      });
    }
  }

  // Simulate AI Generation
  void _generateAiDesign() async {
    if (_userUploadedImage == null && _aiPromptCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Warning',
        'দয়া করে একটি ছবি আপলোড করুন অথবা প্রম্পট লিখুন!',
        backgroundColor: Colors.amber[800],
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isGenerating = false;
      _hasGenerated = true;

      String prompt = _aiPromptCtrl.text.isNotEmpty
          ? _aiPromptCtrl.text
          : "Special Promo Design";
      _fbCaptionCtrl.text =
          "🔥 Special Offer! $prompt\nGet up to 50% off on all items today! Order now. #Promo #Deal";
      _instaCaptionCtrl.text =
          "✨ $prompt ✨\nDon't miss out on our exciting discount! 🚀\n.\n.\n#Brand #Trending #Offer";
      _linkedinCaptionCtrl.text =
          "Exciting news! We are launching our latest banner campaign: '$prompt'. Innovation meets design.";
      _pinterestCaptionCtrl.text =
          "Check out this amazing design idea for $prompt! Saved for inspiration. 📌";
    });

    Get.snackbar(
      'Success 🎉',
      'AI ডিজাইন ও ক্যাপশন তৈরি সম্পন্ন হয়েছে!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _deleteGenerated() {
    setState(() {
      _hasGenerated = false;
      _aiPromptCtrl.clear();
      _fbCaptionCtrl.clear();
      _instaCaptionCtrl.clear();
      _linkedinCaptionCtrl.clear();
      _pinterestCaptionCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Design & Studio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.deepPurple,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI Generate'),
            Tab(icon: Icon(Icons.grid_view_rounded), text: 'Ready-made'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAiGenerateTab(), _buildReadymadeTab()],
      ),
    );
  }

  // ==================== 1. AI GENERATE TAB ====================
  Widget _buildAiGenerateTab() {
    // অন্তত একটি প্ল্যাটফর্ম সিলেক্ট করা আছে কিনা চেক
    bool isAnyPlatformSelected =
        postToFacebook || postToInstagram || postToLinkedIn || postToPinterest;

    // সব সিলেক্ট করা আছে কিনা চেক
    bool isAllSelected =
        postToFacebook && postToInstagram && postToLinkedIn && postToPinterest;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📸 1. Image Upload Section
          const Text(
            '1. Upload Image (Optional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.shade100, width: 2),
              ),
              child: _userUploadedImage != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            _userUploadedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 45,
                          color: Colors.deepPurple.shade300,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap to upload product or custom image',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // ✍️ 2. AI Prompt Input
          const Text(
            '2. Describe Your Concept (Prompt)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _aiPromptCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'e.g., Create a modern offer banner for a burger combo with vibrant purple lighting...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 🚀 Generate Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateAiDesign,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _isGenerating
                    ? 'AI Generating Design...'
                    : 'Generate Design & Captions',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 🎨 3. Generated Image Preview & Controls
          if (_hasGenerated) ...[
            const Text(
              'Generated Design Preview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: _userUploadedImage != null
                        ? Image.file(
                            _userUploadedImage!,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 200,
                            color: Colors.deepPurple.shade50,
                            child: const Center(
                              child: Icon(
                                Icons.auto_awesome,
                                size: 80,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _generateAiDesign,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.deepPurple,
                          ),
                          label: const Text(
                            'Re-generate',
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.deepPurple),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: _deleteGenerated,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 📝 4. Auto-generated Editable Captions
            const Text(
              'AI Captions for Social Media',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildCaptionCard(
              'Facebook Caption',
              Icons.facebook,
              Colors.blue,
              _fbCaptionCtrl,
            ),
            _buildCaptionCard(
              'Instagram Caption',
              Icons.camera_alt,
              Colors.pink,
              _instaCaptionCtrl,
            ),
            _buildCaptionCard(
              'LinkedIn Caption',
              Icons.work,
              Colors.blue.shade800,
              _linkedinCaptionCtrl,
            ),
            _buildCaptionCard(
              'Pinterest Caption',
              Icons.pin_drop,
              Colors.red,
              _pinterestCaptionCtrl,
            ),

            const SizedBox(height: 20),

            // 🌐 5. Target Platforms Header with Select All
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Target Platforms',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // 🎯 Select All Checkbox Widget
                Row(
                  children: [
                    Checkbox(
                      value: isAllSelected,
                      activeColor: Colors.deepPurple,
                      onChanged: (val) {
                        bool value = val ?? false;
                        setState(() {
                          postToFacebook = value;
                          postToInstagram = value;
                          postToLinkedIn = value;
                          postToPinterest = value;
                        });
                      },
                    ),
                    const Text(
                      'Select All',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Facebook'),
                    value: postToFacebook,
                    activeColor: Colors.deepPurple,
                    onChanged: (val) => setState(() => postToFacebook = val!),
                  ),
                  CheckboxListTile(
                    title: const Text('Instagram'),
                    value: postToInstagram,
                    activeColor: Colors.deepPurple,
                    onChanged: (val) => setState(() => postToInstagram = val!),
                  ),
                  CheckboxListTile(
                    title: const Text('LinkedIn'),
                    value: postToLinkedIn,
                    activeColor: Colors.deepPurple,
                    onChanged: (val) => setState(() => postToLinkedIn = val!),
                  ),
                  CheckboxListTile(
                    title: const Text('Pinterest'),
                    value: postToPinterest,
                    activeColor: Colors.deepPurple,
                    onChanged: (val) => setState(() => postToPinterest = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 📤 6. Conditional Post Now Button (Visible only if at least 1 platform is selected)
            if (isAnyPlatformSelected) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Publishing 🚀',
                      'আপনার পোস্টটি সোশ্যাল প্ল্যাটফর্মগুলোতে সাবমিট করা হচ্ছে...',
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'POST NOW',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ],
        ],
      ),
    );
  }

  // ==================== 2. READY-MADE TAB ====================
  Widget _buildReadymadeTab() {
    final filtered = templatesList.where((tpl) {
      final matchesCategory =
          selectedCategory == 'All' || tpl['category'] == selectedCategory;
      final matchesSearch = tpl['title'].toString().toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();

    return Column(
      children: [
        // 🔎 Search Field
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search templates...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // 🏷️ Category Filter Chips
        Container(
          color: Colors.white,
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: Colors.deepPurple,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  backgroundColor: Colors.grey[200],
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (_) => setState(() => selectedCategory = cat),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // 🔲 Templates Grid
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No templates found!',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final tpl = filtered[index];
                    return GestureDetector(
                      onTap: () =>
                          Get.to(() => TemplateEditorView(templateInfo: tpl)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(
                                      tpl['preview_image'],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.image,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          tpl['category'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
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
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Caption Editing Helper Card Widget
  Widget _buildCaptionCard(
    String platformTitle,
    IconData icon,
    Color color,
    TextEditingController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  platformTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
