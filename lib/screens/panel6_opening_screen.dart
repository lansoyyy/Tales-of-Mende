import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import 'panel7_window_scene.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SCRIPT DATA MODEL
// ════════════════════════════════════════════════════════════════════════════

enum _EntryType {
  narrative, // italic story text, no speaker label
  innerThought, // italic, player inner voice (gold tint)
  dialogue, // speaker + body text
  sfxBeat, // auto-advance marker shown as chip
  popUpFx, // brief white flash, auto-advance
  letterReveal, // show parchment overlay
  endScene, // fade-out sentinel
}

class _ScriptEntry {
  const _ScriptEntry(this.type, this.text);
  final _EntryType type;
  final String text;
}

const List<_ScriptEntry> _openingScript = [
  // ── Fade in
  _ScriptEntry(_EntryType.sfxBeat, '[Fade In]'),

  // ── Staircase opening
  _ScriptEntry(
    _EntryType.narrative,
    'You descend the stairs, humming an impromptu tune to yourself as you '
    'grab a glass of coffee to start your day. It had been days since your '
    'interview for the internship. You remembered scrambling your own words; '
    'your hands were so clammy you left a damp mark on your pants after you '
    'were told you could leave the room. You winced at the memory.',
  ),

  _ScriptEntry(_EntryType.endScene, ''),
];

const String _letterBody =
    'Greetings!\n\n'
    'We are pleased to offer you a place as an Alchemist Intern at Elixir '
    'Enterprises. Your journey with us begins on the 3rd of April, where you '
    'will join the ranks of the Genius Society. We look forward to the energy '
    'you will bring to our halls.\n\n'
    'Send word of your acceptance by the 31st of March, and your place shall '
    'be secured.\n\n'
    'Until then, we await your reply.\n\n'
    'Sincerely,\n'
    'Dr. Marshal Graham\n'
    'Head of Genius Society\n'
    'Elixir Enterprises';

// ════════════════════════════════════════════════════════════════════════════
//  STAIRCASE BACKGROUND PAINTER
// ════════════════════════════════════════════════════════════════════════════

class _StaircasePainter extends CustomPainter {
  const _StaircasePainter();

