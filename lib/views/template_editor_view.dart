import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../controllers/automation_controller.dart';
import '../templates/template_factory.dart';

class TemplateEditorView extends StatefulWidget {
  final Map<String, dynamic> templateInfo;

  const TemplateEditorView({super.key, required this.templateInfo});

  @override
  State<TemplateEditorView> createState() => _TemplateEditorViewState();
}

class _TemplateEditorViewState extends State<TemplateEditorView> {
  final GlobalKey _canvasKey = GlobalKey();
  final AutomationController _automationController = Get.put(
    AutomationController(),
  );

  late TextEditingController titleCtrl;
  late TextEditingController subtitleCtrl;
  late TextEditingController offerPriceCtrl;
  late TextEditingController btnCtrl;

  // 🎯 ক্যাপশন ও AI প্রম্পটের জন্য টেক্সট কন্ট্রোলার
  final TextEditingController _customCaptionCtrl = TextEditingController();
  final TextEditingController _aiPromptCtrl = TextEditingController();
  bool _useAiCaption = false;
  bool _isGeneratingAi = false; // 👈 AI Generation Loading State

  // 🎛️ এডিটিং স্লাইডার এবং কালার অপশন
  double titleFontSize = 28.0;
  double logoSize = 40.0;
  double imageRadius = 110.0;

  Color topWaveColor = const Color(0xFF3B0764);
  Color bottomBaseColor = const Color(0xFFF97316);

  File? userSelectedImage;
  File? userSelectedLogo;
  final ImagePicker _picker = ImagePicker();
  bool isExporting = false;

