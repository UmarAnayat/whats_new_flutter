import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../models/whats_new_config.dart';
import '../models/whats_new_feature_item.dart';
import '../motion/whats_new_motion.dart';
import '../theme/whats_new_theme.dart';

/// Animated premium bottom sheet for release notes.
class WhatsNewSheet extends StatefulWidget {
  const WhatsNewSheet({
    super.key,
    required this.config,
    required this.theme,
    required this.onDismiss,
  });

  final WhatsNewConfig config;
  final WhatsNewTheme theme;
  final VoidCallback onDismiss;

  @override
  State<WhatsNewSheet> createState() => _WhatsNewSheetState();
}

class _WhatsNewSheetState extends State<WhatsNewSheet>
    with TickerProviderStateMixin {
  late final AnimationController _presentController;
  late final AnimationController _contentController;
  late final AnimationController _closeController;

  final GlobalKey _sheetKey = GlobalKey();
  double _sheetHeight = 0;

  double _dragOffset = 0;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _presentController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 1,
    );
    _contentController = AnimationController(
      vsync: this,
      duration: WhatsNewMotion.sheetContentDuration,
    );
    _closeController = AnimationController(
      vsync: this,
      duration: WhatsNewMotion.closeTapDuration,
    );
    _runEnterAnimation();
  }

  Future<void> _runEnterAnimation() async {
    await Future.wait([
      _presentController.animateWith(
        WhatsNewMotion.sheetEnterSimulation(),
      ),
      _contentController.forward(from: 0),
    ]);
  }

  @override
  void dispose() {
    _presentController.dispose();
    _contentController.dispose();
    _closeController.dispose();
    super.dispose();
  }

  void _scheduleSheetHeightUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final height = _sheetKey.currentContext?.size?.height ?? 0;
      if (height > 0 && (height - _sheetHeight).abs() > 0.5) {
        setState(() => _sheetHeight = height);
      }
    });
  }

  double _travelHeight(double maxHeight, double bottomInset) {
    if (_sheetHeight > 0) return _sheetHeight;
    return _estimateSheetHeight(widget.config, bottomInset)
        .clamp(0, maxHeight);
  }

  static double _estimateSheetHeight(
    WhatsNewConfig config,
    double bottomInset,
  ) {
    const heroSpace = 148.0;
    const handleBlock = 13.0;
    const headerBlock = 88.0;
    const featureBlock = 96.0;
    final ctaBlock = WhatsNewMotion.ctaHeight +
        WhatsNewMotion.sectionVerticalPadding +
        bottomInset;
    return heroSpace +
        handleBlock +
        headerBlock +
        20 +
        (config.features.length * featureBlock) +
        20 +
        ctaBlock;
  }

  Future<void> _dismiss({double velocity = 0}) async {
    if (_isClosing) return;
    _isClosing = true;
    HapticFeedback.selectionClick();
    await _contentController.reverse();
    await _presentController.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 0.7, stiffness: 520, damping: 42),
        _presentController.value,
        0,
        velocity,
      ),
    );
    if (mounted) widget.onDismiss();
  }

  Future<void> _onCloseTap() async {
    HapticFeedback.lightImpact();
    await _closeController.forward();
    await _closeController.reverse();
    await _dismiss();
  }

  Future<void> _onContinueTap() async {
    HapticFeedback.mediumImpact();
    await _dismiss();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isClosing) return;
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dy).clamp(0, 260);
    });
  }

  Future<void> _onVerticalDragEnd(DragEndDetails details) async {
    if (_isClosing) return;
    final velocity = details.primaryVelocity ?? 0;
    if (_dragOffset > WhatsNewMotion.dragDismissThreshold || velocity > 900) {
      await _dismiss(velocity: velocity / 1000);
      return;
    }

    final controller = AnimationController(
      vsync: this,
      duration: WhatsNewMotion.dragSnapBackDuration,
    );
    final animation = Tween<double>(begin: _dragOffset, end: 0).animate(
      CurvedAnimation(parent: controller, curve: WhatsNewMotion.contentCurve),
    );
    animation.addListener(() => setState(() => _dragOffset = animation.value));
    await controller.forward();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final config = widget.config;
    final maxHeight =
        MediaQuery.sizeOf(context).height * WhatsNewMotion.sheetMaxHeightFactor;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    _scheduleSheetHeightUpdate();

    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _presentController,
          _contentController,
          _closeController,
        ]),
        builder: (context, _) {
          final rawT = _presentController.value;
          final sheetT = WhatsNewMotion.sheetProgress(rawT);
          final travelHeight = _travelHeight(maxHeight, bottomInset);

          final sheetYOffset =
              (1 - sheetT) * travelHeight + _dragOffset + (1 - sheetT) * 28;
          final sheetScale =
              lerpDouble(WhatsNewMotion.sheetEnterScale, 1, sheetT)!;
          final backdropOpacity = Curves.easeOut.transform(sheetT.clamp(0.0, 1.0));
          final blurSigma = lerpDouble(0, WhatsNewMotion.backdropBlurSigma, sheetT)!;

          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: _dismiss,
                  behavior: HitTestBehavior.opaque,
                  child: _PremiumBackdrop(
                    theme: theme,
                    opacity: backdropOpacity.clamp(0, 1),
                    blurSigma: blurSigma,
                    sheetProgress: sheetT,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Transform.translate(
                  offset: Offset(0, sheetYOffset),
                  child: Transform.scale(
                    scale: sheetScale,
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onVerticalDragUpdate: _onVerticalDragUpdate,
                      onVerticalDragEnd: _onVerticalDragEnd,
                      child: Container(
                        key: _sheetKey,
                        constraints: BoxConstraints(maxHeight: maxHeight),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(WhatsNewMotion.sheetTopRadius),
                          ),
                          boxShadow: theme.sheetShadow,
                          border: Border.all(
                            color: theme.featureCardBorder.withValues(alpha: 0.8),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(WhatsNewMotion.sheetTopRadius),
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: theme.sheetBackgroundGradient,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _StaggerReveal(
                                  controller: _contentController,
                                  interval: const Interval(
                                    0,
                                    0.32,
                                    curve: Curves.easeOutBack,
                                  ),
                                  slideFrom: 36,
                                  child: _HeroBanner(
                                    theme: theme,
                                    config: config,
                                    closeAnimation: _closeController,
                                    onClose: _onCloseTap,
                                  ),
                                ),
                                _StaggerReveal(
                                  controller: _contentController,
                                  interval: const Interval(
                                    0.04,
                                    0.22,
                                    curve: Curves.easeOut,
                                  ),
                                  slideFrom: 14,
                                  child: Container(
                                    width: WhatsNewMotion.handleWidth,
                                    height: WhatsNewMotion.handleHeight,
                                    margin: const EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                      color: theme.handleColor,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          WhatsNewMotion.horizontalPadding,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 12),
                                        _StaggerReveal(
                                          controller: _contentController,
                                          interval: const Interval(
                                            0.12,
                                            0.38,
                                            curve: Curves.easeOutCubic,
                                          ),
                                          slideFrom: 28,
                                          child: _HeaderText(
                                            config: config,
                                            theme: theme,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ...List.generate(
                                          config.features.length,
                                          (index) {
                                            final feature =
                                                config.features[index];
                                            final start = 0.22 + (index * 0.1);
                                            final end =
                                                (start + 0.28).clamp(0.0, 1.0);
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom: index ==
                                                        config.features.length -
                                                            1
                                                    ? 0
                                                    : WhatsNewMotion
                                                        .featureRowSpacing,
                                              ),
                                              child: _StaggerReveal(
                                                controller: _contentController,
                                                interval: Interval(
                                                  start,
                                                  end,
                                                  curve: Curves.easeOutCubic,
                                                ),
                                                slideFrom: 32,
                                                child: _FeatureCard(
                                                  feature: feature,
                                                  theme: theme,
                                                  index: index,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(
                                          height: 20 + bottomInset * 0.15,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                _StaggerReveal(
                                  controller: _contentController,
                                  interval: const Interval(
                                    0.58,
                                    0.92,
                                    curve: Curves.easeOutCubic,
                                  ),
                                  slideFrom: 36,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      WhatsNewMotion.horizontalPadding,
                                      0,
                                      WhatsNewMotion.horizontalPadding,
                                      WhatsNewMotion.sectionVerticalPadding +
                                          bottomInset,
                                    ),
                                    child: _ContinueButton(
                                      label: config.continueLabel,
                                      theme: theme,
                                      onPressed: _onContinueTap,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PremiumBackdrop extends StatelessWidget {
  const _PremiumBackdrop({
    required this.theme,
    required this.opacity,
    required this.blurSigma,
    required this.sheetProgress,
  });

  final WhatsNewTheme theme;
  final double opacity;
  final double blurSigma;
  final double sheetProgress;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: const SizedBox.expand(),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: const [0, 0.35, 0.7, 1],
                colors: theme.backdropGradientColors
                    .map((c) => c.withValues(alpha: c.a * opacity))
                    .toList(),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 0.85),
                radius: 0.95 + (sheetProgress * 0.15),
                colors: [
                  theme.primary.withValues(alpha: 0.22 * opacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.8, -0.9),
                radius: 0.75,
                colors: [
                  theme.primaryVariant.withValues(alpha: 0.12 * opacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.theme,
    required this.config,
    required this.closeAnimation,
    required this.onClose,
  });

  final WhatsNewTheme theme;
  final WhatsNewConfig config;
  final Animation<double> closeAnimation;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Transform.translate(
              offset: const Offset(30, -50),
              child: _GlowOrb(color: theme.heroGlowPrimary, size: 190),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: const Offset(-40, 10),
              child: _GlowOrb(color: theme.heroGlowSecondary, size: 140),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(gradient: theme.heroGradient),
          ),
          Positioned(
            top: 12,
            right: WhatsNewMotion.horizontalPadding,
            child: _GlassCloseButton(
              theme: theme,
              closeAnimation: closeAnimation,
              onClose: onClose,
            ),
          ),
          Positioned(
            left: WhatsNewMotion.horizontalPadding,
            bottom: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: theme.primaryGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.42),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const SizedBox(
                width: 64,
                height: 64,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          Positioned(
            right: WhatsNewMotion.horizontalPadding,
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: theme.closeButtonFill,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: theme.closeButtonBorder),
              ),
              child: Text(
                'v${config.version}',
                style: TextStyle(
                  color: theme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: theme.versionPillFontSize,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          Positioned(
            left: WhatsNewMotion.horizontalPadding + 76,
            right: WhatsNewMotion.horizontalPadding,
            bottom: 22,
            child: Text(
              'New update ready',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaggerReveal extends StatelessWidget {
  const _StaggerReveal({
    required this.controller,
    required this.interval,
    required this.child,
    this.slideFrom = 24,
  });

  final AnimationController controller;
  final Interval interval;
  final Widget child;
  final double slideFrom;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(parent: controller, curve: interval);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, lerpDouble(slideFrom, 0, t)!),
            child: Transform.scale(
              scale: lerpDouble(0.88, 1, t)!,
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({
    required this.config,
    required this.theme,
  });

  final WhatsNewConfig config;
  final WhatsNewTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          config.title,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: theme.titleFontSize,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -0.8,
          ),
        ),
        if (config.subtitle case final subtitle?) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: theme.subtitleFontSize,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}

class _GlassCloseButton extends StatelessWidget {
  const _GlassCloseButton({
    required this.theme,
    required this.closeAnimation,
    required this.onClose,
  });

  final WhatsNewTheme theme;
  final Animation<double> closeAnimation;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 0.86).animate(
        CurvedAnimation(
          parent: closeAnimation,
          curve: WhatsNewMotion.closeTapCurve,
        ),
      ),
      child: RotationTransition(
        turns: Tween<double>(begin: 0, end: 0.08).animate(
          CurvedAnimation(
            parent: closeAnimation,
            curve: WhatsNewMotion.closeTapCurve,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: theme.closeButtonFill,
              child: InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(22),
                child: Ink(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.closeButtonBorder),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: theme.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.feature,
    required this.theme,
    required this.index,
  });

  final WhatsNewFeatureItem feature;
  final WhatsNewTheme theme;
  final int index;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.featureCardFill,
        borderRadius: BorderRadius.circular(WhatsNewMotion.featureCardRadius),
        border: Border.all(color: theme.featureCardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: theme.primaryGradient,
                borderRadius: BorderRadius.circular(
                  WhatsNewMotion.iconContainerRadius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.32),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SizedBox(
                width: WhatsNewMotion.iconContainerSize,
                height: WhatsNewMotion.iconContainerSize,
                child: Icon(feature.icon, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.title,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: theme.featureTitleFontSize,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature.description,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: theme.featureDescriptionFontSize,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueButton extends StatefulWidget {
  const _ContinueButton({
    required this.label,
    required this.theme,
    required this.onPressed,
  });

  final String label;
  final WhatsNewTheme theme;
  final VoidCallback onPressed;

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: double.infinity,
          height: WhatsNewMotion.ctaHeight,
          decoration: BoxDecoration(
            gradient: widget.theme.primaryGradient,
            borderRadius: BorderRadius.circular(WhatsNewMotion.ctaRadius),
            boxShadow: widget.theme.ctaShadow,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(WhatsNewMotion.ctaRadius),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.24),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double? lerpDouble(num? a, num? b, double t) {
  return a! + (b! - a) * t;
}
