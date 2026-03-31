import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/app_assets.dart';
import 'quest1_game_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SCRIPT — Quest 1 · Panel 3
// ════════════════════════════════════════════════════════════════════════════

enum _EntryType { narrative, innerThought, dialogue, sfxBeat, popUpFx, endScene }

class _ScriptEntry {
  const _ScriptEntry(this.type, this.text, {this.speaker});
  final _EntryType type;
  final String text;
  final String? speaker;
}

const List<_ScriptEntry> _script = [
  _ScriptEntry(_EntryType.sfxBeat, '[Door Creak SFX]'),
  _ScriptEntry(
    _EntryType.innerThought,
    '"Wow," you thought to yourself. "It\'s even bigger than I imagined."',
  ),
  _ScriptEntry(
    _EntryType.dialogue,
    '"And this is where you will spend the majority of your time."',
    speaker: 'MR. GRAHAM',
  ),
  _ScriptEntry(
    _EntryType.narrative,
    'You took in the bright lights and gleaming equipment, your eyes wide with awe.',
  ),
  _ScriptEntry(_EntryType.popUpFx, ''),
  _ScriptEntry(
    _EntryType.dialogue,
    '"I\'ll take it from here, Mr. Graham!"',
    speaker: 'MR. MENDELEEV',
  ),
  _ScriptEntry(
    _EntryType.narrative,
    'You shifted your attention to the source of the new voice. A tall, bright-eyed man stepped forward with an easy smile. Mr. Graham gave a quiet nod.',
  ),
  _ScriptEntry(
    _EntryType.dialogue,
    '"Hi, my name is Dmitri Mendeleev. Welcome to the laboratory."',
    speaker: 'MR. MENDELEEV',
  ),
  _ScriptEntry(
    _EntryType.narrative,
    'He extended his hand toward you. You shook it, feeling a surge of excitement.',
  ),
  _ScriptEntry(
    _EntryType.innerThought,
    'This was it. It was really happening!',
  ),
  _ScriptEntry(
    _EntryType.dialogue,
    '"It is a pleasure to work with you, sir!"',
    speaker: 'PLAYER',
  ),
  _ScriptEntry(
    _EntryType.narrative,
    'The two of you shared a polite smile.',
  ),
  _ScriptEntry(
    _EntryType.dialogue,
    '"See to it our intern settles in well, Mendeleev."',
    speaker: 'MR. GRAHAM',
  ),
  _ScriptEntry(
    _EntryType.dialogue,
    '"Of course, sir."',
    speaker: 'MR. MENDELEEV',
  ),
  _ScriptEntry(
    _EntryType.dialogue,
    '"Very well. I must get going. Carry on."',
    speaker: 'MR. GRAHAM',
  ),
  _ScriptEntry(
    _EntryType.narrative,
    'You watched as he turned on his heel and walked out, his footsteps firm and unhurried.',
  ),
  _ScriptEntry(
    _EntryType.dialogue,
    '"Don\'t be intimidated by him. Mr. Graham is always like that."',
    speaker: 'MR. MENDELEEV',
  ),
  _ScriptEntry(_EntryType.narrative, 'You turned your attention back to Mr. Mendeleev.'),
  _ScriptEntry(
    _EntryType.dialogue,
    '"Come, I\'ll show you around."',
    speaker: 'MR. MENDELEEV',
  ),
  _ScriptEntry(
    _EntryType.narrative,
    'You settled in fairly quickly, no thanks to Mr. Mendeleev\'s warm hospitality. Before long, he gestured to a neatly arranged stack of cards on the counter.',
  ),
  _ScriptEntry(
    _EntryType.dialogue,
    '"What\'s this?"',
    speaker: 'PLAYER',
  ),
  _ScriptEntry(_EntryType.narrative, 'Mr. Mendeleev chuckled softly.'),
  _ScriptEntry(
    _EntryType.dialogue,
    '"I know you must already be familiar with the elements of the periodic table. But let\'s see just how well you really know them."',
    speaker: 'MR. MENDELEEV',
  ),
  _ScriptEntry(_EntryType.endScene, ''),
];

