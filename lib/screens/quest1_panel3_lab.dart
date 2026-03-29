import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/app_assets.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SCRIPT — Quest 1 · Panel 3
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
    'After your brief tour, Mr. Graham led you to the laboratory.',
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
  late AnimationController _endFadeCtrl;
  late Animation<double> _endFade;
  late AnimationController _endBannerCtrl;
  late Animation<double> _endBanner;

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

    _endBannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _endBanner =
        CurvedAnimation(parent: _endBannerCtrl, curve: Curves.easeOut);

    _processBeat();
  }

  @override
  void dispose() {
    _fadeInCtrl.dispose();
    _typeCtrl.dispose();
    _blinkCtrl.dispose();
    _endFadeCtrl.dispose();
    _endBannerCtrl.dispose();
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
    final ms = math.min(text.length * 32, 3200);
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
      _endBannerCtrl.forward().then((_) {
        // Quest 1 intro complete — navigate to the quest gameplay.
        // TODO: replace Navigator.pop() with the Quest 1 gameplay screen
        // once it is implemented.
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (!mounted) return;
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
      });
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

              // ── VN text box
              if (!_endSceneStarted) _buildTextBox(),

              // ── End fade-to-black
              IgnorePointer(
                child: FadeTransition(
                  opacity: _endFade,
                  child: Container(color: Colors.black),
                ),
              ),

              // ── End-of-scene banner
              IgnorePointer(
                child: FadeTransition(
                  opacity: _endBanner,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _GoldDivider(),
                        const SizedBox(height: 14),
                        Text(
                          'Quest 1  ·  Chapter Begin',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.accentLight,
                            letterSpacing: 3,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _GoldDivider(),
                      ],
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
//  GOLD DIVIDER
// ════════════════════════════════════════════════════════════════════════════

class _GoldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _thin(70),
        const SizedBox(width: 10),
        Transform.rotate(
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
        ),
        const SizedBox(width: 10),
        _thin(70),
      ],
    );
  }

  Widget _thin(double w) => Container(
        width: w,
        height: 1,
        color: AppColors.accentDark,
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
