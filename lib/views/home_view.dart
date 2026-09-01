import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_automation/controllers/home_controller.dart';
import 'package:social_media_automation/views/profile_view.dart';
import 'package:social_media_automation/widgets/smart_navigation_drawer.dart';
import 'auth_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      body: Obx(() => controller.pages[controller.currentIndex.value]),

      // Bottom Navigation Bar (মূল লজিক অপরিবর্তিত)
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.connect_without_contact_rounded),
              label: 'ai video',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flash_on_rounded),
              label: 'instant',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_fix_high_rounded),
              label: 'Automation',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
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

  // 🎯 সার্ভিস প্রমোশন ও ফিচার স্লাইড ডাটা
  final List<Map<String, String>> _adBanners = [
    {
      'title': 'Social Media Manager',
      'subtitle': 'Need an expert to handle your page & increase sales?',
      'buttonText': 'Explore Service',
      'imageColor': '0xFF6C63FF',
    },
    {
      'title': 'Video & Reels Editor',
      'subtitle': 'Professional editing for high-converting ads & reels.',
      'buttonText': 'See Samples',
      'imageColor': '0xFFFF6584',
    },
    {
      'title': 'Full Marketing Automation',
      'subtitle': 'Get auto-reply, orders & page management combined!',
      'buttonText': 'Get Started',
      'imageColor': '0xFF4361EE',
    },
  ];

  @override
  void initState() {
    super.initState();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_activeSlideIndex < _adBanners.length - 1) {
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

  void _handleBannerClick(String title) {
    Get.snackbar(
      'Service Selected',
      'Requesting details for: $title',
      backgroundColor: Colors.deepPurple,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Afraz Automation'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // ১. নোটিফিকেশন আইকন (প্রফাইলের বামে)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 26),
                onPressed: () {
                  // নোটিফিকেশন পেইজে যাওয়ার লজিক
                },
              ),
              // নোটিফিকেশন লাল ডট/ব্যাজ
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          // ২. প্রফাইল আইকন
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
      // Drawer Menu (মূল লজিক অপরিবর্তিত)
      drawer: const SmartNavigationDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //const SizedBox(height: 10),

            // 🎯 RenderFlex Error রোধে স্লাইডারের পর্যাপ্ত হাইট দেওয়া হলো
            SizedBox(
              height: 175,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _adBanners.length,
                onPageChanged: (index) {
                  setState(() {
                    _activeSlideIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final ad = _adBanners[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(int.parse(ad['imageColor']!)),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ad['subtitle']!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                            minimumSize: const Size(100, 34),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                          ),
                          onPressed: () => _handleBannerClick(ad['title']!),
                          child: Text(
                            ad['buttonText']!,
                            style: const TextStyle(
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
            const SizedBox(height: 8),
            // Slide Dot Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_adBanners.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _activeSlideIndex == index ? 12 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _activeSlideIndex == index
                        ? Colors.deepPurple
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // 🎯 ২. কুইক ওভারভিউ শর্টকাট
            const Text(
              'Quick Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _buildShortcutTile(
                  title: 'Orders',
                  count: '12 Today',
                  icon: Icons.shopping_bag,
                  color: Colors.blue,
                  onTap: () => Get.snackbar('Orders', 'Navigating to Orders'),
                ),
                _buildShortcutTile(
                  title: 'Messages',
                  count: '28 New',
                  icon: Icons.forum,
                  color: Colors.green,
                  onTap: () =>
                      Get.snackbar('Messages', 'Navigating to Messages'),
                ),
                _buildShortcutTile(
                  title: 'Likes & Comments',
                  count: '145 Total',
                  icon: Icons.thumb_up_alt,
                  color: Colors.orange,
                  onTap: () => Get.snackbar('Interactions', 'Showing Activity'),
                ),
                _buildShortcutTile(
                  title: 'Pending Leads',
                  count: '5 Action Req.',
                  icon: Icons.hourglass_top_rounded,
                  color: Colors.redAccent,
                  onTap: () =>
                      Get.snackbar('Pending', 'Navigating to Pending Leads'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🎯 ৩. সোশাল মিডিয়া পোস্ট পারফরম্যান্স স্ট্যাটিস্টিক্স
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
                    monthlyPosts: '85 Posts (30 Days)',
                    statusColor: const Color(0xFF1877F2),
                  ),
                  const Divider(height: 24),
                  _buildPerformanceRow(
                    platform: 'Instagram Business',
                    dailyPosts: '2 Posts',
                    monthlyPosts: '60 Posts (30 Days)',
                    statusColor: Colors.pink,
                  ),
                  const Divider(height: 24),
                  _buildPerformanceRow(
                    platform: 'YouTube Channel',
                    dailyPosts: '1 Video',
                    monthlyPosts: '12 Videos (30 Days)',
                    statusColor: Colors.red,
                  ),
                  const Divider(height: 24),
                  _buildPerformanceRow(
                    platform: 'TikTok Profile',
                    dailyPosts: '4 Videos',
                    monthlyPosts: '95 Videos (30 Days)',
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

  // Shortcut Tile Builder
  Widget _buildShortcutTile({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Performance Row Builder
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
              monthlyPosts,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
