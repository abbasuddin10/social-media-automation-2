import 'package:flutter/material.dart';
import 'food_purple_curved.dart';

class TemplateFactory {
  static Widget buildTemplate({
    required String layoutType,
    required String title,
    required String subtitle,
    required String offer,
    required String btnText,
    required double titleFontSize,
    required double logoSize,
    required double imageRadius,
    required Color topColor,
    required Color bottomColor,
    ImageProvider? mainImage,
    ImageProvider? logoImage,
  }) {
    switch (layoutType) {
      case 'food_purple_curved':
        return FoodPurpleCurvedTemplate(
          title: title,
          subtitle: subtitle,
          offer: offer,
          btnText: btnText,
          titleFontSize: titleFontSize,
          logoSize: logoSize,
          imageRadius: imageRadius,
          topColor: topColor,
          bottomColor: bottomColor,
          mainImage: mainImage,
          logoImage: logoImage,
        );

      default:
        return const Center(child: Text('Template Layout Not Found!'));
    }
  }
}
