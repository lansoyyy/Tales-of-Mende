import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/app_assets.dart';
import 'quest1_panel2_reception.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SCRIPT — Quest 1 · Panel 1
// ════════════════════════════════════════════════════════════════════════════

enum _EntryType { narrative, innerThought, sfxBeat, endScene }

class _ScriptEntry {
  const _ScriptEntry(this.type, this.text);
  final _EntryType type;
  final String text;
}

const List<_ScriptEntry> _script = [
  _ScriptEntry(_EntryType.sfxBeat, '[Footsteps SFX]'),
  _ScriptEntry(_EntryType.innerThought, '"Well, this is it."'),
  _ScriptEntry(_EntryType.narrative, 'You gripped your bag tighter.'),
  _ScriptEntry(_EntryType.narrative, '"Ah, you must be the intern," a voice called from behind you.'),
  _ScriptEntry(_EntryType.endScene, ''),
];

// ════════════════════════════════════════════════════════════════════════════
//  QUEST 1 · PANEL 1 — HALLWAY
// ════════════════════════════════════════════════════════════════════════════

class Quest1Panel1Hallway extends StatefulWidget {
  const Quest1Panel1Hallway({super.key});

  @override
  State<Quest1Panel1Hallway> createState() => _Quest1Panel1HallwayState();
}

class _Quest1Panel1HallwayState extends State<Quest1Panel1Hallway>
    with TickerProviderStateMixin {
  bool _showQuestCard = true;
  int _beatIndex = 0;
  bool _endSceneStarted = false;

  // Quest intro card
  late AnimationController _questCardCtrl;
  late Animation<double> _questCardFade;

  // Scene fade-in
  late AnimationController _sceneFadeCtrl;
  late Animation<double> _sceneFade;

  // Typewriter
  late AnimationController _typeCtrl;
  late Animation<int> _typeAnim;

  // Cursor blink
  late AnimationController _blinkCtrl;

  // SFX chip
  late AnimationController _sfxCtrl;
  late Animation<double> _sfxAnim;
  String _sfxLabel = '';
  bool _sfxVisible = false;

  // End scene fade-to-black
  late AnimationController _endFadeCtrl;
  late Animation<double> _endFade;

  _ScriptEntry get _current => _script[_beatIndex];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _questCardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _questCardFade =
        CurvedAnimation(parent: _questCardCtrl, curve: Curves.easeInOut);

    _sceneFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _sceneFade =
        CurvedAnimation(parent: _sceneFadeCtrl, curve: Curves.easeIn);

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

    _endFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _endFade = CurvedAnimation(parent: _endFadeCtrl, curve: Curves.easeIn);

    // Quest card sequence: fade in → hold 2.2 s → fade out → reveal scene
    _questCardCtrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 2200), () {
        if (!mounted) return;
        _questCardCtrl.reverse().then((_) {
          if (!mounted) return;
          setState(() => _showQuestCard = false);
          _sceneFadeCtrl.forward();
          _processBeat();
        });
      });
    });
  }

  @override
  void dispose() {
    _questCardCtrl.dispose();
    _sceneFadeCtrl.dispose();
    _typeCtrl.dispose();
    _blinkCtrl.dispose();
    _sfxCtrl.dispose();
    _endFadeCtrl.dispose();
    super.dispose();
  }

  // ── Beat processing ────────────────────────────────────────────────────

  void _processBeat() {
    if (_beatIndex >= _script.length) return;
    switch (_current.type) {
      case _EntryType.sfxBeat:
        _showSfxChip(_current.text);
      case _EntryType.endScene:
        _triggerEndScene();
      case _EntryType.innerThought:
      case _EntryType.narrative:
        _startTypewriter(_current.text);
    }
  }

  void _startTypewriter(String text) {
    final ms = math.min(text.length * 32, 2800);
    _typeCtrl.duration = Duration(milliseconds: ms);
    _typeAnim = IntTween(begin: 0, end: text.length)
        .animate(CurvedAnimation(parent: _typeCtrl, curve: Curves.linear));
    _typeCtrl
      ..reset()
      ..forward();
  }

  void _onTap() {
    if (_showQuestCard || _endSceneStarted) return;
    if (_current.type == _EntryType.sfxBeat) return;
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

  void _triggerEndScene() {
    setState(() => _endSceneStarted = true);
    _endFadeCtrl.forward().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const Quest1Panel2Reception(),
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Scene (fades in after quest card leaves)
            if (!_showQuestCard)
              FadeTransition(
                opacity: _sceneFade,
                child: _buildScene(context),
              ),

            // ── Quest title card overlay (shown first)
            if (_showQuestCard)
              FadeTransition(
                opacity: _questCardFade,
                child: const _QuestTitleCard(
                  questLabel: 'QUEST 1',
                  questTitle: 'The Genius Society',
                ),
              ),

            // ── End fade-to-black (on top of everything)
            IgnorePointer(
              child: FadeTransition(
                opacity: _endFade,
                child: Container(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScene(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Hallway background image
        Image.asset(
          AppAssets.quest1HallwayBg,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF080520), Color(0xFF030110)],
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

        // ── Location badge (top-left)
        const Positioned(
          top: 20,
          left: 20,
          child: _LocationBadge(label: 'Elixir Enterprises  ·  Hallway'),
        ),

        // ── Panel chip (top-right)
        const Positioned(
          top: 20,
          right: 20,
          child: _PanelChip(label: 'Q1 · P1'),
        ),

        // ── SFX chip (centre-top)
        if (_sfxVisible)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _sfxAnim,
              child: Center(child: _SfxChip(label: _sfxLabel)),
            ),
          ),

        // ── VN text box
        if (!_endSceneStarted) _buildTextBox(),
      ],
    );
  }

  Widget _buildTextBox() {
    final entry = _current;
    if (entry.type == _EntryType.sfxBeat ||
        entry.type == _EntryType.endScene) {
      return const SizedBox.shrink();
    }
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
//  QUEST TITLE CARD
// ════════════════════════════════════════════════════════════════════════════

class _QuestTitleCard extends StatelessWidget {
  const _QuestTitleCard({
    required this.questLabel,
    required this.questTitle,
  });
  final String questLabel;
  final String questTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top decorative divider
            _GoldDivider(),
            const SizedBox(height: 22),

            // ── "QUEST 1"
            Text(
              questLabel,
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.accent,
                fontSize: 40,
                letterSpacing: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),

            // ── Bottom decorative divider
            _GoldDivider(),
            const SizedBox(height: 18),

            // ── Quest subtitle
            Text(
              questTitle,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
                letterSpacing: 2.5,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _thin(80),
        const SizedBox(width: 10),
        _diamond(),
        const SizedBox(width: 10),
        _thin(80),
      ],
    );
  }

  Widget _thin(double w) => Container(
        width: w,
        height: 1,
        color: AppColors.accentDark,
      );

  Widget _diamond() => Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: AppColors.accent,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withAlpha(120),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      );
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