  // Warm interior palette
  static const Color _wallTop = Color(0xFFF5EDD5);
  static const Color _wallBottom = Color(0xFFE8D9BB);
  static const Color _wallSide = Color(0xFFDDD0B0);
  static const Color _treadTop = Color(0xFF8B6035); // step top face
  static const Color _treadFront = Color(0xFF6B4520); // step riser face
  static const Color _treadEdge = Color(0xFFA07840); // bright leading edge
  static const Color _rail = Color(0xFF4A2E10); // banister rail
  static const Color _spindle = Color(0xFF5A3818); // spindle
  static const Color _newelPost = Color(0xFF3A2008); // thick post at base
  static const Color _frameOuter = Color(0xFF3A2E20);
  static const Color _frameInner = Color(0xFFD5C8A8);
  static const Color _shadowStep = Color(0x33000000);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 1. Wall gradient ─────────────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [_wallTop, _wallBottom],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // ── 2. Left wall wing (slightly darker) ────────────────────────────────
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(w * 0.28, 0)
        ..lineTo(w * 0.28, h)
        ..lineTo(0, h)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_wallSide, _wallSide.withAlpha(0)],
        ).createShader(Rect.fromLTWH(0, 0, w * 0.28, h)),
    );

    // ── 3. Window bloom (top-center radial glow) ────────────────────────────
    final bloomCenter = Offset(w * 0.72, h * 0.08);
    canvas.drawCircle(
      bloomCenter,
      h * 0.38,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0xCCFFFBE6),
            Color(0x66F5EDCC),
            Color(0x00F0E0B0),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(
          Rect.fromCircle(center: bloomCenter, radius: h * 0.38),
        ),
    );

    // ── 4. Stair steps ───────────────────────────────────────────────────
    const int stepCount = 7;
    final stairLeft = w * 0.10;
    final stairRight = w * 0.95;
    final stairBottom = h * 0.92;
    final vpX = w * 0.72;
    final baseStepH = h * 0.11;
    final baseRiserH = h * 0.055;

    for (int i = 0; i < stepCount; i++) {
      final t = i / stepCount;
      final pScale = 1.0 - t * 0.62;

      final leftX = _lerp(stairLeft, vpX * 0.68, t);
      final rightX = _lerp(stairRight, vpX * 1.05, t).clamp(0.0, w);
      final bottomY = stairBottom - i * (baseStepH + baseRiserH) * 0.72;
      final topY = bottomY - baseStepH * pScale;
      final riserBottom = bottomY + baseRiserH * pScale;

      // Tread top face
      canvas.drawPath(
        Path()
          ..moveTo(leftX, topY)
          ..lineTo(rightX, topY)
          ..lineTo(rightX, bottomY)
          ..lineTo(leftX, bottomY)
          ..close(),
        Paint()..color = _treadTop,
      );

      // Shadow on far end
      canvas.drawPath(
        Path()
          ..moveTo(rightX - w * 0.06, topY)
          ..lineTo(rightX, topY)
          ..lineTo(rightX, bottomY)
          ..lineTo(rightX - w * 0.06, bottomY)
          ..close(),
        Paint()..color = _shadowStep,
      );

      // Leading edge highlight
      canvas.drawLine(
        Offset(leftX, bottomY),
        Offset(rightX, bottomY),
        Paint()
          ..color = _treadEdge
          ..strokeWidth = 2.0,
      );

      // Riser / front face
      canvas.drawPath(
        Path()
          ..moveTo(leftX, bottomY)
          ..lineTo(rightX, bottomY)
          ..lineTo(rightX, riserBottom)
          ..lineTo(leftX, riserBottom)
          ..close(),
        Paint()..color = _treadFront,
      );
    }

    // ── 5. Banister rails ─────────────────────────────────────────────────
    final railPaint = Paint()
      ..color = _rail
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final leftRailStart = Offset(stairLeft + w * 0.08, stairBottom - h * 0.02);
    final leftRailEnd = Offset(w * 0.20, h * 0.22);
    canvas.drawLine(leftRailStart, leftRailEnd, railPaint);

    final rightRailStart = Offset(stairRight - w * 0.04, stairBottom - h * 0.02);
    final rightRailEnd = Offset(w * 0.76, h * 0.22);
    canvas.drawLine(rightRailStart, rightRailEnd, railPaint);

    // ── 6. Spindles ────────────────────────────────────────────────────────
    const int spindleCount = 10;
    final spindlePaint = Paint()
      ..color = _spindle
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.butt;

    for (int i = 0; i < spindleCount; i++) {
      final f = i / (spindleCount - 1);
      final topX = _lerp(leftRailEnd.dx, leftRailStart.dx, f);
      final topY = _lerp(leftRailEnd.dy, leftRailStart.dy, f);
      final spH = h * 0.10 * (1.0 - f * 0.5);
      canvas.drawLine(Offset(topX, topY), Offset(topX, topY + spH), spindlePaint);
    }
    for (int i = 0; i < spindleCount; i++) {
      final f = i / (spindleCount - 1);
      final topX = _lerp(rightRailEnd.dx, rightRailStart.dx, f);
      final topY = _lerp(rightRailEnd.dy, rightRailStart.dy, f);
      final spH = h * 0.10 * (1.0 - f * 0.5);
      canvas.drawLine(Offset(topX, topY), Offset(topX, topY + spH), spindlePaint);
    }

    // ── 7. Newel posts ─────────────────────────────────────────────────────
    final newelPaint = Paint()..color = _newelPost;
    final postW = w * 0.025;
    final postH = h * 0.14;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(leftRailStart.dx - postW / 2, leftRailStart.dy - postH, postW, postH),
        const Radius.circular(3),
      ),
      newelPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rightRailStart.dx - postW / 2, rightRailStart.dy - postH, postW, postH),
        const Radius.circular(3),
      ),
      newelPaint,
    );

    // ── 8. Picture frame on right wall ────────────────────────────────────
    final frameL = w * 0.78;
    final frameT = h * 0.28;
    final frameW = w * 0.09;
    final frameHt = h * 0.12;

    canvas.drawRect(Rect.fromLTWH(frameL, frameT, frameW, frameHt), Paint()..color = _frameOuter);
    canvas.drawRect(
      Rect.fromLTWH(frameL + w * 0.01, frameT + h * 0.015, frameW - w * 0.02, frameHt - h * 0.03),
      Paint()..color = _frameInner,
    );

    // ── 9. Floor landing at bottom ────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, stairBottom, w, h - stairBottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_treadTop, _treadTop.withAlpha(200)],
        ).createShader(Rect.fromLTWH(0, stairBottom, w, h - stairBottom)),
    );

  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ════════════════════════════════════════════════════════════════════════════
