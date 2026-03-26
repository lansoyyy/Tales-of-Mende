import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/utils/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import 'panel2_main_menu_screen.dart';

/// Panel 1 — Splash / Loading Screen
///
/// Displays the background scene and Tales of Mende logo while a
/// fake-progress bar fills over ~3 seconds, then fades into the main menu.
class Panel1SplashScreen extends StatefulWidget {
  const Panel1SplashScreen({super.key});

  @override
  State<Panel1SplashScreen> createState() => _Panel1SplashScreenState();
}

class _Panel1SplashScreenState extends State<Panel1SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progressController;
  late final AnimationController _fadeController;
  late final Animation<double> _progressAnim;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    // Hide system UI for full immersion
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Progress bar fills in 3 seconds
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    // Fade-in for the whole screen
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // Start fade-in then progress
    _fadeController.forward().then((_) {
      _progressController.forward().then((_) => _navigateToMenu());
    });
  }

  void _navigateToMenu() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const Panel2MainMenuScreen(),
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
            // ── Background ─────────────────────────────────────────────────
            Image.asset(
              AppAssets.splashBackground,
              fit: BoxFit.cover,
              width: size.width,
              height: size.height,
              errorBuilder: (_, __, ___) => Container(color: AppColors.background),
            ),

            // ── Dark vignette overlay ───────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Colors.transparent, Color(0xCC000000)],
                ),
              ),
            ),

            // ── Logo ────────────────────────────────────────────────────────
            Positioned(
              top: 0,
              bottom: size.height * 0.25,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  AppAssets.splashLogo,
                  width: size.width * 0.55,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(
                    'TALES OF MENDE',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.questGold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ),

            // ── Loading bar & label ──────────────────────────────────────────
            Positioned(
              left: size.width * 0.2,
              right: size.width * 0.2,
              bottom: size.height * 0.12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  Text(
                    'LOADING...',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Track
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withAlpha(180),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AnimatedBuilder(
                      animation: _progressAnim,
                      builder: (_, __) => FractionallySizedBox(
                        widthFactor: 1.0,
                        child: LayoutBuilder(
                          builder: (context, constraints) => Stack(
                            children: [
                              // Filled portion
                              Container(
                                width: constraints.maxWidth * _progressAnim.value,
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.accentDark,
                                      AppColors.accent,
                                      AppColors.accentLight,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withAlpha(120),
                                      blurRadius: 8,
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
                  ),
                ],
              ),
            ),

            // ── Version watermark ────────────────────────────────────────────
            Positioned(
              right: 16,
              bottom: 10,
              child: Text(
                'v1.0.0',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textDisabled,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
