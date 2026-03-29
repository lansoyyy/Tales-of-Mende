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

  // Atmospheric morning palette — warm amber, dramatic shadows, dark mahogany
  static const Color _wallLight  = Color(0xFFCFAB72); // warm amber upper
  static const Color _wallMid    = Color(0xFF8B6030); // mid amber-brown
  static const Color _wallDark   = Color(0xFF2E1508); // deep base brown
  static const Color _wallSide   = Color(0xFF1A0C04); // deep side shadow
  static const Color _treadFront = Color(0xFF2A1408); // very dark riser
  static const Color _treadEdge  = Color(0xFFD4A853); // gold leading edge
  static const Color _treadShine = Color(0x44D4A853); // gold edge shimmer
  static const Color _rail       = Color(0xFF1E0E06); // ebony banister rail
  static const Color _spindle    = Color(0xFF2E1A08); // dark walnut spindle
  static const Color _newelPost  = Color(0xFF180A04); // very dark newel post
  static const Color _shadowStep = Color(0x66000000); // under-step shadow

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 1. Atmospheric wall gradient (morning light from upper-right) ──────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: const [_wallLight, _wallMid, _wallDark],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // ── 2. Left wall deep shadow wing ─────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w * 0.22, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_wallSide, _wallSide.withAlpha(0)],
        ).createShader(Rect.fromLTWH(0, 0, w * 0.22, h)),
    );

    // ── 3. Diagonal morning light shaft from upper-right off-screen window ─
    final lightPath = Path()
      ..moveTo(w * 0.68, 0)
      ..lineTo(w, 0)
      ..lineTo(w * 0.58, h * 0.58)
      ..lineTo(w * 0.25, h * 0.58)
      ..close();
    canvas.drawPath(
      lightPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: const [Color(0x55FEC95A), Color(0x00FEC95A)],
        ).createShader(Rect.fromLTWH(w * 0.25, 0, w * 0.75, h * 0.58)),
    );

    // ── 4. Wainscot paneling on left wall ─────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.60, w * 0.25, 4.0),
      Paint()..color = const Color(0xFF6B4020),
    );
    for (int i = 0; i < 2; i++) {
      final panelT = h * 0.65 + i * h * 0.15;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.022, panelT, w * 0.18, h * 0.12),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0x22000000),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.027, panelT + h * 0.005, w * 0.17, h * 0.11),
          const Radius.circular(2),
        ),
        Paint()
          ..color = const Color(0x33C0803A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    // ── 5. Stair steps ────────────────────────────────────────────────────
    const int stepCount = 7;
    final stairLeft   = w * 0.12;
    final stairRight  = w * 0.94;
    final stairBottom = h * 0.90;
    final vpX         = w * 0.68;
    final baseStepH   = h * 0.10;
    final baseRiserH  = h * 0.055;

    for (int i = 0; i < stepCount; i++) {
      final t      = i / stepCount;
      final pScale = 1.0 - t * 0.60;
      final leftX   = _lerp(stairLeft, vpX * 0.72, t);
      final rightX  = _lerp(stairRight, vpX * 1.04, t).clamp(0.0, w);
      final bottomY = stairBottom - i * (baseStepH + baseRiserH) * 0.72;
      final topY    = bottomY - baseStepH * pScale;
      final riserBottom = bottomY + baseRiserH * pScale;

      // Tread — mahogany with light-to-dark gradient
      canvas.drawPath(
        Path()
          ..moveTo(leftX, topY)
          ..lineTo(rightX, topY)
          ..lineTo(rightX, bottomY)
          ..lineTo(leftX, bottomY)
          ..close(),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: const [Color(0xFF7A4A1A), Color(0xFF3E1E08)],
          ).createShader(Rect.fromLTWH(leftX, topY, rightX - leftX, bottomY - topY)),
      );

      // Far-end tread shadow
      canvas.drawPath(
        Path()
          ..moveTo(rightX - (rightX - leftX) * 0.16, topY)
          ..lineTo(rightX, topY)
          ..lineTo(rightX, bottomY)
          ..lineTo(rightX - (rightX - leftX) * 0.16, bottomY)
          ..close(),
        Paint()..color = _shadowStep,
      );

      // Gold leading-edge highlight
      canvas.drawLine(
        Offset(leftX, bottomY),
        Offset(rightX, bottomY),
        Paint()
          ..color = _treadEdge
          ..strokeWidth = 2.5,
      );
      canvas.drawLine(
        Offset(leftX, bottomY - 2),
        Offset(rightX, bottomY - 2),
        Paint()
          ..color = _treadShine
          ..strokeWidth = 1.5,
      );

      // Riser — very dark with gradient
      canvas.drawPath(
        Path()
          ..moveTo(leftX, bottomY)
          ..lineTo(rightX, bottomY)
          ..lineTo(rightX, riserBottom)
          ..lineTo(leftX, riserBottom)
          ..close(),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [_treadFront, Color(0xFF160A04)],
          ).createShader(
            Rect.fromLTWH(leftX, bottomY, rightX - leftX, riserBottom - bottomY),
          ),
      );
    }

    // ── 6. Banister rails ─────────────────────────────────────────────────
    final leftRailStart  = Offset(stairLeft + w * 0.06, stairBottom - h * 0.02);
    final leftRailEnd    = Offset(w * 0.22, h * 0.22);
    final rightRailStart = Offset(stairRight - w * 0.04, stairBottom - h * 0.02);
    final rightRailEnd   = Offset(w * 0.74, h * 0.22);

    // Rail drop shadow
    final railShadow = Paint()
      ..color = const Color(0x66000000)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(leftRailStart, leftRailEnd, railShadow);
    canvas.drawLine(rightRailStart, rightRailEnd, railShadow);

    // Rail body
    final railPaint = Paint()
      ..color = _rail
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(leftRailStart, leftRailEnd, railPaint);
    canvas.drawLine(rightRailStart, rightRailEnd, railPaint);

    // Rail top-shine
    final railShine = Paint()
      ..color = const Color(0x226B4020)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(leftRailStart, leftRailEnd, railShine);
    canvas.drawLine(rightRailStart, rightRailEnd, railShine);

    // ── 7. Spindles ────────────────────────────────────────────────────────
    const int spindleCount = 10;
    for (int i = 0; i < spindleCount; i++) {
      final f = i / (spindleCount - 1);
      final ltX = _lerp(leftRailEnd.dx, leftRailStart.dx, f);
      final ltY = _lerp(leftRailEnd.dy, leftRailStart.dy, f);
      final rtX = _lerp(rightRailEnd.dx, rightRailStart.dx, f);
      final rtY = _lerp(rightRailEnd.dy, rightRailStart.dy, f);
      final spH = h * 0.09 * (1.0 - f * 0.45);
      _drawSpindle(canvas, ltX, ltY, spH);
      _drawSpindle(canvas, rtX, rtY, spH);
    }

    // ── 8. Newel posts ─────────────────────────────────────────────────────
    _drawNewelPost(canvas, leftRailStart.dx, leftRailStart.dy, w * 0.028, h);
    _drawNewelPost(canvas, rightRailStart.dx, rightRailStart.dy, w * 0.028, h);

    // ── 9. Picture frame with gold border on right wall ───────────────────
    final frameL  = w * 0.77;
    final frameT  = h * 0.26;
    final frameW  = w * 0.10;
    final frameHt = h * 0.17;

    // Subtle glow halo behind frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(frameL - 6, frameT - 6, frameW + 12, frameHt + 12),
        const Radius.circular(6),
      ),
      Paint()
        ..color = const Color(0x33D4A853)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10),
    );
    // Gold outer frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(frameL, frameT, frameW, frameHt),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFD4A853),
    );
    // Inner dark bevel
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(frameL + 4, frameT + 4, frameW - 8, frameHt - 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF1E1008),
    );
    // Dark painting content
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(frameL + 7, frameT + 7, frameW - 14, frameHt - 14),
        const Radius.circular(1),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Color(0xFF2A3040), Color(0xFF0A1020)],
        ).createShader(
          Rect.fromLTWH(frameL + 7, frameT + 7, frameW - 14, frameHt - 14),
        ),
    );

    // ── 10. Wall sconce glow (light source on left wall) ──────────────────
    final sconceX = w * 0.14;
    final sconceY = h * 0.37;
    // Warm ambient glow (large soft bloom)
    canvas.drawCircle(
      Offset(sconceX, sconceY),
      h * 0.24,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0x55FEC95A), Color(0x22FEC95A), Color(0x00FEC95A)],
          stops: const [0.0, 0.40, 1.0],
        ).createShader(
          Rect.fromCircle(center: Offset(sconceX, sconceY), radius: h * 0.24),
        ),
    );
    // Sconce bracket
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(sconceX - 7, sconceY, 14, h * 0.09),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF4A2E10),
    );
    // Lamp globe
    canvas.drawCircle(
      Offset(sconceX, sconceY - h * 0.012),
      h * 0.026,
      Paint()..color = const Color(0xFFFFE890),
    );

    // ── 11. Floating dust motes in the light shaft ────────────────────────
    final rng = math.Random(42);
    final motePaint = Paint()..color = const Color(0x55FEC95A);
    for (int i = 0; i < 22; i++) {
      final mx = w * (0.40 + rng.nextDouble() * 0.50);
      final my = h * (rng.nextDouble() * 0.50);
      final mr = 0.8 + rng.nextDouble() * 2.2;
      canvas.drawCircle(Offset(mx, my), mr, motePaint);
    }

    // ── 12. Floor landing — dark rich wood ────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, stairBottom, w, h - stairBottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF3A2010), Color(0xFF1A0E08)],
        ).createShader(Rect.fromLTWH(0, stairBottom, w, h - stairBottom)),
    );
    // Floor reflected light sheen
    canvas.drawRect(
      Rect.fromLTWH(w * 0.22, stairBottom, w * 0.56, (h - stairBottom) * 0.4),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0x22FEC95A), Color(0x00FEC95A)],
        ).createShader(
          Rect.fromLTWH(w * 0.22, stairBottom, w * 0.56, (h - stairBottom) * 0.4),
        ),
    );
  }

  void _drawSpindle(Canvas canvas, double cx, double topY, double height) {
    canvas.drawLine(
      Offset(cx, topY),
      Offset(cx, topY + height),
      Paint()
        ..color = _spindle
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round,
    );
    // Inner highlight
    canvas.drawLine(
      Offset(cx, topY + height * 0.2),
      Offset(cx, topY + height * 0.65),
      Paint()
        ..color = const Color(0x226B4020)
        ..strokeWidth = 1.5,
    );
  }

  void _drawNewelPost(
    Canvas canvas,
    double cx,
    double bottomY,
    double postW,
    double totalH,
  ) {
    final postH = totalH * 0.17;
    // Post body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - postW / 2, bottomY - postH, postW, postH),
        Radius.circular(postW * 0.12),
      ),
      Paint()..color = _newelPost,
    );
    // Decorative cap (sphere-like)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, bottomY - postH - postW * 0.40),
        width: postW * 1.35,
        height: postW * 1.35,
      ),
      Paint()..color = const Color(0xFF2A1608),
    );
    // Cap highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - postW * 0.15, bottomY - postH - postW * 0.52),
        width: postW * 0.50,
        height: postW * 0.50,
      ),
      Paint()..color = const Color(0x446B4020),
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
                child: _LocationBadge(label: 'Home  ·  Staircase'),
              ),

              // ── Panel chip (top-right)
              const Positioned(
                top: 20,
                right: 20,
                child: _PanelChip(label: 'P6'),
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

