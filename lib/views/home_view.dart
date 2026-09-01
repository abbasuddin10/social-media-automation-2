import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_automation/views/ai_video_view.dart';
import 'package:social_media_automation/views/automation_agent_view.dart';
import 'package:social_media_automation/views/automation_view.dart';
import 'package:social_media_automation/views/instant_post_view.dart';
import 'package:social_media_automation/views/profile_view.dart';
import 'package:social_media_automation/views/templates_view.dart'; // 🎯 নতুন ইম্পোর্ট
import 'auth_view.dart';

// 🎯 Instant ট্যাবের জন্য প্লেসহোল্ডার ভিউ
class InstantView extends StatelessWidget {
  const InstantView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Instant Page',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class HomeController extends GetxController {
  var currentIndex = 0.obs;

  final List<Widget> pages = [
    const HomeDashboardContent(),
    const AiVideoView(),
    const InstantPostView(), // 🎯 ঠিক মাঝামাঝি যুক্ত করা Instant ভিউ (Index 2)
    AutomationView(),
    const TemplatesView(), // 🎯 প্রোফাইলের জায়গায় নতুন টেমপ্লেট ভিউ
  ];

  void changeTab(int index) {
    currentIndex.value = index;
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      body: Obx(() => controller.pages[controller.currentIndex.value]),

      // Bottom Navigation Bar with 5 Buttons
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.connect_without_contact_rounded),
              label:
                  'ai video', // 🎯 ai posts এর জায়গায় ai video আপডেট করা হয়েছে
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.flash_on_rounded,
              ), // 🎯 ঠিক মাঝামাঝি Instant ট্যাব যুক্ত করা হয়েছে
              label: 'instant',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_fix_high_rounded),
              label: 'Automation',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), // 🎯 টেমপ্লেটের নতুন আইকন
              label: 'Templates',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeDashboardContent extends StatefulWidget {
  const HomeDashboardContent({super.key});

  @override
  State<HomeDashboardContent> createState() => _HomeDashboardContentState();
}

class _HomeDashboardContentState extends State<HomeDashboardContent> {
  final PageController _pageController = PageController();
  int _activeSlideIndex = 0;
  Timer? _autoSlideTimer;

  // 5 Sliding Design Templates (Ready to Post)
  final List<Map<String, String>> _slideDesigns = [
    {
      'title': 'Discount Offer Post',
      'subtitle': 'Special 20% discount on all products!',
      'imageColor': '0xFF6C63FF',
    },
    {
      'title': 'New Video Alert',
      'subtitle': 'Check out our new tutorial on YouTube.',
      'imageColor': '0xFFFF6584',
    },
    {
      'title': 'Festive Greetings',
      'subtitle': 'Warm wishes to everyone on this occasion!',
      'imageColor': '0xFF4361EE',
    },
    {
      'title': 'Daily Motivation',
      'subtitle': 'Make today count and achieve your goals.',
      'imageColor': '0xFF2EC4B6',
    },
    {
      'title': 'Product Showcase',
      'subtitle': 'Explore our best professional services.',
      'imageColor': '0xFFFF9F1C',
    },
  ];

  @override
  void initState() {
    super.initState();
    // অটো স্লাইড টাইমার সেটআপ (প্রতি ৪ সেকেন্ড পরপর স্লাইড চেঞ্জ হবে)
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_activeSlideIndex < _slideDesigns.length - 1) {
        _activeSlideIndex++;
      } else {
        _activeSlideIndex = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _activeSlideIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAll(() => const AuthView());
  }

  // Direct Post Function
  void _postDesign(String designTitle) {
    Get.snackbar(
      'Success',
      "'$designTitle' successfully posted to social media!",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Automation'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.deepPurple, size: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileView()),
              );
            },
          ),
        ],
      ),

      // Drawer Menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text(
                'Automation User',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text('user@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
              ),
              decoration: BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.deepPurple),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ready-made Design Templates (Auto-sliding Banner)
            const Text(
              'Ready-Made Design Templates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slideDesigns.length,
                onPageChanged: (index) {
                  setState(() {
                    _activeSlideIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final design = _slideDesigns[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(int.parse(design['imageColor']!)),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          design['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          design['subtitle']!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                          ),
                          onPressed: () => _postDesign(design['title']!),
                          child: const Text(
                            'Post Now',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Slide Dot Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slideDesigns.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _activeSlideIndex == index ? 12 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _activeSlideIndex == index
                        ? Colors.deepPurple
                        : Colors.grey.shade400,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // 2. Overview Section
            const Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Connected Accounts',
                    value: '4',
                    icon: Icons.link,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Active Automations',
                    value: '2',
                    icon: Icons.smart_toy,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Business Performance & Post Statistics
            const Text(
              'Business Performance & Post Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildPerformanceRow(
                    platform: 'Facebook Page',
                    dailyPosts: '3 Posts',
                    monthlyPosts: '85 Posts',
                    statusColor: Colors.blue,
                  ),
                  const Divider(height: 24),
                  _buildPerformanceRow(
                    platform: 'Instagram Business',
                    dailyPosts: '2 Posts',
                    monthlyPosts: '60 Posts',
                    statusColor: Colors.pink,
                  ),
                  const Divider(height: 24),
                  _buildPerformanceRow(
                    platform: 'YouTube Channel',
                    dailyPosts: '1 Video',
                    monthlyPosts: '12 Videos',
                    statusColor: Colors.red,
                  ),
                  const Divider(height: 24),
                  _buildPerformanceRow(
                    platform: 'TikTok Profile',
                    dailyPosts: '4 Videos',
                    monthlyPosts: '95 Videos',
                    statusColor: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Stat Card Widget
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Performance Row Widget
  Widget _buildPerformanceRow({
    required String platform,
    required String dailyPosts,
    required String monthlyPosts,
    required Color statusColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  platform,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Today: $dailyPosts',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Monthly: $monthlyPosts',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
