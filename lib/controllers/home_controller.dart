import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_media_automation/views/ai_video_view.dart';
import 'package:social_media_automation/views/automation_view.dart';
import 'package:social_media_automation/views/home_view.dart'; // 🎯 HomeDashboardContent এর জন্য ইম্পোর্ট
import 'package:social_media_automation/views/instant_post_view.dart';
import 'package:social_media_automation/views/templates_view.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;

  final List<Widget> pages = [
    const HomeDashboardContent(),
    const AiVideoView(),
    const InstantPostView(),
    AutomationView(),
    const TemplatesView(),
  ];

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
