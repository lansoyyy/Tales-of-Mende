import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/app_assets.dart';
import 'panel6_opening_screen.dart';

class Quest1StageCompleteScreen extends StatefulWidget {
  const Quest1StageCompleteScreen({super.key});

  @override
  State<Quest1StageCompleteScreen> createState() =>
      _Quest1StageCompleteScreenState();
}

class _Quest1StageCompleteScreenState extends State<Quest1StageCompleteScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const Panel6OpeningScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.52 > 440 ? 440.0 : size.width * 0.52;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.questCompleteBg,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF120822), Color(0xFF05020E)],
                ),
              ),
            ),
          ),
          Container(color: const Color(0x99000000)),
          IgnorePointer(
            child: Image.asset(
              AppAssets.questCompleteSparks,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.expand(),
            ),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 28 * (1 - value)),
                  child: child,
                ),
              ),
              child: Container(
                width: cardWidth,
                padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
                decoration: BoxDecoration(
                  color: const Color(0xD9120A24),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.accent.withAlpha(140)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(90),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppAssets.questCompleteIcon,
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.workspace_premium_outlined,
                        color: AppColors.accent,
                        size: 76,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'YOU COMPLETED THIS STAGE',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.accent,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Quest 1  ·  Laboratory Memory Match',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Take a moment, then head back home when you are ready for the next part of the adventure.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    GestureDetector(
                      onTap: _goHome,
                      child: Image.asset(
                        AppAssets.questCompleteHomeButton,
                        width: 182,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Back Home',
                            style: AppTextStyles.buttonText.copyWith(
                              color: AppColors.textOnAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: size.height * 0.08,
            child: Text(
              'Return home whenever you are ready.',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
