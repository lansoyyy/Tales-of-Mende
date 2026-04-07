import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/utils/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import 'panel6_opening_screen.dart';

/// Panel 5 — In-game Loading Screen
///
/// Shows the background and animated loading bar while assets "load",
/// then navigates to Panel 6 (the opening/home screen of the game).
class Panel5GameLoadingScreen extends StatefulWidget {
  const Panel5GameLoadingScreen({super.key});

  @override
  State<Panel5GameLoadingScreen> createState() =>
      _Panel5GameLoadingScreenState();
}

class _Panel5GameLoadingScreenState extends State<Panel5GameLoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progressController;
  late final AnimationController _fadeController;
  late final AnimationController _tipFadeController;
  late final Animation<double> _progressAnim;
  late final Animation<double> _fadeIn;
  late final Animation<double> _tipFade;

  int _tipIndex = 0;
  static const _tips = [
    'Elements are arranged by increasing atomic number.',
    'Each element has a unique number of protons.',
    'Elements in the same column, or group, have similar properties.',
    'Rows in the periodic table are called periods.',
    'Metals are found on the left side of the table.',
    'Nonmetals are found on the right side.',
    'Metalloids have properties of both metals and nonmetals.',
    'The alkali metals in Group 1 are highly reactive.',
    'The noble gases in Group 18 are stable and rarely react.',
    'Atomic size increases as you go down a group.',
    'Atomic size decreases as you go across a period.',
    'Transition metals are found in the middle of the table.',
    'The periodic table helps predict how elements will react.',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    _tipFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..value = 1.0;
    _tipFade = CurvedAnimation(
      parent: _tipFadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward().then((_) {
      _progressController.forward().then((_) => _navigate());
      // Cycle tips every ~1 second
      _cycleTip();
    });
  }

  void _cycleTip() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _tipFadeController.reverse().then((_) {
        if (!mounted) return;
        setState(() => _tipIndex = (_tipIndex + 1) % _tips.length);
        _tipFadeController.forward().then((_) => _cycleTip());
      });
    });
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const Panel6OpeningScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    _tipFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeIn,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background ────────────────────────────────────────────────
            Image.asset(
              AppAssets.loadingBackground,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.background),
            ),

            // ── Dark overlay ─────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x44000000), Color(0xCC000000)],
                  stops: [0.4, 1.0],
                ),
              ),
            ),

            // ── Loading spinner (loading copy asset) ──────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rotating loading icon
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (_, child) => Transform.rotate(
                      angle: _progressController.value * 6.28318 * 3,
                      child: child,
                    ),
                    child: Image.asset(
                      AppAssets.loadingBar,
                      width: 48,
                      height: 48,
                      color: AppColors.accent,
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (_, __, ___) => SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LOADING WORLD…',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 4,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom progress bar + tip ──────────────────────────────────
            Positioned(
              left: size.width * 0.15,
              right: size.width * 0.15,
              bottom: size.height * 0.1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CHEM TIP',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accent,
                      fontSize: 10,
                      letterSpacing: 2.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Tip text
                  FadeTransition(
                    opacity: _tipFade,
                    child: Text(
                      _tips[_tipIndex],
                      textAlign: TextAlign.center,
                      style: AppTextStyles.narrative.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Progress track
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withAlpha(160),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AnimatedBuilder(
                      animation: _progressAnim,
                      builder: (_, __) => LayoutBuilder(
                        builder: (ctx, constraints) => Stack(
                          children: [
                            Container(
                              width: constraints.maxWidth * _progressAnim.value,
                              height: 5,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.accentDark,
                                    AppColors.accent,
                                    AppColors.accentLight,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withAlpha(100),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Percentage label
                  AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (_, __) => Text(
                      '${(_progressAnim.value * 100).toInt()}%',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.accent,
                        letterSpacing: 2,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Version ───────────────────────────────────────────────────
            Positioned(
              right: 16,
              bottom: 8,
              child: Text(
                'v1.0.0',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textDisabled,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
