import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/utils/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// Panel 6 — Opening / Home Screen
///
/// Entry point into the actual game world.
/// Currently a placeholder — will be fleshed out in a future panel.
class Panel6OpeningScreen extends StatefulWidget {
  const Panel6OpeningScreen({super.key});

  @override
  State<Panel6OpeningScreen> createState() => _Panel6OpeningScreenState();
}

class _Panel6OpeningScreenState extends State<Panel6OpeningScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeIn,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background ──────────────────────────────────────────────
            Image.asset(
              AppAssets.homeBackground,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.background),
            ),

            // ── Overlay ─────────────────────────────────────────────────
            Container(color: const Color(0x44000000)),

            // ── Placeholder label ────────────────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TALES OF MENDE',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.questGold,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(
                          color: AppColors.accent.withAlpha(160),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Opening screen — coming soon',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // ── Side navigation icons (Panel 6 assets) ────────────────────
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NavIcon(asset: AppAssets.homeProfileFolder, label: 'Profile'),
                  const SizedBox(height: 16),
                  _NavIcon(asset: AppAssets.homeQuestFolder, label: 'Quests'),
                  const SizedBox(height: 16),
                  _NavIcon(asset: AppAssets.homeBookKnowledge, label: 'Knowledge'),
                  const SizedBox(height: 16),
                  _NavIcon(asset: AppAssets.homeOptions, label: 'Options'),
                ],
              ),
            ),

            // ── Back button ───────────────────────────────────────────────
            Positioned(
              top: 12,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Image.asset(
                  AppAssets.homeBackButton,
                  width: 28,
                  height: 28,
                  color: AppColors.textPrimary,
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // ── Sparks decoration ─────────────────────────────────────────
            Positioned(
              top: 0,
              right: 0,
              child: IgnorePointer(
                child: Image.asset(
                  AppAssets.homeSparks,
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Nav icon widget ──────────────────────────────────────────────────────────

class _NavIcon extends StatefulWidget {
  const _NavIcon({required this.asset, required this.label});
  final String asset;
  final String label;

  @override
  State<_NavIcon> createState() => _NavIconState();
}

class _NavIconState extends State<_NavIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.label} — coming soon'),
              duration: const Duration(seconds: 1),
              backgroundColor: AppColors.surface,
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.surfaceVariant.withAlpha(200)
                : AppColors.surface.withAlpha(120),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? AppColors.accent : AppColors.borderColor,
            ),
          ),
          child: Image.asset(
            widget.asset,
            width: 24,
            height: 24,
            color: _hovered ? AppColors.accent : AppColors.textPrimary,
            colorBlendMode: BlendMode.srcIn,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.help_outline, color: AppColors.textSecondary, size: 20),
          ),
        ),
      ),
    );
  }
}
