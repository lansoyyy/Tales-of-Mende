import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import 'panel8_letter_scene.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SCRIPT — Panel 7
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
  _ScriptEntry(_EntryType.sfxBeat, '[People Ambience SFX]'),
  _ScriptEntry(
    _EntryType.narrative,
    'Taking a sip of your coffee, you gaze at the window to see the streets '
    'bustling again for another productive day. Your train of thought was '
    'quickly interrupted by a loud, enthusiastic knock on the door.',
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
//  WINDOW / BUSY-STREET BACKGROUND PAINTER
// ════════════════════════════════════════════════════════════════════════════

class _WindowStreetPainter extends CustomPainter {
  const _WindowStreetPainter();

  static const Color _wallTop = Color(0xFFF0E6D0);
  static const Color _wallBottom = Color(0xFFE0D0B0);
  static const Color _wallSide = Color(0xFFD8C8A0);
  static const Color _frameColor = Color(0xFFF2F0E8);
  static const Color _frameShadow = Color(0xFF9A8870);
  static const Color _sillColor = Color(0xFFD4B483);
  static const Color _skyTop = Color(0xFF87CEEA);
  static const Color _skyBottom = Color(0xFFD4ECF7);
  static const Color _hillA = Color(0xFF7BA05B);
  static const Color _hillB = Color(0xFF567A3C);
  static const Color _sidewalkColor = Color(0xFFCCCABE);
  static const Color _streetColor = Color(0xFFB0ADA0);
  static const Color _curtainColor = Color(0xFFD4A86C);

  static const List<Color> _buildingColors = [
    Color(0xFFC07050),
    Color(0xFFF0E0C0),
    Color(0xFFD07030),
    Color(0xFFF5F0E0),
    Color(0xFFBB8060),
  ];

  static const List<Color> _peopleColors = [
    Color(0xFF883322),
    Color(0xFF224488),
    Color(0xFF338833),
    Color(0xFF884488),
    Color(0xFF885533),
    Color(0xFF334488),
    Color(0xFF883344),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 1. Wall background ─────────────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [_wallTop, _wallBottom],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Side shadows
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w * 0.10, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_wallSide, _wallSide.withAlpha(0)],
        ).createShader(Rect.fromLTWH(0, 0, w * 0.10, h)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.90, 0, w * 0.10, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [_wallSide, _wallSide.withAlpha(0)],
        ).createShader(Rect.fromLTWH(w * 0.90, 0, w * 0.10, h)),
    );

    // ── 2. Window dimensions ───────────────────────────────────────────────
    final winL = w * 0.06;
    final winR = w * 0.94;
    final winT = h * 0.03;
    final winB = h * 0.62;
    final winW = winR - winL;
    final winH = winB - winT;
    final frameThick = w * 0.018;

    // ── 3. Window outer shadow ──────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(winL - 2, winT - 2, winR + 2, winB + 2),
        const Radius.circular(4),
      ),
      Paint()..color = _frameShadow,
    );

    // ── 4. Window frame ────────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(winL, winT, winR, winB),
        const Radius.circular(4),
      ),
      Paint()..color = _frameColor,
    );

    // ── 5. Glass area with outdoor scene (clipped) ─────────────────────────
    final glassL = winL + frameThick;
    final glassR = winR - frameThick;
    final glassT = winT + frameThick;
    final glassB = winB - frameThick;
    final glassW = glassR - glassL;
    final glassH = glassB - glassT;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(glassL, glassT, glassW, glassH));

    // Sky gradient
    canvas.drawRect(
      Rect.fromLTWH(glassL, glassT, glassW, glassH * 0.48),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [_skyTop, _skyBottom],
        ).createShader(Rect.fromLTWH(glassL, glassT, glassW, glassH * 0.48)),
    );

    // Hills at horizon
    final horizonY = glassT + glassH * 0.40;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(glassL + glassW * 0.25, horizonY + 18),
        width: glassW * 0.60,
        height: 70,
      ),
      Paint()..color = _hillA,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(glassL + glassW * 0.65, horizonY + 8),
        width: glassW * 0.55,
        height: 62,
      ),
      Paint()..color = _hillB,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(glassL + glassW * 0.92, horizonY + 22),
        width: glassW * 0.44,
        height: 55,
      ),
      Paint()..color = _hillA,
    );

    // Buildings
    final buildingBaseY = glassT + glassH * 0.70;
    final streetTopY = glassT + glassH * 0.82;
    const buildings = [
      (0.00, 0.19, 0.78), // (xFrac, widthFrac, heightFrac)
      (0.20, 0.17, 0.92),
      (0.38, 0.23, 0.66),
      (0.62, 0.21, 0.86),
      (0.84, 0.16, 0.72),
    ];

    for (int i = 0; i < buildings.length; i++) {
      final (xf, wf, hf) = buildings[i];
      final bx = glassL + glassW * xf;
      final bw = glassW * wf;
      final bh = (streetTopY - buildingBaseY) * hf;
      final bTop = streetTopY - bh;

      canvas.drawRect(
        Rect.fromLTWH(bx, bTop, bw, bh),
        Paint()..color = _buildingColors[i % _buildingColors.length],
      );

      // Windows grid (2 cols × 3 rows)
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 2; col++) {
          canvas.drawRect(
            Rect.fromLTWH(
              bx + bw * 0.15 + col * (bw * 0.40),
              bTop + bh * 0.12 + row * (bh * 0.24),
              bw * 0.28,
              bh * 0.14,
            ),
            Paint()..color = const Color(0x804488AA),
          );
        }
      }

      // Awning
      canvas.drawRect(
        Rect.fromLTWH(
          bx + bw * 0.04,
          streetTopY - bh * 0.12,
          bw * 0.92,
          bh * 0.08,
        ),
        Paint()..color = _buildingColors[(i + 2) % _buildingColors.length],
      );
    }

    // Sidewalk
    canvas.drawRect(
      Rect.fromLTWH(glassL, streetTopY, glassW, glassH - (streetTopY - glassT)),
      Paint()..color = _sidewalkColor,
    );
    // Road strip
    canvas.drawRect(
      Rect.fromLTWH(
        glassL,
        streetTopY + (glassB - streetTopY) * 0.28,
        glassW,
        (glassB - streetTopY) * 0.50,
      ),
      Paint()..color = _streetColor,
    );

    // People silhouettes
    const people = [
      (0.07, 0.86), (0.16, 0.88), (0.27, 0.85), (0.38, 0.87),
      (0.50, 0.86), (0.60, 0.88), (0.71, 0.85), (0.81, 0.87),
      (0.91, 0.86), (0.13, 0.92), (0.33, 0.91), (0.59, 0.92),
      (0.76, 0.90), (0.45, 0.93), (0.22, 0.89), (0.64, 0.90),
    ];
    for (int i = 0; i < people.length; i++) {
      final (px, py) = people[i];
      final personX = glassL + glassW * px;
      final personY = glassT + glassH * py;
      final personH = glassH * 0.055;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(personX, personY),
          width: personH * 0.52,
          height: personH,
        ),
        Paint()..color = _peopleColors[i % _peopleColors.length],
      );
    }

    // Sky brightness at top of glass
    canvas.drawRect(
      Rect.fromLTWH(glassL, glassT, glassW, glassH * 0.18),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0x44FFFFFF), Color(0x00FFFFFF)],
        ).createShader(Rect.fromLTWH(glassL, glassT, glassW, glassH * 0.18)),
    );

    // Glass tint overlay (subtle blue reflection)
    canvas.drawRect(
      Rect.fromLTWH(glassL, glassT, glassW, glassH),
      Paint()..color = const Color(0x0A87CEEA),
    );

    canvas.restore();

    // ── 6. Curtains ────────────────────────────────────────────────────────
    final curtainPaint = Paint()..color = _curtainColor;
    final leftCurtainPath = Path()
      ..moveTo(winL - 2, winT)
      ..lineTo(winL + winW * 0.13, winT)
      ..lineTo(winL + winW * 0.09, winT + winH * 0.42)
      ..lineTo(winL + winW * 0.15, winT + winH * 0.72)
      ..lineTo(winL, winB)
      ..lineTo(winL - 2, winB)
      ..close();
    canvas.drawPath(leftCurtainPath, curtainPaint);

    final rightCurtainPath = Path()
      ..moveTo(winR + 2, winT)
      ..lineTo(winR - winW * 0.13, winT)
      ..lineTo(winR - winW * 0.09, winT + winH * 0.42)
      ..lineTo(winR - winW * 0.15, winT + winH * 0.72)
      ..lineTo(winR, winB)
      ..lineTo(winR + 2, winB)
      ..close();
    canvas.drawPath(rightCurtainPath, curtainPaint);

    // Curtain fold shadow
    canvas.drawPath(
      leftCurtainPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [Color(0x44000000), Color(0x00000000)],
        ).createShader(Rect.fromLTWH(winL, winT, winW * 0.15, winH)),
    );

    // ── 7. Window crossbars ───────────────────────────────────────────────
    final barPaint = Paint()..color = _frameColor;
    // Horizontal divider
    canvas.drawRect(
      Rect.fromLTWH(winL, glassT + glassH * 0.55, winW, frameThick * 0.8),
      barPaint,
    );
    // Vertical divider
    canvas.drawRect(
      Rect.fromLTWH(winL + winW * 0.50 - frameThick * 0.4, winT, frameThick * 0.8, winH),
      barPaint,
    );

    // ── 8. Window sill ────────────────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(winL - 4, winB, winW + 8, h * 0.045),
      Paint()..color = _sillColor,
    );

    // ── 9. Potted plants on sill ──────────────────────────────────────────
    const plantXFracs = [0.18, 0.40, 0.62, 0.83];
    const plantColors = [
      Color(0xFF4A7A2E),
      Color(0xFF5A8C3E),
      Color(0xFF3A6A20),
    ];
    for (int i = 0; i < plantXFracs.length; i++) {
      final px = winL + winW * plantXFracs[i];
      final py = winB;
      // Pot
      canvas.drawOval(
        Rect.fromCenter(center: Offset(px, py + h * 0.026), width: 24, height: 15),
        Paint()..color = const Color(0xFF996644),
      );
      // Foliage
      canvas.drawCircle(Offset(px, py), 17, Paint()..color = plantColors[0]);
      canvas.drawCircle(
        Offset(px - 11, py + 5),
        12,
        Paint()..color = plantColors[1],
      );
      canvas.drawCircle(
        Offset(px + 11, py + 5),
        12,
        Paint()..color = plantColors[2],
      );
      // Flower accent
      canvas.drawCircle(
        Offset(px - 3, py - 11),
        4,
        Paint()..color = const Color(0xFFFF6688),
      );
    }

    // ── 10. Ambient light bloom from window ───────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(winL, winT, winW, winH),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.80,
          colors: const [Color(0x22FFFFFF), Color(0x00FFFFFF)],
        ).createShader(Rect.fromLTWH(winL, winT, winW, winH)),
    );

    // ── 11. Inner frame edge shadow ───────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTRB(glassL, glassT, glassR, glassT + 5),
      Paint()..color = const Color(0x22000000),
    );
    canvas.drawRect(
      Rect.fromLTRB(glassL, glassT, glassL + 5, glassB),
      Paint()..color = const Color(0x22000000),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ════════════════════════════════════════════════════════════════════════════
//  PANEL 7 — WINDOW / STREET SCENE
// ════════════════════════════════════════════════════════════════════════════

class Panel7WindowScene extends StatefulWidget {
  const Panel7WindowScene({super.key});

  @override
  State<Panel7WindowScene> createState() => _Panel7WindowSceneState();
}

class _Panel7WindowSceneState extends State<Panel7WindowScene>
    with TickerProviderStateMixin {
  int _beatIndex = 0;
  bool _showingLetter = false;
  bool _endSceneStarted = false;

  late AnimationController _typeCtrl;
  late Animation<int> _typeAnim;
  late AnimationController _blinkCtrl;
  late AnimationController _fadeInCtrl;
  late Animation<double> _fadeIn;
  late AnimationController _sfxCtrl;
  late Animation<double> _sfxAnim;
  String _sfxLabel = '';
  bool _sfxVisible = false;
  late AnimationController _flashCtrl;
  late Animation<double> _flashAnim;
  late AnimationController _endFadeCtrl;
  late Animation<double> _endFade;

  _ScriptEntry get _currentEntry => _script[_beatIndex];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _fadeInCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
      duration: const Duration(milliseconds: 1000),
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

  // ── Beat processing ─────────────────────────────────────────────────────

  void _processBeat() {
    if (_beatIndex >= _script.length) return;
    final entry = _currentEntry;

    switch (entry.type) {
      case _EntryType.sfxBeat:
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
    if (entry.type == _EntryType.sfxBeat || entry.type == _EntryType.popUpFx) {
      return;
    }
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
          pageBuilder: (_, __, ___) => const Panel8LetterScene(),
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
              // ── Window/street background
              CustomPaint(
                painter: const _WindowStreetPainter(),
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

              // ── Fade-to-black for scene transition
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
//  LETTER OVERLAY — parchment card
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
                          border: Border.all(
                            color: const Color(0xFFCC4444),
                            width: 2,
                          ),
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
