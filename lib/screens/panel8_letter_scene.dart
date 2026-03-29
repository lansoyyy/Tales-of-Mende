import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/app_assets.dart';
import 'quest1_panel1_hallway.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SCRIPT — Panel 8
// ════════════════════════════════════════════════════════════════════════════

enum _EntryType {
  narrative,
  innerThought,
  dialogue,
  sfxBeat,
  popUpFx,
  letterReveal,
  endScene,
}

class _ScriptEntry {
  const _ScriptEntry(this.type, this.text);
  final _EntryType type;
  final String text;
}

const List<_ScriptEntry> _script = [
  _ScriptEntry(
    _EntryType.narrative,
    'Your eyes widened as you scanned the paper one more time. Copper raised '
    'a brow in amusement at your reaction. He looked at you in anticipation '
    'while you stared at the last sentence of the letter.',
  ),
  _ScriptEntry(_EntryType.endScene, ''),
];

// ════════════════════════════════════════════════════════════════════════════
//  LETTER READING BACKGROUND PAINTER
// ════════════════════════════════════════════════════════════════════════════

class _LetterReadingPainter extends CustomPainter {
  const _LetterReadingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dark atmospheric interior
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Color(0xFF1C0F32), Color(0xFF0A050E)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Warm glow in the upper-center (mimicking light on the letter)
    final glowCenter = Offset(w * 0.50, h * 0.35);
    canvas.drawCircle(
      glowCenter,
      h * 0.32,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0x30D4A853), Color(0x00000000)],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromCircle(center: glowCenter, radius: h * 0.32),
        ),
    );

    // Subtle desk surface at the bottom (warm dark wood)
    final deskY = h * 0.75;
    canvas.drawRect(
      Rect.fromLTWH(0, deskY, w, h - deskY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF2A1A0A), Color(0xFF180E06)],
        ).createShader(Rect.fromLTWH(0, deskY, w, h - deskY)),
    );
    // Desk edge highlight
    canvas.drawLine(
      Offset(0, deskY),
      Offset(w, deskY),
      Paint()
        ..color = const Color(0xFF5A3818)
        ..strokeWidth = 1.5,
    );

    // Vignette
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: const [Color(0x00000000), Color(0x99000000)],
          stops: const [0.45, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ════════════════════════════════════════════════════════════════════════════
//  PANEL 8 — LETTER READING SCENE
// ════════════════════════════════════════════════════════════════════════════

class Panel8LetterScene extends StatefulWidget {
  const Panel8LetterScene({super.key});

  @override
  State<Panel8LetterScene> createState() => _Panel8LetterSceneState();
}

class _Panel8LetterSceneState extends State<Panel8LetterScene>
    with TickerProviderStateMixin {
  int _beatIndex = 0;
  bool _endSceneStarted = false;

  late AnimationController _typeCtrl;
  late Animation<int> _typeAnim;
  late AnimationController _blinkCtrl;
  late AnimationController _fadeInCtrl;
  late Animation<double> _fadeIn;
  late AnimationController _endFadeCtrl;
  late Animation<double> _endFade;

  // Letter image subtle float animation
  late AnimationController _floatCtrl;
  late Animation<double> _float;

  _ScriptEntry get _currentEntry => _script[_beatIndex];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _fadeInCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _fadeInCtrl, curve: Curves.easeIn);

    _typeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _typeAnim = const AlwaysStoppedAnimation<int>(0);

    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..repeat(reverse: true);

    _endFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _endFade = CurvedAnimation(parent: _endFadeCtrl, curve: Curves.easeIn);

    // Letter floating animation
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _processBeat();
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _blinkCtrl.dispose();
    _fadeInCtrl.dispose();
    _endFadeCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  // ── Beat processing ─────────────────────────────────────────────────────

  void _processBeat() {
    if (_beatIndex >= _script.length) return;
    final entry = _currentEntry;

    switch (entry.type) {
      case _EntryType.endScene:
        _triggerEndScene();
      case _EntryType.sfxBeat:
        // No sfx beats in panel8, no-op
        _advanceBeat();
      case _EntryType.popUpFx:
        _advanceBeat();
      case _EntryType.letterReveal:
        _advanceBeat();
      case _EntryType.narrative:
      case _EntryType.innerThought:
      case _EntryType.dialogue:
        _startTypewriter(entry.text);
    }
  }

  void _startTypewriter(String text) {
    final durationMs = math.min(text.length * 28, 3200);
    _typeCtrl.duration = Duration(milliseconds: durationMs);
    _typeAnim = IntTween(begin: 0, end: text.length).animate(
      CurvedAnimation(parent: _typeCtrl, curve: Curves.linear),
    );
    _typeCtrl
      ..reset()
      ..forward();
  }

  void _onTap() {
    if (_endSceneStarted) return;
    if (_typeCtrl.isAnimating) {
      _typeCtrl.value = 1.0;
      return;
    }
    _advanceBeat();
  }

  void _advanceBeat() {
    if (_beatIndex < _script.length - 1) {
      setState(() => _beatIndex++);
      _processBeat();
    }
  }

  void _triggerEndScene() {
    setState(() => _endSceneStarted = true);
    _endFadeCtrl.forward().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const Quest1Panel1Hallway(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Letter image sits in the upper ~50% of screen, above the text box
    final letterAreaHeight = size.height * 0.50;
    // Size the pixel-art letter to be prominent but not overpowering
    final letterImgWidth = (size.width * 0.46).clamp(140.0, 280.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: FadeTransition(
          opacity: _fadeIn,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Dark atmospheric background
              CustomPaint(
                painter: const _LetterReadingPainter(),
                size: Size.infinite,
              ),

              // ── Pixel-art letter image (centered, floating)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: letterAreaHeight,
                child: AnimatedBuilder(
                  animation: _float,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _float.value),
                    child: child,
                  ),
                  child: Center(
                    child: Image.asset(
                      AppAssets.storyLetters,
                      width: letterImgWidth,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none, // crisp pixel art
                      errorBuilder: (_, __, ___) => _DrawnLetter(
                        width: letterImgWidth,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Bottom readability gradient
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: size.height * 0.52,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0xEE030110)],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Edge vignette
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.3,
                      colors: const [Colors.transparent, Color(0xAA000000)],
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),

              // ── Location badge (top-left)
              const Positioned(
                top: 20,
                left: 20,
                child: _LocationBadge(label: 'Home  ·  Study'),
              ),

              // ── Panel chip (top-right)
              const Positioned(
                top: 20,
                right: 20,
                child: _PanelChip(label: 'P8'),
              ),

              // ── VN text box
              if (!_endSceneStarted) _buildTextBox(),

              // ── Skip hint
              if (!_endSceneStarted) _buildSkipHint(),

              // ── Fade-to-black
              IgnorePointer(
                child: FadeTransition(
                  opacity: _endFade,
                  child: Container(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextBox() {
    final entry = _currentEntry;
    if (entry.type == _EntryType.endScene) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedBuilder(
        animation: Listenable.merge([_typeCtrl, _blinkCtrl]),
        builder: (context, _) {
          final chars = _typeAnim.value;
          final full = entry.text;
          final display = full.substring(0, chars.clamp(0, full.length));
          final isDone = !_typeCtrl.isAnimating && _typeCtrl.value >= 1.0;
          return _VnTextBox(
            entry: entry,
            displayText: display,
            showBlink: isDone,
            blinkOpacity: _blinkCtrl.value,
          );
        },
      ),
    );
  }

  Widget _buildSkipHint() {
    final entry = _currentEntry;
    if (entry.type == _EntryType.endScene) return const SizedBox.shrink();

    return Positioned(
      top: 16,
      right: 16,
      child: Opacity(
        opacity: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Tap to continue',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  FALLBACK: drawn pixel-art letter (if asset missing)
// ════════════════════════════════════════════════════════════════════════════

class _DrawnLetter extends StatelessWidget {
  const _DrawnLetter({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * 1.3),
      painter: _PixelLetterPainter(),
    );
  }
}

class _PixelLetterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = size.width / 10;
    // Paper body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(p * 0.5, 0, p * 9, p * 13),
        Radius.circular(p * 0.3),
      ),
      Paint()..color = const Color(0xFFD8D0E8),
    );
    // Pixel-style shadow border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(p * 0.5, 0, p * 9, p * 13),
        Radius.circular(p * 0.3),
      ),
      Paint()
        ..color = const Color(0xFF6060A0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = p * 0.4,
    );
    // Text lines (simplified pixel rows)
    final linePaint = Paint()..color = const Color(0xFF8080C0);
    for (int i = 0; i < 6; i++) {
      canvas.drawRect(
        Rect.fromLTWH(p * 1.5, p * (2.0 + i * 1.6), p * 6.5, p * 0.5),
        linePaint,
      );
    }
    // Wax seal circle
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.78),
      p * 1.2,
      Paint()..color = const Color(0xFFAA3030),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ════════════════════════════════════════════════════════════════════════════
//  LOCATION BADGE
// ════════════════════════════════════════════════════════════════════════════

class _LocationBadge extends StatelessWidget {
  const _LocationBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xBB060318),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withAlpha(100), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withAlpha(25),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_outlined,
              color: AppColors.accentLight, size: 12),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  PANEL CHIP
// ════════════════════════════════════════════════════════════════════════════

class _PanelChip extends StatelessWidget {
  const _PanelChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withAlpha(70)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.accent,
          fontSize: 10,
          letterSpacing: 1.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  VN TEXT BOX
// ════════════════════════════════════════════════════════════════════════════

class _VnTextBox extends StatelessWidget {
  const _VnTextBox({
    required this.entry,
    required this.displayText,
    required this.showBlink,
    required this.blinkOpacity,
  });

  final _ScriptEntry entry;
  final String displayText;
  final bool showBlink;
  final double blinkOpacity;

  @override
  Widget build(BuildContext context) {
    final textStyle = entry.type == _EntryType.innerThought
        ? AppTextStyles.narrative.copyWith(color: AppColors.accentLight)
        : AppTextStyles.narrative;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xD40A0718),
        border: Border(top: BorderSide(color: AppColors.accent, width: 1.5)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text(displayText, style: textStyle)),
          if (showBlink)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Opacity(
                opacity: blinkOpacity,
                child: Text(
                  '▼',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accentLight,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
