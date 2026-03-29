import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/utils/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import 'panel5_game_loading_screen.dart';

/// Panel 4 — "Are You Ready?" Screen
///
/// Retro arcade-style START board centered on the landscape background.
/// Inspired by a pixel/retro game START screen with YES / NO choices.
class Panel4AreYouReadyScreen extends StatefulWidget {
  const Panel4AreYouReadyScreen({super.key});

  @override
  State<Panel4AreYouReadyScreen> createState() =>
      _Panel4AreYouReadyScreenState();
}

class _Panel4AreYouReadyScreenState extends State<Panel4AreYouReadyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  // Tracks which choice is highlighted (null = none, true = YES, false = NO)
  bool? _selected;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // "START" text pulses
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onYes() {
    setState(() => _selected = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const Panel5GameLoadingScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  void _onNo() {
    setState(() => _selected = false);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  // ── Palette ───────────────────────────────────────────────────────────────
  static const Color _boardBg = Color(0xFF0D0520);
  static const Color _boardBorder = Color(0xFF3A2A70);
  static const Color _gridLine = Color(0xFF1E1050);
  static const Color _goldAccent = Color(0xFFD4A853);
  static const Color _goldGlow = Color(0x66D4A853);
  static const Color _heartRed = Color(0xFFFF4466);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ──────────────────────────────────────────────────
          Image.asset(
            AppAssets.readyBackground,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF0D0828)),
          ),
          Container(color: const Color(0xAA0D0828)),

          // ── Centered arcade board ───────────────────────────────────────
          Center(child: _buildArcadeBoard(size)),
        ],
      ),
    );
  }

  Widget _buildArcadeBoard(Size size) {
    final boardW = (size.width * 0.62).clamp(300.0, 520.0);
    final boardH = (size.height * 0.82).clamp(220.0, 340.0);

    return Container(
      width: boardW,
      height: boardH,
      decoration: BoxDecoration(
        color: _boardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _boardBorder, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.xpPurple.withAlpha(80),
            blurRadius: 30,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(160),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Grid lines (retro CRT effect)
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: CustomPaint(
              size: Size(boardW, boardH),
              painter: _GridPainter(color: _gridLine),
            ),
          ),

          // Board decoration corners
          Positioned(top: 6, left: 6, child: _boardCornerIcon()),
          Positioned(top: 6, right: 6, child: _boardCornerIcon()),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                // ── Top row: HI-SCORE | Hearts ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HI-SCORE',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _goldAccent,
                            letterSpacing: 1.5,
                            fontSize: 9,
                          ),
                        ),
                        Text(
                          '000000',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: _goldAccent,
                            letterSpacing: 2,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    // Hearts row
                    Row(
                      children: List.generate(
                        5,
                        (i) => Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.favorite,
                            color: _heartRed,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // ── "START" pulsing text ────────────────────────────────
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Text(
                    'START',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: _goldAccent,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(color: _goldGlow, blurRadius: 20),
                        const Shadow(color: Color(0x33D4A853), blurRadius: 40),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // "ARE YOU READY?" using asset + text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.readyLetter,
                      width: 16,
                      height: 16,
                      color: Colors.white.withAlpha(200),
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ARE YOU READY?',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white.withAlpha(200),
                        letterSpacing: 3,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Image.asset(
                      AppAssets.readyLetter,
                      width: 16,
                      height: 16,
                      color: Colors.white.withAlpha(200),
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── YES / NO ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RetroChoiceButton(
                      label: 'YES',
                      isSelected: _selected == true,
                      arrowSide: AxisDirection.right,
                      onTap: _onYes,
                      color: _goldAccent,
                    ),
                    const SizedBox(width: 40),
                    _RetroChoiceButton(
                      label: 'NO',
                      isSelected: _selected == false,
                      arrowSide: AxisDirection.left,
                      onTap: _onNo,
                      color: Colors.white,
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _boardCornerIcon() {
    return Image.asset(
      AppAssets.readyBoard,
      width: 20,
      height: 20,
      color: AppColors.xpPurple.withAlpha(160),
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (_, __, ___) => const SizedBox(),
    );
  }
}

// ─── Retro YES/NO choice button ───────────────────────────────────────────────

class _RetroChoiceButton extends StatefulWidget {
  const _RetroChoiceButton({
    required this.label,
    required this.isSelected,
    required this.arrowSide,
    required this.onTap,
    required this.color,
  });

  final String label;
  final bool isSelected;
  final AxisDirection arrowSide;
  final VoidCallback onTap;
  final Color color;

  @override
  State<_RetroChoiceButton> createState() => _RetroChoiceButtonState();
}

class _RetroChoiceButtonState extends State<_RetroChoiceButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected || _hovered;
    final arrow = widget.arrowSide == AxisDirection.right ? '◄' : '►';
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 120),
          style: AppTextStyles.headlineSmall.copyWith(
            color: active ? widget.color : widget.color.withAlpha(160),
            fontSize: active ? 22 : 18,
            letterSpacing: 3,
            shadows: active
                ? [Shadow(color: widget.color.withAlpha(150), blurRadius: 12)]
                : [],
          ),
          child: Text(
            widget.arrowSide == AxisDirection.right
                ? '${widget.label}$arrow'
                : '$arrow${widget.label}',
          ),
        ),
      ),
    );
  }
}

// ─── CRT grid painter ─────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;
    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}