// ════════════════════════════════════════════════════════════════════════════
//  QUEST 1 · PANEL 3 — LABORATORY
// ════════════════════════════════════════════════════════════════════════════

class Quest1Panel3Lab extends StatefulWidget {
  const Quest1Panel3Lab({super.key});

  @override
  State<Quest1Panel3Lab> createState() => _Quest1Panel3LabState();
}

class _Quest1Panel3LabState extends State<Quest1Panel3Lab>
    with TickerProviderStateMixin {
  int _beatIndex = 0;
  bool _endSceneStarted = false;

  late AnimationController _fadeInCtrl;
  late Animation<double> _fadeIn;
  late AnimationController _typeCtrl;
  late Animation<int> _typeAnim;
  late AnimationController _blinkCtrl;

  late AnimationController _sfxCtrl;
  late Animation<double> _sfxAnim;
  String _sfxLabel = '';
  bool _sfxVisible = false;

  late AnimationController _flashCtrl;
  late Animation<double> _flashAnim;

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
    _fadeInCtrl.dispose();
    _typeCtrl.dispose();
    _blinkCtrl.dispose();
    _sfxCtrl.dispose();
    _flashCtrl.dispose();
    _endFadeCtrl.dispose();
    super.dispose();
  }

  void _processBeat() {
    if (_beatIndex >= _script.length) return;
    switch (_current.type) {
      case _EntryType.sfxBeat:
        _showSfxChip(_current.text);
      case _EntryType.popUpFx:
        _triggerWhiteFlash();
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
    _typeAnim = IntTween(begin: 0, end: text.length)
        .animate(CurvedAnimation(parent: _typeCtrl, curve: Curves.linear));
    _typeCtrl
      ..reset()
      ..forward();
  }

  void _onTap() {
    if (_endSceneStarted) return;
    final t = _current.type;
    if (t == _EntryType.sfxBeat || t == _EntryType.popUpFx) return;
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

  void _triggerEndScene() {
    setState(() => _endSceneStarted = true);
    _endFadeCtrl.forward().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const Quest1GameScreen(),
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
              // ── Lab background image
              Image.asset(
                AppAssets.quest1ChemLab,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFEEEEEA), Color(0xFFCCCCC8)],
                    ),
                  ),
                ),
              ),

              // ── Cool desaturating overlay (makes lab feel clinical)
              IgnorePointer(
                child: Container(
                  color: const Color(0x18000820),
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
                    label: 'Elixir Enterprises  ·  Laboratory'),
              ),

              // ── Panel chip
              const Positioned(
                top: 20,
                right: 20,
                child: _PanelChip(label: 'Q1 · P3'),
              ),

              // ── SFX chip
              if (_sfxVisible)
                Positioned(
                  top: 56,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FadeTransition(
                      opacity: _sfxAnim,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xCC0A0718),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.accent.withAlpha(100)),
                        ),
                        child: Text(
                          _sfxLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accentLight,
                            fontSize: 11,
                            letterSpacing: 1.2,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ── VN text box
              if (!_endSceneStarted) _buildTextBox(),

              // ── White flash (popUpFx)
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
    final entry = _current;
    if (entry.type == _EntryType.endScene) return const SizedBox.shrink();
    if (entry.type == _EntryType.popUpFx) return const SizedBox.shrink();
    if (entry.type == _EntryType.sfxBeat && _sfxVisible) return const SizedBox.shrink();
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
            speaker: entry.speaker,
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
    this.speaker,
  });

  final _EntryType entryType;
  final String displayText;
  final bool showBlink;
  final double blinkOpacity;
  final String? speaker;

  @override
  Widget build(BuildContext context) {
    final isDialogue = entryType == _EntryType.dialogue;
    final textStyle = entryType == _EntryType.innerThought
        ? AppTextStyles.narrative.copyWith(color: AppColors.accentLight)
        : AppTextStyles.narrative;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xD40A0718),
        border: Border(top: BorderSide(color: AppColors.accent, width: 1.5)),
      ),
      padding: EdgeInsets.fromLTRB(20, isDialogue && speaker != null ? 10 : 14, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDialogue && speaker != null) ...[            Text(
              speaker!,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.accent,
                fontSize: 10,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Row(
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
        ],
      ),
    );
  }
}