  @override
  void initState() {
    super.initState();
    var data = widget.templateInfo['data'] ?? {};
    titleCtrl = TextEditingController(text: data['title'] ?? 'SPECIAL OFFER');
    subtitleCtrl = TextEditingController(
      text: data['subtitle'] ?? 'Best Quality Product',
    );
    offerPriceCtrl = TextEditingController(text: data['offer'] ?? '50% OFF');
    btnCtrl = TextEditingController(text: data['btn_text'] ?? 'SHOP NOW');

    // ডিফল্ট কাস্টম ক্যাপশন
    _customCaptionCtrl.text =
        "${titleCtrl.text} - ${subtitleCtrl.text}\nOffer: ${offerPriceCtrl.text}";
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    subtitleCtrl.dispose();
    offerPriceCtrl.dispose();
    btnCtrl.dispose();
    _customCaptionCtrl.dispose();
    _aiPromptCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickMainImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => userSelectedImage = File(picked.path));
  }

  Future<void> _pickLogoImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => userSelectedLogo = File(picked.path));
  }

  void _openColorPicker(Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Done'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // ক্যানভাস পিকচার ফাইল হিসেবে প্রস্তুত করার মেথড
  Future<File?> _captureCanvasToFile() async {
    try {
      RenderRepaintBoundary boundary =
          _canvasKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      double targetWidth = 1080.0;
      double pixelRatio = targetWidth / boundary.size.width;

      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/temp_post_${DateTime.now().millisecondsSinceEpoch}.png';
        File imgFile = File(filePath);
        return await imgFile.writeAsBytes(pngBytes);
      }
    } catch (e) {
      debugPrint("Canvas Capture Error: $e");
    }
    return null;
  }

  // 🎯 পোস্ট ডেমো প্রিভিউ, ক্যাপশন ও AI প্রম্পট বটম শিট
  void _showPublishModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Post Preview & Automation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 🖼️ ডেমো পোস্ট প্রিভিউ কার্ড
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 75,
                              height: 75,
                              child: userSelectedImage != null
                                  ? Image.file(
                                      userSelectedImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      widget.templateInfo['preview_image'],
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titleCtrl.text.isEmpty
                                      ? "Template Banner"
                                      : titleCtrl.text,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitleCtrl.text,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ✍️ ক্যাপশন মোড সিলেক্টর
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Caption Style:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Custom'),
                              selected: !_useAiCaption,
                              onSelected: (val) {
                                setModalState(() => _useAiCaption = false);
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('AI Prompt ✨'),
                              selected: _useAiCaption,
                              selectedColor: Colors.deepPurple[100],
                              onSelected: (val) {
                                setModalState(() => _useAiCaption = true);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (!_useAiCaption) ...[
                      TextField(
                        controller: _customCaptionCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'আপনার ক্যাপশন লিখুন...',
                          labelText: 'Custom Caption',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ] else ...[
                      // 🤖 AI Prompt Input
                      TextField(
                        controller: _aiPromptCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText:
                              'যেমন: Write an engaging promo caption with hashtags for this product',
                          labelText: 'AI Prompt for Caption',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.auto_awesome,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 🚀 AI Generate Button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton.icon(
                          onPressed: _isGeneratingAi
                              ? null
                              : () async {
                                  if (_aiPromptCtrl.text.trim().isEmpty) {
                                    Get.snackbar(
                                      "Warning",
                                      "দয়া করে প্রম্পট বা বিষয় লিখুন!",
                                      backgroundColor: Colors.amber[700],
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }

                                  setModalState(() => _isGeneratingAi = true);

                                  String? generatedCaption =
                                      await _automationController
                                          .generateAiCaption(
                                            _aiPromptCtrl.text,
                                          );

                                  setModalState(() => _isGeneratingAi = false);

                                  if (generatedCaption != null) {
                                    setModalState(() {
                                      _customCaptionCtrl.text =
                                          generatedCaption;
                                      _useAiCaption =
                                          false; // ক্যাপশন বক্সে নিয়ে যাওয়া হলো
                                    });
                                    Get.snackbar(
                                      "Success",
                                      "ক্যাপশন তৈরি হয়েছে!",
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );
                                  } else {
                                    Get.snackbar(
                                      "Error",
                                      "ক্যাপশন জেনারেট করতে সমস্যা হয়েছে!",
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                          icon: _isGeneratingAi
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.bolt, color: Colors.white),
                          label: Text(
                            _isGeneratingAi
                                ? 'Generating Caption...'
                                : 'Generate Caption with AI',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    const Text(
                      'Select Target Platforms:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    Obx(
                      () => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Facebook Page'),
                        value: _automationController.postToFacebook.value,
                        onChanged: (val) =>
                            _automationController.postToFacebook.value = val!,
                        activeColor: Colors.deepPurple,
                      ),
                    ),
                    Obx(
                      () => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Instagram Business'),
                        value: _automationController.postToInstagram.value,
                        onChanged: (val) =>
                            _automationController.postToInstagram.value = val!,
                        activeColor: Colors.deepPurple,
                      ),
                    ),
                    Obx(
                      () => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Pinterest Profile'),
                        value: _automationController.postToPinterest.value,
                        onChanged: (val) =>
                            _automationController.postToPinterest.value = val!,
                        activeColor: Colors.deepPurple,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // আপলোড বাটন
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Obx(
                        () => ElevatedButton.icon(
                          icon: const Icon(Icons.upload),
                          label: const Text('Upload Post'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _automationController.isLoading.value
                              ? null
                              : () async {
                                  Navigator.pop(context);

                                  File? capturedFile =
                                      await _captureCanvasToFile();

                                  if (capturedFile != null) {
                                    String selectedMode = _useAiCaption
                                        ? 'ai_agent'
                                        : 'manual';
                                    String finalContent = _useAiCaption
                                        ? _aiPromptCtrl.text
                                        : _customCaptionCtrl.text;

                                    await _automationController
                                        .publishTemplatePost(
                                          imageFile: capturedFile,
                                          mode: selectedMode,
                                          content: finalContent,
                                          facebook: _automationController
                                              .postToFacebook
                                              .value,
                                          instagram: _automationController
                                              .postToInstagram
                                              .value,
                                          pinterest: _automationController
                                              .postToPinterest
                                              .value,
                                        );
                                  }
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String layoutType = widget.templateInfo['layout_type'];
    String defaultTemplateImage = widget.templateInfo['preview_image'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.templateInfo['category']}'),
        centerTitle: true,
        actions: [
          isExporting
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.download_rounded, size: 26),
                  tooltip: 'Save Image',
                  onPressed: () async {
                    setState(() => isExporting = true);
                    File? img = await _captureCanvasToFile();
                    if (img != null) {
                      await Gal.putImage(img.path);
                      if (mounted) {
                        Get.snackbar(
                          "Success",
                          "Gallery-তে সেভ হয়েছে!",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      }
                    }
                    setState(() => isExporting = false);
                  },
                ),
        ],
      ),
      body: Column(
        children: [
          // 🖼️ ১. ক্যানভাস প্রিভিউ
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 12.0,
            ),
            color: const Color(0xFFF1F5F9),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.36,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: RepaintBoundary(
                      key: _canvasKey,
                      child: Container(
                        color: Colors.white,
                        child: TemplateFactory.buildTemplate(
                          layoutType: layoutType,
                          title: titleCtrl.text,
                          subtitle: subtitleCtrl.text,
                          offer: offerPriceCtrl.text,
                          btnText: btnCtrl.text,
                          titleFontSize: titleFontSize,
                          logoSize: logoSize,
                          imageRadius: imageRadius,
                          topColor: topWaveColor,
                          bottomColor: bottomBaseColor,
                          mainImage: userSelectedImage != null
                              ? FileImage(userSelectedImage!)
                              : AssetImage(defaultTemplateImage)
                                    as ImageProvider,
                          logoImage: userSelectedLogo != null
                              ? FileImage(userSelectedLogo!)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🎛️ ২. সম্পূর্ণ এডিটিং কন্ট্রোলস (Sliders, Colors, Text Input)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ইমেজ ও লোগো পরিবর্তনের বাটন
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickMainImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Change Image'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickLogoImage,
                          icon: const Icon(Icons.stars),
                          label: const Text('Change Logo'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // কালার পিকিং বাটন
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _openColorPicker(topWaveColor, (color) {
                                setState(() => topWaveColor = color);
                              }),
                          icon: Icon(Icons.color_lens, color: topWaveColor),
                          label: const Text('Top Color'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _openColorPicker(bottomBaseColor, (color) {
                                setState(() => bottomBaseColor = color);
                              }),
                          icon: Icon(Icons.color_lens, color: bottomBaseColor),
                          label: const Text('Bottom Color'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // স্লাইডারসমূহ (Font, Image Size, Logo Size)
                  Text(
                    'Title Font Size: ${titleFontSize.toInt()}px',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: titleFontSize,
                    min: 16.0,
                    max: 48.0,
                    onChanged: (v) => setState(() => titleFontSize = v),
                  ),

                  Text(
                    'Image Size: ${imageRadius.toInt()}px',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: imageRadius,
                    min: 60.0,
                    max: 150.0,
                    onChanged: (v) => setState(() => imageRadius = v),
                  ),

                  Text(
                    'Logo Size: ${logoSize.toInt()}px',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: logoSize,
                    min: 20.0,
                    max: 70.0,
                    onChanged: (v) => setState(() => logoSize = v),
                  ),

                  const SizedBox(height: 10),

                  // টেক্সট ফিল্ডসমূহ
                  TextField(
                    controller: titleCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: subtitleCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Subtitle',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: offerPriceCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Offer Badge',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: btnCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Button Text',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🚀 পোস্ট পপআপ খোলার ফাইনাল বাটন
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: _showPublishModal,
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text(
                        'CONTINUE TO POST',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
