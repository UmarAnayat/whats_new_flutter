import 'whats_new_feature_item.dart';

/// Configuration passed to [WhatsNewModal.show].
class WhatsNewConfig {
  const WhatsNewConfig({
    required this.version,
    required this.title,
    this.subtitle,
    required this.features,
    this.continueLabel = 'Continue',
  });

  final String version;
  final String title;
  final String? subtitle;
  final List<WhatsNewFeatureItem> features;
  final String continueLabel;
}
