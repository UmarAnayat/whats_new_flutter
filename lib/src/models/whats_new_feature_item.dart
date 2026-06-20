import 'package:flutter/widgets.dart';

/// A single feature row shown inside the what's new sheet.
class WhatsNewFeatureItem {
  const WhatsNewFeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
