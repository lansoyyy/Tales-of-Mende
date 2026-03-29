import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/app_assets.dart';
import 'quest1_panel3_lab.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SCRIPT — Quest 1 · Panel 2
// ════════════════════════════════════════════════════════════════════════════

enum _EntryType { narrative, innerThought, sfxBeat, endScene }

class _ScriptEntry {
  const _ScriptEntry(this.type, this.text);
  final _EntryType type;
  final String text;
}

const List<_ScriptEntry> _script = [
  _ScriptEntry(
    _EntryType.narrative,
    'A moment of silence fell between the two of you. You fidget with the '
    'strap of your bag until you hear him clear his throat.',
  ),
  _ScriptEntry(_EntryType.endScene, ''),
];

// ════════════════════════════════════════════════════════════════════════════
//  GRAND HALL BACKGROUND PAINTER  (fallback if image missing)
// ════════════════════════════════════════════════════════════════════════════

class _GrandHallPainter extends CustomPainter {
  const _GrandHallPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dark base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF0E0328), Color(0xFF050110)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Warm chandelier glow from top-center
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.12),
      h * 0.45,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0x50D4A853), Color(0x00000000)],
        ).createShader(
          Rect.fromCircle(center: Offset(w * 0.5, h * 0.12), radius: h * 0.45),
        ),
    );

    // Checkered floor (bottom 30%)
    final floorY = h * 0.70;
    final tileSize = w * 0.06;
    final cols = (w / tileSize).ceil() + 1;
    final rows = ((h - floorY) / tileSize).ceil() + 1;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final isLight = (r + c) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(c * tileSize - (tileSize / 2), floorY + r * tileSize,
              tileSize, tileSize),
          Paint()
            ..color = isLight
                ? const Color(0xFF1A1030)
                : const Color(0xFF120825),
        );
      }
    }

    // Floor reflective sheen
    canvas.drawRect(
      Rect.fromLTWH(0, floorY, w, h - floorY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0x22D4A853), Color(0x00000000)],
        ).createShader(Rect.fromLTWH(0, floorY, w, h - floorY)),
    );

    // Side pillars
    final pillarPaint = Paint()..color = const Color(0xFF1C0C40);
    const pillars = [0.08, 0.22, 0.78, 0.92];
    for (final f in pillars) {
      final px = w * f;
      canvas.drawRect(
        Rect.fromLTWH(px - w * 0.018, 0, w * 0.036, h * 0.72),
        pillarPaint,
      );
      // Pillar highlight
      canvas.drawRect(
        Rect.fromLTWH(px - w * 0.018, 0, w * 0.005, h * 0.72),
        Paint()..color = const Color(0x33D4A853),
      );
      // Gold base cap
      canvas.drawRect(
        Rect.fromLTWH(
            px - w * 0.022, h * 0.68, w * 0.044, h * 0.038),
        Paint()..color = const Color(0xFF6A4818),
      );
    }

    // Windows between pillars (tall arched glow)
    const windowXFracs = [0.35, 0.65];
    for (final f in windowXFracs) {
      final wx = w * f;
      final winW = w * 0.15;
      final winH = h * 0.55;
      // Arch path
      final archPath = Path()
        ..moveTo(wx - winW / 2, h * 0.05 + winH)
        ..lineTo(wx - winW / 2, h * 0.05 + winH * 0.28)
        ..quadraticBezierTo(
            wx, h * 0.03, wx + winW / 2, h * 0.05 + winH * 0.28)
        ..lineTo(wx + winW / 2, h * 0.05 + winH)
        ..close();
      canvas.drawPath(
        archPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Color(0x60C8E8FF), Color(0x10C8E8FF)],
          ).createShader(
            Rect.fromLTWH(wx - winW / 2, h * 0.03, winW, winH),
          ),
      );
      // Window frame
      canvas.drawPath(
          archPath,
          Paint()
            ..color = const Color(0x66D4A853)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }

    // Hanging chandelier (centre)
    final cX = w * 0.50;
    canvas.drawLine(
      Offset(cX, 0),
      Offset(cX, h * 0.10),
      Paint()
        ..color = const Color(0xFF7A5828)
        ..strokeWidth = 3,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cX, h * 0.14), width: w * 0.06, height: h * 0.06),
      Paint()..color = const Color(0xFFD4A853),
    );
    // Chandelier glow
    canvas.drawCircle(
      Offset(cX, h * 0.14),
      h * 0.08,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0x80FFD880), Color(0x00000000)],
        ).createShader(
          Rect.fromCircle(
              center: Offset(cX, h * 0.14), radius: h * 0.08),
        ),
    );

    // Vignette
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: const [Color(0x00000000), Color(0xCC000000)],
          stops: const [0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ════════════════════════════════════════════════════════════════════════════
//  QUEST 1 · PANEL 2 — GRAND HALL / RECEPTION
// ════════════════════════════════════════════════════════════════════════════

class Quest1Panel2Reception extends StatefulWidget {
  const Quest1Panel2Reception({super.key});

  @override
  State<Quest1Panel2Reception> createState() => _Quest1Panel2ReceptionState();
}

class _Quest1Panel2ReceptionState extends State<Quest1Panel2Reception>
    with TickerProviderStateMixin {
  int _beatIndex = 0;
  bool _endSceneStarted = false;

  late AnimationController _fadeInCtrl;
  late Animation<double> _fadeIn;
  late AnimationController _typeCtrl;
  late Animation<int> _typeAnim;
  late AnimationController _blinkCtrl;
  late AnimationController _endFadeCtrl;
  late Animation<double> _endFade;

  _ScriptEntry get _current => _script[_beatIndex];

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

    _processBeat();
  }

  @override
  void dispose() {
    _fadeInCtrl.dispose();
    _typeCtrl.dispose();
    _blinkCtrl.dispose();
    _endFadeCtrl.dispose();
    super.dispose();
  }

  // ── Beat processing ────────────────────────────────────────────────────

  void _processBeat() {
    if (_beatIndex >= _script.length) return;
    switch (_current.type) {
      case _EntryType.endScene:
        _triggerEndScene();
      case _EntryType.narrative:
      case _EntryType.innerThought:
      case _EntryType.sfxBeat:
        _startTypewriter(_current.text);
    }
  }

  void _startTypewriter(String text) {
    final ms = math.min(text.length * 28, 3200);
    _typeCtrl.duration = Duration(milliseconds: ms);
    _typeAnim = IntTween(begin: 0, end: text.length)
        .animate(CurvedAnimation(parent: _typeCtrl, curve: Curves.linear));
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
          pageBuilder: (_, __, ___) => const Quest1Panel3Lab(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
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
              // ── Background: try JPEG assets, fall back to painter
              Image.asset(
                AppAssets.quest1ReceptionHall,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => Image.asset(
                  AppAssets.quest1ReceptionHall2,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (__, ___, ____) => const CustomPaint(
                    painter: _GrandHallPainter(),
                    child: SizedBox.expand(),
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

              // ── Bottom readability gradient
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: h * 0.55,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0xF0050214)],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Location badge
              const Positioned(
                top: 20,
                left: 20,
                child: _LocationBadge(
                    label: 'Elixir Enterprises  ·  Grand Hall'),
              ),

              // ── Panel chip
              const Positioned(
                top: 20,
                right: 20,
                child: _PanelChip(label: 'Q1 · P2'),
              ),

              // ── VN text box
              if (!_endSceneStarted) _buildTextBox(),

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
    final entry = _current;
    if (entry.type == _EntryType.endScene) return const SizedBox.shrink();
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedBuilder(
        animation: Listenable.merge([_typeCtrl, _blinkCtrl]),
        builder: (_, __) {
          final chars = _typeAnim.value;
          final full = entry.text;
          final display = full.substring(0, chars.clamp(0, full.length));
          final isDone = !_typeCtrl.isAnimating && _typeCtrl.value >= 1.0;
          return _VnTextBox(
            entryType: entry.type,
            displayText: display,
            showBlink: isDone,
            blinkOpacity: _blinkCtrl.value,
          );
        },
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
    required this.entryType,
    required this.displayText,
    required this.showBlink,
    required this.blinkOpacity,
  });

  final _EntryType entryType;
  final String displayText;
  final bool showBlink;
  final double blinkOpacity;

  @override
  Widget build(BuildContext context) {
    final textStyle = entryType == _EntryType.innerThought
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