//  PANEL 6 — OPENING SCENE SCREEN
// ════════════════════════════════════════════════════════════════════════════

class Panel6OpeningScreen extends StatefulWidget {
  const Panel6OpeningScreen({super.key});

  @override
  State<Panel6OpeningScreen> createState() => _Panel6OpeningScreenState();
}

class _Panel6OpeningScreenState extends State<Panel6OpeningScreen>
    with TickerProviderStateMixin {
  // ── Beat index ────────────────────────────────────────────────────────
  int _beatIndex = 0;
  bool _showingLetter = false;
  bool _endSceneStarted = false;

  // ── Typewriter ────────────────────────────────────────────────────────
  late AnimationController _typeCtrl;
  late Animation<int> _typeAnim;

  // ── Blink indicator ───────────────────────────────────────────────────
  late AnimationController _blinkCtrl;

  // ── Initial fade-in ───────────────────────────────────────────────────
  late AnimationController _fadeInCtrl;
  late Animation<double> _fadeIn;

  // ── SFX chip ──────────────────────────────────────────────────────────
  late AnimationController _sfxCtrl;
  late Animation<double> _sfxAnim;
  String _sfxLabel = '';
  bool _sfxVisible = false;

  // ── Pop-up FX (white flash) ───────────────────────────────────────────
  late AnimationController _flashCtrl;
  late Animation<double> _flashAnim;

  // ── End-scene fade-to-black ───────────────────────────────────────────
  late AnimationController _endFadeCtrl;
  late Animation<double> _endFade;

  // ── End banner opacity ────────────────────────────────────────────────
  late AnimationController _endBannerCtrl;
  late Animation<double> _endBanner;

  _ScriptEntry get _currentEntry => _openingScript[_beatIndex];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _fadeInCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _fadeInCtrl, curve: Curves.easeIn);

    _typeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _typeAnim = const AlwaysStoppedAnimation<int>(0);

    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..repeat(reverse: true);

    _sfxCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _sfxAnim = CurvedAnimation(parent: _sfxCtrl, curve: Curves.easeIn);

    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flashAnim = CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut);

    _endFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _endFade = CurvedAnimation(parent: _endFadeCtrl, curve: Curves.easeIn);

    _endBannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _endBanner = CurvedAnimation(parent: _endBannerCtrl, curve: Curves.easeIn);

    _processBeat();
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _blinkCtrl.dispose();
    _fadeInCtrl.dispose();
    _sfxCtrl.dispose();
    _flashCtrl.dispose();
    _endFadeCtrl.dispose();
    _endBannerCtrl.dispose();
    super.dispose();
  }

  // ── Beat processing ───────────────────────────────────────────────────

  void _processBeat() {
    if (_beatIndex >= _openingScript.length) return;
    final entry = _currentEntry;

    switch (entry.type) {
      case _EntryType.sfxBeat:
        if (_beatIndex == 0) _fadeInCtrl.forward();
        _showSfxChip(entry.text);
      case _EntryType.popUpFx:
        _triggerWhiteFlash();
      case _EntryType.letterReveal:
        _showLetterOverlay();
      case _EntryType.endScene:
        _triggerEndScene();
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
    if (_showingLetter || _endSceneStarted) return;
    final entry = _currentEntry;
    if (entry.type == _EntryType.sfxBeat || entry.type == _EntryType.popUpFx) return;
    if (_typeCtrl.isAnimating) {
      _typeCtrl.value = 1.0;
      return;
    }
    _advanceBeat();
  }

  void _advanceBeat() {
    if (_beatIndex < _openingScript.length - 1) {
      setState(() => _beatIndex++);
      _processBeat();
    }
  }

  void _showSfxChip(String label) {
    setState(() {
      _sfxLabel = label;
      _sfxVisible = true;
    });
    _sfxCtrl.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        _sfxCtrl.reverse().then((_) {
          if (!mounted) return;
          setState(() => _sfxVisible = false);
          _advanceBeat();
        });
      });
    });
  }

  void _triggerWhiteFlash() {
    _flashCtrl.forward(from: 0).then((_) {
      _flashCtrl.reverse().then((_) {
        if (!mounted) return;
        _advanceBeat();
      });
    });
  }

  void _showLetterOverlay() {
    if (_showingLetter) return;
    setState(() => _showingLetter = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (_) => const _LetterOverlay(),
      ).then((_) {
        if (!mounted) return;
        setState(() => _showingLetter = false);
        _advanceBeat();
      });
    });
  }

  void _triggerEndScene() {
    setState(() => _endSceneStarted = true);
    _endFadeCtrl.forward().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const Panel7WindowScene(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
              // ── Staircase background
              CustomPaint(
                painter: const _StaircasePainter(),
                size: Size.infinite,
              ),

              // ── Bottom readability gradient
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: MediaQuery.of(context).size.height * 0.48,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0xDD050210)],
                      ),
                    ),
                  ),
                ),
              ),

              // ── VN text box
              if (!_endSceneStarted) _buildTextBox(),

              // ── Skip hint
              if (!_endSceneStarted) _buildSkipHint(),

              // ── SFX chip
              if (_sfxVisible)
                Positioned(
                  top: 48,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _sfxAnim,
                    child: Center(child: _SfxChip(label: _sfxLabel)),
                  ),
                ),

              // ── White flash
              IgnorePointer(
                child: FadeTransition(
                  opacity: _flashAnim,
                  child: Container(color: Colors.white),
                ),
              ),

              // ── End fade-to-black
              IgnorePointer(
                child: FadeTransition(
                  opacity: _endFade,
                  child: Container(color: Colors.black),
                ),
              ),

              // ── "End of Scene" banner
              IgnorePointer(
                child: FadeTransition(
                  opacity: _endBanner,
                  child: Center(
                    child: Text(
                      'End of Scene',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.accentLight,
                        letterSpacing: 3,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
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
    if (entry.type == _EntryType.sfxBeat ||
        entry.type == _EntryType.popUpFx ||
        entry.type == _EntryType.endScene ||
        entry.type == _EntryType.letterReveal) {
      return const SizedBox.shrink();
    }

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
    final isAuto =
        entry.type == _EntryType.sfxBeat ||
        entry.type == _EntryType.popUpFx ||
        entry.type == _EntryType.endScene ||
        entry.type == _EntryType.letterReveal;
    if (isAuto) return const SizedBox.shrink();

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
    final textStyle = switch (entry.type) {
      _EntryType.narrative => AppTextStyles.narrative,
      _EntryType.innerThought => AppTextStyles.narrative.copyWith(
          color: AppColors.accentLight,
        ),
      _ => AppTextStyles.bodyMedium,
    };

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xD40A0718),
        border: Border(
          top: BorderSide(color: AppColors.accent, width: 1.5),
        ),
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

// ════════════════════════════════════════════════════════════════════════════
//  SFX CHIP
// ════════════════════════════════════════════════════════════════════════════

class _SfxChip extends StatelessWidget {
  const _SfxChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(220),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withAlpha(180)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: AppColors.accentLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  LETTER OVERLAY
// ════════════════════════════════════════════════════════════════════════════

class _LetterOverlay extends StatelessWidget {
  const _LetterOverlay();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          color: const Color(0xBB000000),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              decoration: BoxDecoration(
                color: const Color(0xFFF5E6C8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFB8973C), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x88000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Wax seal
                    Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF8B1A1A),
                          border: Border.all(color: const Color(0xFFCC4444), width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            'E',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Letter body
                    Text(
                      _letterBody,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF3A2008),
                        height: 1.75,
                        fontSize: 14,
                        fontStyle: FontStyle.normal,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Dismiss hint
                    Center(
                      child: Text(
                        'Tap anywhere to continue',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF7A5A28),
                          letterSpacing: 1.0,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
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
    );
  }
}

