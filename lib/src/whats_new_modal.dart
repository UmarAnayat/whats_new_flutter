import 'package:flutter/material.dart';

import 'models/whats_new_config.dart';
import 'theme/whats_new_theme.dart';
import 'widgets/whats_new_sheet.dart';

/// Single entry point for showing the premium what's new modal.
abstract final class WhatsNewModal {
  /// Presents an animated bottom sheet with release notes.
  static Future<void> show(
    BuildContext context, {
    required WhatsNewConfig config,
    WhatsNewTheme? theme,
  }) {
    final resolvedTheme = theme ??
        WhatsNewTheme.material3(
          brightness: Theme.of(context).brightness,
        );

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss What\'s New',
      barrierColor: Colors.transparent,
      useRootNavigator: true,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return WhatsNewSheet(
          config: config,
          theme: resolvedTheme,
          onDismiss: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }
}
