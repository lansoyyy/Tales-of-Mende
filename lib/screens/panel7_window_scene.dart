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

  // Interior palette — warm Victorian morning atmosphere
  static const Color _wallTop    = Color(0xFFB8904E); // warm amber-ochre
  static const Color _wallBottom = Color(0xFF6B4818); // deep warm brown
  static const Color _wallSide   = Color(0xFF1A0C04); // deep side shadow
  static const Color _frameColor = Color(0xFFF0EAD6); // aged white frame
  static const Color _sillColor  = Color(0xFFD4B070); // warm oak sill
  static const Color _sillShadow = Color(0xFF6A5020); // sill shadow below
  static const Color _skyTop     = Color(0xFF4A6080); // deep blue zenith
  static const Color _skyMid     = Color(0xFF88A8C0); // mid-sky blue
  static const Color _skyGlow    = Color(0xFFD4804A); // warm orange horizon
  static const Color _sidewalk   = Color(0xFFAA9870); // morning pavement
  static const Color _street     = Color(0xFF706850); // darker road
  static const Color _curtainBase= Color(0xFF8B4A2A); // rich burgundy curtain
  static const Color _curtainMid = Color(0xFFBC6040); // lighter curtain fold
  static const Color _curtainDark= Color(0xFF5A2818); // deep fold shadow

  static const List<Color> _buildingColors = [
    Color(0xFF7A4830), // brick red
    Color(0xFFD8C098), // light stone
    Color(0xFF6A5A4A), // grey stone
    Color(0xFF9A7050), // warm sandstone
    Color(0xFF5A4838), // dark grey-brown
    Color(0xFFB89070), // aged terracotta
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 1. Interior wall — warm Victorian morning atmosphere ──────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [_wallTop, _wallBottom],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    // Deep side shadow wings
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w * 0.14, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_wallSide, _wallSide.withAlpha(0)],
        ).createShader(Rect.fromLTWH(0, 0, w * 0.14, h)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.86, 0, w * 0.14, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [_wallSide, _wallSide.withAlpha(0)],
        ).createShader(Rect.fromLTWH(w * 0.86, 0, w * 0.14, h)),
    );

    // ── 2. Window dimensions (elegant narrow Victorian) ──────────────────
    final winL = w * 0.30;
    final winR = w * 0.70;
    final winT = h * 0.02;
    final winB = h * 0.67;
    final winW = winR - winL;
    final winH = winB - winT;
    final frameThick = w * 0.013;

    // ── 3. Warm morning light spill onto floor ────────────────────────────
    canvas.drawPath(
      Path()
        ..moveTo(winL + frameThick, winB - frameThick)
        ..lineTo(winR - frameThick, winB - frameThick)
        ..lineTo(w * 0.88, h)
        ..lineTo(w * 0.12, h)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0x55FFC060), Color(0x00FFC060)],
        ).createShader(Rect.fromLTWH(0, winB, w, h - winB)),
    );

    // ── 4. Curtain rod above window ───────────────────────────────────────
    final rodY = winT - h * 0.022;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(winL - w * 0.06, rodY - 4, winW + w * 0.12, 9),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF4A3010),
    );
    // Gold finials at rod ends
    for (final x in [winL - w * 0.07, winR + w * 0.07]) {
      canvas.drawCircle(Offset(x, rodY), 7, Paint()..color = const Color(0xFFD4A853));
    }

    // ── 5. Window frame drop shadow ───────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(winL - 4, winT - 4, winR + 4, winB + 4),
        const Radius.circular(6),
      ),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 14),
    );

    // ── 6. Window outer frame ─────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(winL, winT, winR, winB),
        const Radius.circular(4),
      ),
      Paint()..color = _frameColor,
    );

    // ── 7. Glass area — clipped outdoor morning scene ─────────────────────
    final glassL = winL + frameThick;
    final glassR = winR - frameThick;
    final glassT = winT + frameThick;
    final glassB = winB - frameThick / 2;
    final glassW = glassR - glassL;
    final glassH = glassB - glassT;

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(glassL, glassT, glassR, glassB),
        const Radius.circular(2),
      ),
    );

    // Sky — golden morning 3-stop gradient
    canvas.drawRect(
      Rect.fromLTWH(glassL, glassT, glassW, glassH * 0.58),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [_skyTop, _skyMid, _skyGlow],
          stops: const [0.0, 0.50, 1.0],
        ).createShader(Rect.fromLTWH(glassL, glassT, glassW, glassH * 0.58)),
    );

    // Sunrise haze / sun glow bloom
    final sunX = glassL + glassW * 0.62;
    final sunY = glassT + glassH * 0.42;
    canvas.drawCircle(
      Offset(sunX, sunY),
      glassW * 0.38,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0x88FFD060), Color(0x44FFA030), Color(0x00FF8020)],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(
          Rect.fromCircle(center: Offset(sunX, sunY), radius: glassW * 0.38),
        ),
    );

    // ── Victorian cityscape ───────────────────────────────────────────────
    final horizY     = glassT + glassH * 0.44;
    final streetTopY = glassT + glassH * 0.78;

    const buildings = [
      (0.00, 0.19, 0.95),
      (0.20, 0.15, 0.70),
      (0.36, 0.22, 0.88),
      (0.59, 0.18, 0.62),
      (0.78, 0.22, 0.80),
    ];

    for (int i = 0; i < buildings.length; i++) {
      final (xf, wf, hf) = buildings[i];
      final bx    = glassL + glassW * xf;
      final bw    = glassW * wf;
      final bh    = (streetTopY - horizY) * hf;
      final bTop  = streetTopY - bh;
      final bColor = _buildingColors[i % _buildingColors.length];

      // Building body with top-to-bottom gradient
      canvas.drawRect(
        Rect.fromLTWH(bx, bTop, bw, bh),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bColor, Color.lerp(bColor, const Color(0xFF1A1010), 0.35)!],
          ).createShader(Rect.fromLTWH(bx, bTop, bw, bh)),
      );

      // Cornice ledge at top
      canvas.drawRect(
        Rect.fromLTWH(bx - 2, bTop, bw + 4, bh * 0.055),
        Paint()..color = Color.lerp(bColor, Colors.white, 0.15)!,
      );

      // Window grid (3 rows × 2 cols)
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 2; col++) {
          final wx = bx + bw * (0.14 + col * 0.43);
          final wy = bTop + bh * (0.11 + row * 0.25);
          final ww = bw * 0.26;
          final wh = bh * 0.16;
          // Window dark base
          canvas.drawRect(
            Rect.fromLTWH(wx, wy, ww, wh),
            Paint()..color = const Color(0xFF443322),
          );
          // Warm golden glow in lit windows
          if ((i + row + col) % 3 != 0) {
            canvas.drawRect(
              Rect.fromLTWH(wx + 1, wy + 1, ww - 2, wh - 2),
              Paint()..color = const Color(0xAAFFCC66),
            );
          }
          // Window frame lines
          canvas.drawRect(
            Rect.fromLTWH(wx, wy, ww, wh),
            Paint()
              ..color = const Color(0xFFC0A070)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        }
      }

      // Chimneys
      final chimneyCount = (i % 2) + 1;
      for (int c = 0; c < chimneyCount; c++) {
        final chX = bx + bw * (0.25 + c * 0.50);
        final chH = bh * 0.11;
        canvas.drawRect(
          Rect.fromLTWH(chX - 5, bTop - chH, 10, chH),
          Paint()..color = Color.lerp(bColor, Colors.black, 0.25)!,
        );
        // Chimney cap
        canvas.drawRect(
          Rect.fromLTWH(chX - 7, bTop - chH - 4, 14, 5),
          Paint()..color = const Color(0xFF4A3828),
        );
        // Smoke wisp
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(chX, bTop - chH - 16),
            width: 12,
            height: 20,
          ),
          Paint()..color = const Color(0x33A8A0A0),
        );
      }
    }

    // Ground / sidewalk
    canvas.drawRect(
      Rect.fromLTWH(glassL, streetTopY, glassW, glassH - (streetTopY - glassT)),
      Paint()..color = _sidewalk,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        glassL,
        streetTopY + (glassH - (streetTopY - glassT)) * 0.22,
        glassW,
        (glassH - (streetTopY - glassT)) * 0.55,
      ),
      Paint()..color = _street,
    );

    // Ground morning mist (fog layer)
    canvas.drawRect(
      Rect.fromLTWH(glassL, streetTopY - 10, glassW, glassH * 0.20),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0x00D8C090),
            Color(0x66D8C090),
            Color(0x00D8C090),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
          Rect.fromLTWH(glassL, streetTopY - 10, glassW, glassH * 0.20),
        ),
    );

    // People silhouettes — varied sizes and hues
    const people = [
      (0.08, 0.85), (0.16, 0.87), (0.26, 0.84), (0.37, 0.86),
      (0.49, 0.85), (0.58, 0.87), (0.68, 0.84), (0.79, 0.86),
      (0.90, 0.85), (0.13, 0.91), (0.32, 0.90), (0.55, 0.92),
      (0.74, 0.90), (0.44, 0.93),
    ];
    final rng = math.Random(7);
    const bodyColors = [
      Color(0xFF2A1A0A), Color(0xFF1A2040),
      Color(0xFF301808), Color(0xFF1A3020),
    ];
    for (int i = 0; i < people.length; i++) {
      final (px, py) = people[i];
      final personX = glassL + glassW * px;
      final personY = glassT + glassH * py;
      final personH = glassH * (0.048 + rng.nextDouble() * 0.015);
      final bodyColor = bodyColors[i % bodyColors.length];
      // Body
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(personX, personY),
          width: personH * 0.45,
          height: personH,
        ),
        Paint()..color = bodyColor,
      );
      // Head
      canvas.drawCircle(
        Offset(personX, personY - personH * 0.62),
        personH * 0.18,
        Paint()..color = bodyColor,
      );
    }

    // Glass warmth overlay
    canvas.drawRect(
      Rect.fromLTWH(glassL, glassT, glassW, glassH),
      Paint()..color = const Color(0x0BFFCC80),
    );
    // Sky brightness at top
    canvas.drawRect(
      Rect.fromLTWH(glassL, glassT, glassW, glassH * 0.14),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0x33FFFFFF), Color(0x00FFFFFF)],
        ).createShader(Rect.fromLTWH(glassL, glassT, glassW, glassH * 0.14)),
    );

    canvas.restore();

    // ── 8. Window crossbars (Victorian 6-pane: 2 rows × 3 cols) ──────────
    final barPaint = Paint()..color = _frameColor;
    final barThick = frameThick * 0.55;
    // Horizontal mid-bar
    canvas.drawRect(
      Rect.fromLTWH(winL, glassT + glassH * 0.50, winW, barThick),
      barPaint,
    );
    // Two vertical bars
    canvas.drawRect(
      Rect.fromLTWH(winL + winW * 0.335 - barThick / 2, winT, barThick, winH),
      barPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(winL + winW * 0.665 - barThick / 2, winT, barThick, winH),
      barPaint,
    );

    // ── 9. Curtains (draped, folded, burgundy) ────────────────────────────
    _drawCurtain(canvas, winL, winT, winB, winW, true);
    _drawCurtain(canvas, winR, winT, winB, winW, false);

    // ── 10. Window sill (raised oak) ──────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(winL - 10, winB, winW + 20, h * 0.042),
        const Radius.circular(3),
      ),
      Paint()..color = _sillColor,
    );
    // Sill shadow below
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(winL - 10, winB + h * 0.038, winW + 20, h * 0.010),
        const Radius.circular(2),
      ),
      Paint()..color = _sillShadow,
    );

    // ── 11. Potted plants on sill ─────────────────────────────────────────
    const plantXFracs = [0.20, 0.50, 0.80];
    for (int i = 0; i < plantXFracs.length; i++) {
      _drawPlant(canvas, winL + winW * plantXFracs[i], winB, i);
    }

    // ── 12. Ambient window light bloom on surrounding wall ────────────────
    canvas.drawRect(
      Rect.fromLTWH(winL - winW * 0.20, winT, winW * 1.40, winH),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.75,
          colors: const [Color(0x18FFD080), Color(0x00FFD080)],
        ).createShader(
          Rect.fromLTWH(winL - winW * 0.20, winT, winW * 1.40, winH),
        ),
    );

    // ── 13. Inner frame edge shadows ──────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTRB(glassL, glassT, glassR, glassT + 6),
      Paint()..color = const Color(0x33000000),
    );
    canvas.drawRect(
      Rect.fromLTRB(glassL, glassT, glassL + 6, glassB),
      Paint()..color = const Color(0x22000000),
    );
  }

  void _drawCurtain(
    Canvas canvas,
    double anchorX,
    double top,
    double bottom,
    double winW,
    bool isLeft,
  ) {
    final sign = isLeft ? 1.0 : -1.0;
    final curtainWidth = winW * 0.20;

    const foldT   = [0.0, 0.28, 0.55, 0.82, 1.0];
    const foldOff = [0.0, 0.55, 0.22, 0.68, 0.05];

    for (int fold = 0; fold < foldT.length - 1; fold++) {
      final yTop   = top + (bottom - top) * foldT[fold];
      final yBot   = top + (bottom - top) * foldT[fold + 1];
      final xEdgeT = anchorX + sign * curtainWidth * foldOff[fold];
      final xEdgeB = anchorX + sign * curtainWidth * foldOff[fold + 1];

      final foldPath = Path()
        ..moveTo(anchorX, yTop)
        ..lineTo(xEdgeT, yTop)
        ..lineTo(xEdgeB, yBot)
        ..lineTo(anchorX, yBot)
        ..close();

      canvas.drawPath(
        foldPath,
        Paint()..color = fold.isEven ? _curtainBase : _curtainMid,
      );
    }
    // Outer edge shadow seam
    canvas.drawLine(
      Offset(anchorX, top),
      Offset(anchorX, bottom),
      Paint()
        ..color = _curtainDark
        ..strokeWidth = 3,
    );
  }

  void _drawPlant(Canvas canvas, double cx, double sillY, int index) {
    const potColors = [
      Color(0xFFC06040),
      Color(0xFF8B5A30),
      Color(0xFFD4885A),
    ];
    const leafPairs = [
      [Color(0xFF3A7020), Color(0xFF4A8830)],
      [Color(0xFF285A18), Color(0xFF388028)],
      [Color(0xFF507830), Color(0xFF608840)],
    ];

    const potH = 16.0;
    const potW = 22.0;

    // Pot body (trapezoidal)
    canvas.drawPath(
      Path()
        ..moveTo(cx - potW * 0.42, sillY + 2)
        ..lineTo(cx + potW * 0.42, sillY + 2)
        ..lineTo(cx + potW * 0.38, sillY + potH)
        ..lineTo(cx - potW * 0.38, sillY + potH)
        ..close(),
      Paint()..color = potColors[index % potColors.length],
    );
    // Pot rim
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, sillY + 2), width: potW, height: 6),
      Paint()..color = const Color(0xFF7A4020),
    );
    // Foliage cluster
    final lc = leafPairs[index % leafPairs.length];
    canvas.drawCircle(Offset(cx, sillY - 12), 13, Paint()..color = lc[0]);
    canvas.drawCircle(Offset(cx - 10, sillY - 6), 9, Paint()..color = lc[1]);
    canvas.drawCircle(Offset(cx + 10, sillY - 6), 9, Paint()..color = lc[1]);
    canvas.drawCircle(Offset(cx - 4, sillY - 19), 8, Paint()..color = lc[0]);
    canvas.drawCircle(Offset(cx + 4, sillY - 19), 8, Paint()..color = lc[1]);
    // Accent flower bud
    canvas.drawCircle(
      Offset(cx + (index.isEven ? 3 : -3), sillY - 26),
      3.5,
      Paint()..color = const Color(0xFFFF8888),
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
                child: _LocationBadge(label: 'Home  ·  Living Room'),
              ),

              // ── Panel chip (top-right)
              const Positioned(
                top: 20,
                right: 20,
                child: _PanelChip(label: 'P7'),
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
