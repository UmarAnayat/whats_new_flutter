import 'package:flutter/material.dart';

/// Visual tokens for the what's new sheet.
class WhatsNewTheme {
  const WhatsNewTheme({
    required this.primary,
    required this.primaryVariant,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.handleColor,
    required this.backdropScrim,
    required this.iconBackgroundOpacity,
    required this.featureCardFill,
    required this.featureCardBorder,
    required this.closeButtonFill,
    required this.closeButtonBorder,
    required this.heroGlowPrimary,
    required this.heroGlowSecondary,
    required this.sheetGradientTop,
    required this.sheetGradientBottom,
    this.titleFontSize = 28,
    this.subtitleFontSize = 15,
    this.featureTitleFontSize = 16,
    this.featureDescriptionFontSize = 14,
    this.versionPillFontSize = 12,
  });

  final Color primary;
  final Color primaryVariant;
  final Color surface;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color handleColor;
  final Color backdropScrim;
  final double iconBackgroundOpacity;
  final Color featureCardFill;
  final Color featureCardBorder;
  final Color closeButtonFill;
  final Color closeButtonBorder;
  final Color heroGlowPrimary;
  final Color heroGlowSecondary;
  final Color sheetGradientTop;
  final Color sheetGradientBottom;
  final double titleFontSize;
  final double subtitleFontSize;
  final double featureTitleFontSize;
  final double featureDescriptionFontSize;
  final double versionPillFontSize;

  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, primaryVariant],
      );

  LinearGradient get sheetBackgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [sheetGradientTop, sheetGradientBottom],
      );

  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primary.withValues(alpha: 0.34),
          primaryVariant.withValues(alpha: 0.16),
          Colors.transparent,
        ],
        stops: const [0, 0.42, 1],
      );

  List<Color> get backdropGradientColors => [
        backdropScrim,
        primary.withValues(alpha: 0.18),
        primaryVariant.withValues(alpha: 0.08),
        Colors.transparent,
      ];

  List<BoxShadow> get ctaShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.38),
          blurRadius: 22,
          offset: const Offset(0, 10),
          spreadRadius: -4,
        ),
      ];

  List<BoxShadow> get sheetShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.14),
          blurRadius: 44,
          offset: const Offset(0, -14),
          spreadRadius: -10,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.22),
          blurRadius: 30,
          offset: const Offset(0, -8),
        ),
      ];

  /// Material 3 preset with indigo primary and light/dark surfaces.
  factory WhatsNewTheme.material3({Brightness brightness = Brightness.light}) {
    final isDark = brightness == Brightness.dark;
    const primary = Color(0xFF4F46E5);
    const primaryVariant = Color(0xFF7C3AED);

    return WhatsNewTheme(
      primary: primary,
      primaryVariant: primaryVariant,
      surface: isDark ? const Color(0xFF0B0B10) : const Color(0xFFF3F5FB),
      surfaceElevated: isDark ? const Color(0xFF15151C) : const Color(0xFFFDFDFF),
      sheetGradientTop: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
      sheetGradientBottom: isDark ? const Color(0xFF101015) : const Color(0xFFF8FAFF),
      textPrimary: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      textSecondary: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      handleColor: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
      backdropScrim: isDark
          ? const Color(0xCC020617)
          : const Color(0x990F172A),
      iconBackgroundOpacity: isDark ? 0.24 : 0.16,
      featureCardFill: isDark
          ? const Color(0xFF1A1A24).withValues(alpha: 0.92)
          : Colors.white.withValues(alpha: 0.94),
      featureCardBorder: isDark
          ? const Color(0xFF3B3B52)
          : const Color(0xFFDCE3F0),
      closeButtonFill: isDark
          ? const Color(0xFF232330).withValues(alpha: 0.82)
          : Colors.white.withValues(alpha: 0.78),
      closeButtonBorder: isDark
          ? const Color(0xFF4C4C67)
          : const Color(0xFFE2E8F0),
      heroGlowPrimary: primary.withValues(alpha: isDark ? 0.55 : 0.42),
      heroGlowSecondary: primaryVariant.withValues(alpha: isDark ? 0.38 : 0.28),
    );
  }

  /// Cupertino-style preset tuned for iOS-like sheets.
  factory WhatsNewTheme.cupertino({Brightness brightness = Brightness.light}) {
    final isDark = brightness == Brightness.dark;
    const primary = Color(0xFF007AFF);
    const primaryVariant = Color(0xFF5856D6);

    return WhatsNewTheme(
      primary: primary,
      primaryVariant: primaryVariant,
      surface: isDark ? const Color(0xFF111114) : const Color(0xFFECECF2),
      surfaceElevated: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF7F7FA),
      sheetGradientTop: isDark ? const Color(0xFF1A2744) : const Color(0xFFE8F1FF),
      sheetGradientBottom: isDark ? const Color(0xFF141416) : const Color(0xFFF2F2F7),
      textPrimary: isDark ? Colors.white : const Color(0xFF000000),
      textSecondary: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D72),
      handleColor: isDark ? const Color(0xFF48484A) : const Color(0xFFC7C7CC),
      backdropScrim: isDark
          ? const Color(0xCC000000)
          : const Color(0x99000000),
      iconBackgroundOpacity: isDark ? 0.2 : 0.12,
      featureCardFill: isDark ? const Color(0xFF2C2C2E) : Colors.white,
      featureCardBorder: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
      closeButtonFill: isDark ? const Color(0xFF2C2C2E) : Colors.white,
      closeButtonBorder: isDark ? const Color(0xFF48484A) : const Color(0xFFD1D1D6),
      heroGlowPrimary: primary.withValues(alpha: isDark ? 0.42 : 0.3),
      heroGlowSecondary: primaryVariant.withValues(alpha: isDark ? 0.28 : 0.2),
      titleFontSize: 26,
    );
  }

  Color iconBackground(Color base) =>
      base.withValues(alpha: iconBackgroundOpacity);
}
