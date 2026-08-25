import 'package:flutter/material.dart';

class FoodPurpleCurvedTemplate extends StatelessWidget {
  final String title;
  final String subtitle;
  final String offer;
  final String btnText;
  final double titleFontSize;
  final double logoSize;
  final double imageRadius;
  final Color topColor;
  final Color bottomColor;
  final ImageProvider? mainImage;
  final ImageProvider? logoImage;

  const FoodPurpleCurvedTemplate({
    super.key,
    required this.title,
    required this.subtitle,
    required this.offer,
    required this.btnText,
    required this.titleFontSize,
    this.logoSize = 40.0,
    this.imageRadius = 110.0,
    required this.topColor,
    required this.bottomColor,
    this.mainImage,
    this.logoImage,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        return Stack(
          children: [
            // 1. Base Bottom Color
            Positioned.fill(child: Container(color: bottomColor)),

            // 2. Top Curved Wave Shape
            Positioned.fill(
              child: ClipPath(
                clipper: BottomWaveClipper(),
                child: Container(color: topColor),
              ),
            ),

            // 3. Logo Header
            Positioned(
              top: height * 0.03,
              left: width * 0.04,
              child: logoImage != null
                  ? Image(
                      image: logoImage!,
                      height: logoSize,
                      fit: BoxFit.contain,
                    )
                  : Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          color: Colors.amber,
                          size: logoSize * 0.7,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'BRAND',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: logoSize * 0.4,
                          ),
                        ),
                      ],
                    ),
            ),

            // 4. Title & Subtitle Section
            Positioned(
              top: height * 0.02,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            // 5. Main Food Image Circle
            Positioned(
              top: height * 0.22,
              left: 0,
              right: 0,
              child: Center(
                child: CircleAvatar(
                  radius: imageRadius + 4,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: imageRadius,
                    backgroundImage: mainImage,
                  ),
                ),
              ),
            ),

            // 6. Offer Badge
            Positioned(
              top: height * 0.35,
              right: width * 0.08,
              child: Container(
                width: 55,
                height: 55,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  offer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // 7. Bottom Left Call to Action Button
            Positioned(
              bottom: height * 0.04,
              left: width * 0.05,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  btnText,
                  style: TextStyle(
                    color: bottomColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            // 8. 📱 Bottom Right Social Icons (FOLLOW US)
            Positioned(
              bottom: height * 0.04,
              right: width * 0.05,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'FOLLOW US',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSocialIcon(Icons.facebook, bottomColor),
                      const SizedBox(width: 6),
                      _buildSocialIcon(Icons.camera_alt, bottomColor),
                      const SizedBox(width: 6),
                      _buildSocialIcon(Icons.flutter_dash, bottomColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // সোশ্যাল সার্কেল আইকন উইজেট
  Widget _buildSocialIcon(IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 15),
    );
  }
}

// ✂️ স্মার্ট ওয়েভ কাস্টম ক্লিপার
class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.60);
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.82,
      size.width * 0.65,
      size.height * 0.52,
      size.width,
      size.height * 0.60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
