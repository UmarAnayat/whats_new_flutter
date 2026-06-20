import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

/// Shared motion tokens for the what's new sheet.
abstract final class WhatsNewMotion {
  static const Duration closeTapDuration = Duration(milliseconds: 180);
  static const Duration dragSnapBackDuration = Duration(milliseconds: 260);
  static const Duration themeRevealDuration = Duration(milliseconds: 1800);
  static const Duration homeEntranceDuration = Duration(milliseconds: 980);
  static const Duration sheetContentDuration = Duration(milliseconds: 720);

  static const Curve backdropCurve = Curves.easeOutCubic;
  static const Curve sheetExitCurve = Curves.easeInCubic;
  static const Curve contentCurve = Curves.easeOutQuart;
  static const Curve heroCurve = Curves.easeOutBack;
  static const Curve closeTapCurve = Curves.easeOutBack;

  /// Circular expand from the theme toggle — fast start, soft landing.
  static const Curve themeRevealCurve = Cubic(0.16, 1, 0.3, 1);

  /// Outgoing layer fades/blurs slightly ahead of the reveal edge.
  static const Curve themeOutgoingCurve = Curves.easeInCubic;

  static const SpringDescription sheetSpring = SpringDescription(
    mass: 0.78,
    stiffness: 460,
    damping: 36,
  );

  static Simulation sheetEnterSimulation({double velocity = 0}) {
    return SpringSimulation(sheetSpring, 0, 1, velocity);
  }

  static double sheetProgress(double t) =>
      Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));

  static double contentProgress(double sheetT) =>
      Curves.easeOutCubic.transform(((sheetT - 0.28) / 0.72).clamp(0.0, 1.0));

  static double segmentProgress(double contentT, double start, double length) {
    if (length <= 0) return contentT >= start ? 1 : 0;
    return Curves.easeOutCubic.transform(
      ((contentT - start) / length).clamp(0.0, 1.0),
    );
  }

  static double heroProgress(double contentT) =>
      Curves.easeOutBack
          .transform(segmentProgress(contentT, 0, 0.34))
          .clamp(0.0, 1.0);

  static double headerProgress(double contentT) =>
      segmentProgress(contentT, 0.1, 0.34);

  static double featureProgress(double contentT, int index) =>
      segmentProgress(contentT, 0.22 + (index * 0.1), 0.28);

  static double ctaProgress(double contentT) =>
      segmentProgress(contentT, 0.52, 0.48);

  static const double sheetTopRadius = 32;
  static const double handleWidth = 40;
  static const double handleHeight = 5;
  static const double horizontalPadding = 22;
  static const double sectionVerticalPadding = 18;
  static const double featureRowSpacing = 12;
  static const double iconContainerSize = 44;
  static const double iconContainerRadius = 14;
  static const double featureCardRadius = 18;
  static const double ctaHeight = 56;
  static const double ctaRadius = 18;
  static const double sheetMaxHeightFactor = 0.88;
  static const double backdropBlurSigma = 16;
  static const double sheetEnterScale = 0.9;
  static const double dragDismissThreshold = 120;
}
