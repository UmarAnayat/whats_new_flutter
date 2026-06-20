import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:whats_new_flutter/whats_new_flutter.dart';

void main() {
  runApp(const WhatsNewDemoApp());
}

class WhatsNewDemoApp extends StatelessWidget {
  const WhatsNewDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsNew Demo',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const DemoHomePage(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4F46E5),
        brightness: brightness,
      ),
      scaffoldBackgroundColor: Colors.transparent,
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage>
    with TickerProviderStateMixin {
  static const _demoConfig = WhatsNewConfig(
    version: '2.0.0',
    title: "What's New",
    subtitle: 'Welcome to the latest update',
    features: [
      WhatsNewFeatureItem(
        icon: Icons.bolt_rounded,
        title: 'Faster checkout',
        description: 'Complete purchases in fewer steps.',
      ),
      WhatsNewFeatureItem(
        icon: Icons.dark_mode_rounded,
        title: 'Dark mode',
        description: 'Easier on your eyes at night.',
      ),
      WhatsNewFeatureItem(
        icon: Icons.security_rounded,
        title: 'Security boost',
        description: 'Enhanced account protection.',
      ),
    ],
  );

  late final AnimationController _entranceController;
  late final AnimationController _themeRevealController;
  late final CurvedAnimation _themeRevealAnimation;
  late final CurvedAnimation _themeOutgoingAnimation;

  final GlobalKey _toggleKey = GlobalKey();

  late final Animation<double> _iconEntrance;
  late final Animation<double> _titleEntrance;
  late final Animation<double> _subtitleEntrance;
  late final Animation<double> _buttonEntrance;
  late final Animation<double> _footerEntrance;

  bool _isDark = false;
  bool _isTurning = false;
  bool _turnFromDark = false;
  Offset _revealOrigin = Offset.zero;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: WhatsNewMotion.homeEntranceDuration,
    );
    _themeRevealController = AnimationController(
      vsync: this,
      duration: WhatsNewMotion.themeRevealDuration,
    );
    _themeRevealAnimation = CurvedAnimation(
      parent: _themeRevealController,
      curve: WhatsNewMotion.themeRevealCurve,
    );
    _themeOutgoingAnimation = CurvedAnimation(
      parent: _themeRevealController,
      curve: WhatsNewMotion.themeOutgoingCurve,
    );

    _iconEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.05, 0.42, curve: Curves.easeOutBack),
    );
    _titleEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.16, 0.52, curve: Curves.easeOutCubic),
    );
    _subtitleEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.24, 0.58, curve: Curves.easeOutCubic),
    );
    _buttonEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.34, 0.72, curve: Curves.easeOutCubic),
    );
    _footerEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.44, 0.82, curve: Curves.easeOutCubic),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _themeRevealAnimation.dispose();
    _themeOutgoingAnimation.dispose();
    _themeRevealController.dispose();
    super.dispose();
  }

  void _captureRevealOrigin() {
    final box = _toggleKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      _revealOrigin = box.localToGlobal(
        Offset(box.size.width / 2, box.size.height / 2),
      );
      return;
    }

    final size = MediaQuery.sizeOf(context);
    _revealOrigin = Offset(size.width - 56, 52);
  }

  Future<void> _toggleTheme() async {
    if (_themeRevealController.isAnimating) return;

    _captureRevealOrigin();
    _turnFromDark = _isDark;
    setState(() => _isTurning = true);

    await _themeRevealController.forward(from: 0);

    if (!mounted) return;
    setState(() {
      _isDark = !_isDark;
      _isTurning = false;
    });
    _themeRevealController.value = 0;
  }

  Future<void> _showWhatsNew() {
    return WhatsNewModal.show(
      context,
      config: _demoConfig,
      theme: WhatsNewTheme.material3(
        brightness: _isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _themeRevealController]),
      builder: (context, _) {
        if (!_isTurning) {
          return _DemoPageLayer(
            isDark: _isDark,
            iconEntrance: _iconEntrance,
            titleEntrance: _titleEntrance,
            subtitleEntrance: _subtitleEntrance,
            buttonEntrance: _buttonEntrance,
            footerEntrance: _footerEntrance,
            isDarkMode: _isDark,
            onToggleTheme: _toggleTheme,
            onShowWhatsNew: _showWhatsNew,
            isTurning: false,
            toggleKey: _toggleKey,
            attachToggleKey: true,
          );
        }

        final revealT = _themeRevealAnimation.value;
        final outgoingT = _themeOutgoingAnimation.value;
        final toDark = !_turnFromDark;
        final screenSize = MediaQuery.sizeOf(context);
        final revealOrigin = _revealOrigin;
        final revealAlignment = Alignment(
          (revealOrigin.dx / screenSize.width) * 2 - 1,
          (revealOrigin.dy / screenSize.height) * 2 - 1,
        );

        // Light → dark: circle expands from toggle showing dark.
        // Dark → light: same circle shrinks back into toggle (1 - revealT).
        final clipT = toDark ? revealT : (1 - revealT);

        return Stack(
          fit: StackFit.expand,
          children: [
            Transform.scale(
              scale: toDark
                  ? 1 - outgoingT * 0.04
                  : 0.92 + revealT * 0.08,
              alignment: revealAlignment,
              child: toDark
                  ? ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: outgoingT * 7,
                        sigmaY: outgoingT * 7,
                      ),
                      child: Opacity(
                        opacity: (1 - outgoingT * 0.22).clamp(0.0, 1.0),
                        child: _DemoPageLayer(
                          isDark: false,
                          iconEntrance: _iconEntrance,
                          titleEntrance: _titleEntrance,
                          subtitleEntrance: _subtitleEntrance,
                          buttonEntrance: _buttonEntrance,
                          footerEntrance: _footerEntrance,
                          isDarkMode: false,
                          onToggleTheme: _toggleTheme,
                          onShowWhatsNew: _showWhatsNew,
                          isTurning: true,
                          toggleKey: _toggleKey,
                          attachToggleKey: true,
                        ),
                      ),
                    )
                  : _DemoPageLayer(
                      isDark: false,
                      iconEntrance: _iconEntrance,
                      titleEntrance: _titleEntrance,
                      subtitleEntrance: _subtitleEntrance,
                      buttonEntrance: _buttonEntrance,
                      footerEntrance: _footerEntrance,
                      isDarkMode: false,
                      onToggleTheme: _toggleTheme,
                      onShowWhatsNew: _showWhatsNew,
                      isTurning: true,
                      toggleKey: _toggleKey,
                      attachToggleKey: false,
                    ),
            ),
            ClipPath(
              clipper: _CircularRevealClipper(
                origin: revealOrigin,
                progress: clipT,
              ),
              child: Transform.scale(
                scale: 0.92 + clipT * 0.08,
                alignment: revealAlignment,
                child: toDark
                    ? _DemoPageLayer(
                        isDark: true,
                        iconEntrance: _iconEntrance,
                        titleEntrance: _titleEntrance,
                        subtitleEntrance: _subtitleEntrance,
                        buttonEntrance: _buttonEntrance,
                        footerEntrance: _footerEntrance,
                        isDarkMode: true,
                        onToggleTheme: _toggleTheme,
                        onShowWhatsNew: _showWhatsNew,
                        isTurning: true,
                        toggleKey: _toggleKey,
                        attachToggleKey: false,
                      )
                    : ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: (1 - clipT) * 7,
                          sigmaY: (1 - clipT) * 7,
                        ),
                        child: Opacity(
                          opacity: (0.78 + clipT * 0.22).clamp(0.0, 1.0),
                          child: _DemoPageLayer(
                            isDark: true,
                            iconEntrance: _iconEntrance,
                            titleEntrance: _titleEntrance,
                            subtitleEntrance: _subtitleEntrance,
                            buttonEntrance: _buttonEntrance,
                            footerEntrance: _footerEntrance,
                            isDarkMode: true,
                            onToggleTheme: _toggleTheme,
                            onShowWhatsNew: _showWhatsNew,
                            isTurning: true,
                            toggleKey: _toggleKey,
                            attachToggleKey: true,
                          ),
                        ),
                      ),
              ),
            ),
            if (clipT > 0.01 && clipT < 0.995)
              IgnorePointer(
                child: CustomPaint(
                  painter: _CircularRevealGlowPainter(
                    origin: revealOrigin,
                    progress: clipT,
                    toDark: toDark,
                    screenSize: screenSize,
                  ),
                  size: Size.infinite,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CircularRevealClipper extends CustomClipper<Path> {
  _CircularRevealClipper({
    required this.origin,
    required this.progress,
  });

  final Offset origin;
  final double progress;

  static double _maxRadius(Offset origin, Size size) {
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    return corners
            .map((c) => (c - origin).distance)
            .reduce(math.max) *
        1.08;
  }

  @override
  Path getClip(Size size) {
    final t = progress.clamp(0.0, 1.0);
    if (t <= 0) return Path();
    if (t >= 1) return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final radius = _maxRadius(origin, size) * t;
    return Path()..addOval(Rect.fromCircle(center: origin, radius: radius));
  }

  @override
  bool shouldReclip(covariant _CircularRevealClipper oldClipper) {
    return oldClipper.origin != origin || oldClipper.progress != progress;
  }
}

class _CircularRevealGlowPainter extends CustomPainter {
  _CircularRevealGlowPainter({
    required this.origin,
    required this.progress,
    required this.toDark,
    required this.screenSize,
  });

  final Offset origin;
  final double progress;
  final bool toDark;
  final Size screenSize;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.clamp(0.0, 1.0);
    final radius = _CircularRevealClipper._maxRadius(origin, screenSize) * t;
    if (radius <= 1) return;

    final glowColor = toDark ? const Color(0xFF818CF8) : const Color(0xFFFBBF24);

    canvas.drawCircle(
      origin,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28
        ..shader = RadialGradient(
          colors: [
            glowColor.withValues(alpha: 0.55),
            glowColor.withValues(alpha: 0.18),
            Colors.transparent,
          ],
          stops: const [0.72, 0.88, 1],
        ).createShader(Rect.fromCircle(center: origin, radius: radius + 14)),
    );

    canvas.drawCircle(
      origin,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = Colors.white.withValues(alpha: 0.35 * (1 - (t - 0.5).abs() * 2)),
    );
  }

  @override
  bool shouldRepaint(covariant _CircularRevealGlowPainter oldDelegate) {
    return oldDelegate.origin != origin ||
        oldDelegate.progress != progress ||
        oldDelegate.toDark != toDark ||
        oldDelegate.screenSize != screenSize;
  }
}

class _DemoPageLayer extends StatelessWidget {
  const _DemoPageLayer({
    required this.isDark,
    required this.iconEntrance,
    required this.titleEntrance,
    required this.subtitleEntrance,
    required this.buttonEntrance,
    required this.footerEntrance,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onShowWhatsNew,
    required this.isTurning,
    required this.toggleKey,
    this.attachToggleKey = false,
  });

  final bool isDark;
  final Animation<double> iconEntrance;
  final Animation<double> titleEntrance;
  final Animation<double> subtitleEntrance;
  final Animation<double> buttonEntrance;
  final Animation<double> footerEntrance;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final VoidCallback onShowWhatsNew;
  final bool isTurning;
  final GlobalKey toggleKey;
  final bool attachToggleKey;

  @override
  Widget build(BuildContext context) {
    final bgTop = isDark ? const Color(0xFF09090F) : const Color(0xFFF8FAFF);
    final bgMid = isDark ? const Color(0xFF111827) : const Color(0xFFEEF2FF);
    final bgBottom = isDark ? const Color(0xFF1E1B4B) : const Color(0xFFFDF4FF);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgTop, bgMid, bgBottom],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: isDark ? -60 : -90,
            right: isDark ? -20 : -40,
            child: _BackgroundOrb(
              color: const Color(0xFF4F46E5)
                  .withValues(alpha: isDark ? 0.34 : 0.18),
              size: isDark ? 240 : 220,
            ),
          ),
          Positioned(
            bottom: isDark ? 80 : 120,
            left: isDark ? -70 : -60,
            child: _BackgroundOrb(
              color: const Color(0xFF7C3AED)
                  .withValues(alpha: isDark ? 0.26 : 0.14),
              size: isDark ? 200 : 180,
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          'Pulse',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Spacer(),
                        _ThemeToggleButton(
                          key: attachToggleKey ? toggleKey : null,
                          isDark: isDarkMode,
                          onPressed: isTurning ? () {} : onToggleTheme,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _EntranceBlock(
                              animation: iconEntrance,
                              slide: 36,
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isDark
                                        ? const [
                                            Color(0xFF6366F1),
                                            Color(0xFF8B5CF6),
                                          ]
                                        : const [
                                            Color(0xFF4F46E5),
                                            Color(0xFF7C3AED),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4F46E5)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 24,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.new_releases_rounded,
                                  size: 46,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _EntranceBlock(
                              animation: titleEntrance,
                              slide: 28,
                              child: Text(
                                'Welcome back',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                  height: 1.05,
                                  letterSpacing: -0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _EntranceBlock(
                              animation: subtitleEntrance,
                              slide: 22,
                              child: Text(
                                'Version 2.0 is ready.\nReview the latest changes and improvements.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),
                            _EntranceBlock(
                              animation: buttonEntrance,
                              slide: 26,
                              child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDark
                                          ? const [
                                              Color(0xFF6366F1),
                                              Color(0xFF8B5CF6),
                                            ]
                                          : const [
                                              Color(0xFF4F46E5),
                                              Color(0xFF7C3AED),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF4F46E5)
                                            .withValues(alpha: 0.34),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(18),
                                      onTap: onShowWhatsNew,
                                      child: const Center(
                                        child: Text(
                                          "What's new",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            _EntranceBlock(
                              animation: footerEntrance,
                              slide: 16,
                              child: Text(
                                'Version 2.0.0',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textSecondary.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntranceBlock extends StatelessWidget {
  const _EntranceBlock({
    required this.animation,
    required this.child,
    this.slide = 24,
  });

  final Animation<double> animation;
  final Widget child;
  final double slide;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        return Opacity(
          opacity: t.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * slide),
            child: Transform.scale(
              scale: 0.92 + (t * 0.08),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({
    super.key,
    required this.isDark,
    required this.onPressed,
  });

  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      child: Material(
        color: isDark
            ? const Color(0xFF1E1E28).withValues(alpha: 0.82)
            : Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  size: 18,
                  color: isDark
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFF4F46E5),
                ),
                const SizedBox(width: 8),
                Text(
                  isDark ? 'Dark' : 'Light',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({required this.color, required this.size});

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
