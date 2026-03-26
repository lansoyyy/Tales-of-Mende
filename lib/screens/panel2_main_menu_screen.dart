import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/utils/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// Panel 2 — Main Menu Screen
///
/// Landscape layout inspired by the Arcane Blast reference:
/// - Right side: full-bleed background art
/// - Left side: dark overlay panel with logo and menu buttons
class Panel2MainMenuScreen extends StatefulWidget {
  const Panel2MainMenuScreen({super.key});

  @override
  State<Panel2MainMenuScreen> createState() => _Panel2MainMenuScreenState();
}

class _Panel2MainMenuScreenState extends State<Panel2MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterController;
  late final Animation<double> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnim = Tween<double>(begin: -40, end: 0).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
    );
    _fadeAnim = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeIn,
    );

    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _onNewGame() {
    // TODO: navigate to character select / game start screen
    _showComingSoon('New Game');
  }

  void _onCoop() => _showComingSoon('Co-op');

  void _onOptions() => _showComingSoon('Options');

  void _onElements() => _showComingSoon('Elements');

  void _onExit() {
    showDialog<void>(
      context: context,
      barrierColor: AppColors.overlayDark,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderColor),
        ),
        title: Text('Exit Game', style: AppTextStyles.dialogTitle),
        content: Text(
          'Are you sure you want to quit?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: Text('Exit', style: AppTextStyles.labelLarge.copyWith(color: AppColors.dangerRed)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$section — coming soon!',
          style: AppTextStyles.bodyMedium,
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Left panel takes ~42% of the screen width
    final leftWidth = size.width * 0.42;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background art (full screen) ──────────────────────────────────
          Image.asset(
            AppAssets.menuBackground,
            fit: BoxFit.cover,
            width: size.width,
            height: size.height,
            alignment: Alignment.centerRight,
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.background),
          ),

          // ── Right-side subtle vignette ────────────────────────────────────
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: size.width * 0.65,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF0F0520), Colors.transparent],
                  stops: [0.0, 0.6],
                ),
              ),
            ),
          ),

          // ── Left panel overlay ─────────────────────────────────────────────
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: leftWidth,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.background.withAlpha(240),
                    AppColors.background.withAlpha(200),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.75, 1.0],
                ),
              ),
            ),
          ),

          // ── Left panel content ────────────────────────────────────────────
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: leftWidth,
            child: AnimatedBuilder(
              animation: _enterController,
              builder: (context, child) => Opacity(
                opacity: _fadeAnim.value,
                child: Transform.translate(
                  offset: Offset(_slideAnim.value, 0),
                  child: child,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: size.height * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Logo ─────────────────────────────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        AppAssets.menuLogo,
                        width: leftWidth * 0.85,
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
                        errorBuilder: (_, __, ___) => Text(
                          'TALES OF MENDE',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.questGold,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ── NEW GAME button (featured) ────────────────────────────
                    _FeaturedMenuButton(
                      label: 'NEW GAME',
                      startButtonAsset: AppAssets.menuStartButton,
                      onPressed: _onNewGame,
                    ),

                    SizedBox(height: size.height * 0.018),

                    // ── Secondary buttons (2-column grid) ────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _SecondaryMenuButton(
                            label: 'CO-OP',
                            lettersAsset: AppAssets.menuLetters,
                            onPressed: _onCoop,
                          ),
                        ),
                        SizedBox(width: size.width * 0.015),
                        Expanded(
                          child: _SecondaryMenuButton(
                            label: 'OPTIONS',
                            lettersAsset: AppAssets.menuLetters,
                            onPressed: _onOptions,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.012),

                    Row(
                      children: [
                        Expanded(
                          child: _SecondaryMenuButton(
                            label: 'ELEMENTS',
                            lettersAsset: AppAssets.menuLetters,
                            onPressed: _onElements,
                          ),
                        ),
                        SizedBox(width: size.width * 0.015),
                        Expanded(
                          child: _SecondaryMenuButton(
                            label: 'EXIT',
                            lettersAsset: AppAssets.menuLetters,
                            onPressed: _onExit,
                            isDanger: true,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.04),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Featured "NEW GAME" button
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturedMenuButton extends StatefulWidget {
  const _FeaturedMenuButton({
    required this.label,
    required this.onPressed,
    required this.startButtonAsset,
  });

  final String label;
  final VoidCallback onPressed;
  final String startButtonAsset;

  @override
  State<_FeaturedMenuButton> createState() => _FeaturedMenuButtonState();
}

class _FeaturedMenuButtonState extends State<_FeaturedMenuButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: size.height * 0.1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: _hovered
                  ? [const Color(0xFF9B30D9), const Color(0xFF7820B3)]
                  : [const Color(0xFF7B20B9), const Color(0xFF5810A0)],
            ),
            border: Border.all(
              color: _hovered ? AppColors.accentLight : AppColors.accent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.xpPurple.withAlpha(_hovered ? 100 : 50),
                blurRadius: _hovered ? 18 : 8,
                spreadRadius: _hovered ? 2 : 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left decoration icon
              Image.asset(
                widget.startButtonAsset,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
                color: AppColors.accentLight,
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.auto_awesome,
                  color: AppColors.accentLight,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: 15,
                  letterSpacing: 3,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: AppColors.xpPurple.withAlpha(200),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Right decoration icon
              Image.asset(
                widget.startButtonAsset,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
                color: AppColors.accentLight,
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.auto_awesome,
                  color: AppColors.accentLight,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Secondary menu button (COOP / OPTIONS / ELEMENTS / EXIT)
// ─────────────────────────────────────────────────────────────────────────────

class _SecondaryMenuButton extends StatefulWidget {
  const _SecondaryMenuButton({
    required this.label,
    required this.onPressed,
    required this.lettersAsset,
    this.isDanger = false,
  });

  final String label;
  final VoidCallback onPressed;
  final String lettersAsset;
  final bool isDanger;

  @override
  State<_SecondaryMenuButton> createState() => _SecondaryMenuButtonState();
}

class _SecondaryMenuButtonState extends State<_SecondaryMenuButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final baseColor = widget.isDanger
        ? const Color(0xFF4A1515)
        : const Color(0xFF1E1035);
    final hoverColor = widget.isDanger
        ? const Color(0xFF6A2020)
        : const Color(0xFF2D1B50);
    final borderColor = widget.isDanger
        ? AppColors.dangerRed.withAlpha(180)
        : AppColors.borderColor;
    final labelColor =
        widget.isDanger ? const Color(0xFFFF8888) : AppColors.textPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: size.height * 0.085,
          decoration: BoxDecoration(
            color: _hovered ? hoverColor : baseColor.withAlpha(200),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: _hovered
                ? [BoxShadow(color: AppColors.xpPurple.withAlpha(40), blurRadius: 10)]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left wing icon
              Image.asset(
                widget.lettersAsset,
                width: 16,
                height: 16,
                color: _hovered ? AppColors.accent : AppColors.textSecondary,
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.chevron_right,
                  color: _hovered ? AppColors.accent : AppColors.textSecondary,
                  size: 14,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: labelColor,
                  letterSpacing: 2.5,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 6),
              // Right wing icon
              Image.asset(
                widget.lettersAsset,
                width: 16,
                height: 16,
                color: _hovered ? AppColors.accent : AppColors.textSecondary,
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.chevron_left,
                  color: _hovered ? AppColors.accent : AppColors.textSecondary,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
