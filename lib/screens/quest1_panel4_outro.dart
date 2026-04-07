import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/app_assets.dart';
import '../widgets/story_dialogue_box.dart';
import 'quest1_stage_complete_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SCRIPT — Quest 1 · Outro
// ════════════════════════════════════════════════════════════════════════════

enum _EntryType { narrative, innerThought, dialogue, endScene }

class _ScriptEntry {
  const _ScriptEntry(this.type, this.text, {this.speaker});
  final _EntryType type;
  final String text;
  final String? speaker;
}

const List<_ScriptEntry> _script = [
  _ScriptEntry(
    _EntryType.dialogue,
    '"Well done! You\'re quite an expert at this already."',
    speaker: 'MR. MENDELEEV',
  ),
  _ScriptEntry(_EntryType.narrative, 'You shrugged.'),
  _ScriptEntry(
    _EntryType.dialogue,
    '"It was still quite a lot to learn."',
    speaker: 'PLAYER',
  ),
  _ScriptEntry(
    _EntryType.dialogue,
    '"Still, you handled yourself well."',
    speaker: 'MR. MENDELEEV',
  ),
  _ScriptEntry(_EntryType.dialogue, '"Thank you."', speaker: 'PLAYER'),
  _ScriptEntry(
    _EntryType.dialogue,
    '"Well, that will be all for now. It is still your first day, after all. Go ahead and take a rest."',
    speaker: 'MR. MENDELEEV',
  ),
  _ScriptEntry(
    _EntryType.narrative,
    'You nodded, muttering another thank you, and grabbed your bag. You gave Mr. Mendeleev a small wave before stepping out of the room with a quiet sigh of relief.',
  ),
  _ScriptEntry(_EntryType.endScene, ''),
];

// ════════════════════════════════════════════════════════════════════════════
//  QUEST 1 · OUTRO
// ════════════════════════════════════════════════════════════════════════════

class Quest1Panel4Outro extends StatefulWidget {
  const Quest1Panel4Outro({super.key});

  @override
  State<Quest1Panel4Outro> createState() => _Quest1Panel4OutroState();
}

class _Quest1Panel4OutroState extends State<Quest1Panel4Outro>
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

  void _processBeat() {
    if (_beatIndex >= _script.length) return;
    switch (_current.type) {
      case _EntryType.endScene:
        _triggerEndScene();
      case _EntryType.narrative:
      case _EntryType.innerThought:
      case _EntryType.dialogue:
        _startTypewriter(_current.text);
    }
  }

  void _startTypewriter(String text) {
    final ms = math.min(text.length * 28, 3200);
    _typeCtrl.duration = Duration(milliseconds: ms);
    _typeAnim = IntTween(
      begin: 0,
      end: text.length,
    ).animate(CurvedAnimation(parent: _typeCtrl, curve: Curves.linear));
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
          pageBuilder: (_, __, ___) => const Quest1StageCompleteScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 700),
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
              // ── Lab background (same location as game)
              Image.asset(
                AppAssets.quest1ChemLab,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFD8D8D4), Color(0xFFB0B0AC)],
                    ),
                  ),
                ),
              ),

              // ── Dark overlay
              IgnorePointer(child: Container(color: const Color(0x22000820))),

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
                height: h * 0.52,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0xF2050214)],
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
                  label: 'Elixir Enterprises  ·  Laboratory',
                ),
              ),

              // ── Panel chip
              const Positioned(
                top: 20,
                right: 20,
                child: _PanelChip(label: 'Q1  ·  Outro'),
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
          final textStyle = entry.type == _EntryType.innerThought
              ? AppTextStyles.narrative.copyWith(color: AppColors.accentLight)
              : AppTextStyles.narrative;
          return StoryDialogueBox(
            speaker: entry.speaker,
            displayText: display,
            textStyle: textStyle,
            showBlink: isDone,
            blinkOpacity: _blinkCtrl.value,
            portraitMotionValue: _typeCtrl.value,
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
          const Icon(
            Icons.location_on_outlined,
            color: AppColors.accentLight,
            size: 12,
          ),
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
