import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/app_assets.dart';
import '../widgets/story_dialogue_box.dart';
import 'quest1_panel4_outro.dart';

// ════════════════════════════════════════════════════════════════════════════
//  ELEMENT PAIRS
// ════════════════════════════════════════════════════════════════════════════

const _trialPairs = [
  ('Mg', 'Magnesium'),
  ('Fe', 'Iron'),
  ('Au', 'Gold'),
  ('Na', 'Sodium'),
];

const _round1Pairs = [
  ('H', 'Hydrogen'),
  ('O', 'Oxygen'),
  ('C', 'Carbon'),
  ('N', 'Nitrogen'),
  ('K', 'Potassium'),
];

const _round2Pairs = [
  ('He', 'Helium'),
  ('Li', 'Lithium'),
  ('Ca', 'Calcium'),
  ('Cu', 'Copper'),
  ('Cl', 'Chlorine'),
  ('Al', 'Aluminium'),
];

const _round3Pairs = [
  ('Be', 'Beryllium'),
  ('B', 'Boron'),
  ('F', 'Fluorine'),
  ('P', 'Phosphorus'),
  ('S', 'Sulfur'),
  ('Pb', 'Lead'),
  ('Hg', 'Mercury'),
  ('Zn', 'Zinc'),
];

// ════════════════════════════════════════════════════════════════════════════
//  DIALOGUE LINES
// ════════════════════════════════════════════════════════════════════════════

class _Line {
  const _Line(this.speaker, this.text);
  final String speaker;
  final String text;
}

const _tutorialLines = [
  _Line(
    'MR. MENDELEEV',
    "Let's proceed to your first task. Pay close attention to the rules.",
  ),
  _Line(
    'MR. MENDELEEV',
    'This task will test your memory, but the cards are all periodic table elements.',
  ),
  _Line(
    'MR. MENDELEEV',
    'Important: match each chemical symbol with its correct element name.',
  ),
  _Line('MR. MENDELEEV', 'You may flip only two cards at a time.'),
  _Line('MR. MENDELEEV', 'If the pair is correct, both cards stay revealed.'),
  _Line(
    'MR. MENDELEEV',
    'If the pair is wrong, both cards flip back and you try again.',
  ),
  _Line(
    'MR. MENDELEEV',
    "For example, 'Mg' matches 'Magnesium'. Some symbols look nothing like the names they represent, so stay sharp.",
  ),
];

const _trialIntroLines = [
  _Line(
    'MR. MENDELEEV',
    "Before the real game begins, let's do a quick practice round.",
  ),
  _Line('MR. MENDELEEV', 'No pressure here. Ready to practice?'),
];

const _trialAfterLines = [
  _Line('MR. MENDELEEV', "That's the idea."),
  _Line('MR. MENDELEEV', "Simple enough, right?"),
  _Line('MR. MENDELEEV', "Now… let's see how well you really remember."),
];

const _preRoundLines = [
  _Line('MR. MENDELEEV', "The real game starts now."),
  _Line(
    'MR. MENDELEEV',
    'Remember: match the symbol to the full element name.',
  ),
  _Line('MR. MENDELEEV', "Good luck!"),
];

// ════════════════════════════════════════════════════════════════════════════
//  GAME PHASE
// ════════════════════════════════════════════════════════════════════════════

enum _Phase {
  tutorial,
  trialIntro,
  trial,
  trialDone,
  preRound,
  playing,
  roundDone,
  gameDone,
}

// ════════════════════════════════════════════════════════════════════════════
//  CARD DATA
// ════════════════════════════════════════════════════════════════════════════

class _Card {
  _Card({
    required this.id,
    required this.pairKey,
    required this.text,
    required this.isSymbol,
  });
  final String id;
  final String pairKey;
  final String text;
  final bool isSymbol;
  bool matched = false;
}

// ════════════════════════════════════════════════════════════════════════════
//  QUEST 1 GAME SCREEN
// ════════════════════════════════════════════════════════════════════════════

class Quest1GameScreen extends StatefulWidget {
  const Quest1GameScreen({super.key});

  @override
  State<Quest1GameScreen> createState() => _Quest1GameScreenState();
}

class _Quest1GameScreenState extends State<Quest1GameScreen>
    with TickerProviderStateMixin {
  // ── Phase ──────────────────────────────────────────────────────────────
  _Phase _phase = _Phase.tutorial;
  int _lineIndex = 0;
  int _currentRound = 0; // 0 = trial, 1–3 = rounds

  // ── Board state ────────────────────────────────────────────────────────
  List<_Card> _board = [];
  String? _firstFlipped;
  bool _lockBoard = false;
  int _matchedPairs = 0;
  int _totalPairs = 0;

  // ── Trial guidance step (0–3) ──────────────────────────────────────────
  int _trialStep = 0;

  // ── Card flip controllers ───────────────────────────────────────────────
  final Map<String, AnimationController> _flipCtrls = {};

  // ── Dialogue typewriter ─────────────────────────────────────────────────
  late AnimationController _typeCtrl;
  late Animation<int> _typeAnim;
  late AnimationController _blinkCtrl;
  String _speaker = '';
  String _dialogue = '';
  bool _dialogueDone = false;

  // ── Fade in ─────────────────────────────────────────────────────────────
  late AnimationController _fadeInCtrl;
  late Animation<double> _fadeIn;

  // ── Round-complete banner ───────────────────────────────────────────────
  bool _showRoundBanner = false;
  String _roundBannerText = '';

  // ── Feedback flash ──────────────────────────────────────────────────────
  bool _showFeedback = false;
  String _feedbackText = '';
  bool _feedbackCorrect = false;

  // ── End-game fade ───────────────────────────────────────────────────────
  late AnimationController _endFadeCtrl;
  late Animation<double> _endFade;

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
      duration: const Duration(milliseconds: 1300),
    );
    _endFade = CurvedAnimation(parent: _endFadeCtrl, curve: Curves.easeIn);

    _showLine(_tutorialLines[0]);
  }

  @override
  void dispose() {
    for (final c in _flipCtrls.values) {
      c.dispose();
    }
    _typeCtrl.dispose();
    _blinkCtrl.dispose();
    _fadeInCtrl.dispose();
    _endFadeCtrl.dispose();
    super.dispose();
  }

  // ── Dialogue ───────────────────────────────────────────────────────────

  void _showLine(_Line line) {
    setState(() {
      _speaker = line.speaker;
      _dialogue = line.text;
      _dialogueDone = false;
    });
    final ms = math.min(line.text.length * 26, 3200);
    _typeCtrl.duration = Duration(milliseconds: ms);
    _typeAnim = IntTween(
      begin: 0,
      end: line.text.length,
    ).animate(CurvedAnimation(parent: _typeCtrl, curve: Curves.linear));
    _typeCtrl
      ..reset()
      ..forward().then((_) {
        if (mounted) setState(() => _dialogueDone = true);
      });
  }

  void _onTap() {
    if (_typeCtrl.isAnimating) {
      _typeCtrl.value = 1.0;
      return;
    }
    _advance();
  }

  void _advance() {
    switch (_phase) {
      case _Phase.tutorial:
        _lineIndex++;
        if (_lineIndex < _tutorialLines.length) {
          _showLine(_tutorialLines[_lineIndex]);
        } else {
          _lineIndex = 0;
          setState(() => _phase = _Phase.trialIntro);
          _showLine(_trialIntroLines[0]);
        }
      case _Phase.trialIntro:
        _lineIndex++;
        if (_lineIndex < _trialIntroLines.length) {
          _showLine(_trialIntroLines[_lineIndex]);
        } else {
          _beginTrial();
        }
      case _Phase.trialDone:
        _lineIndex++;
        if (_lineIndex < _trialAfterLines.length) {
          _showLine(_trialAfterLines[_lineIndex]);
        } else {
          _lineIndex = 0;
          setState(() => _phase = _Phase.preRound);
          _showLine(_preRoundLines[0]);
        }
      case _Phase.preRound:
        _lineIndex++;
        if (_lineIndex < _preRoundLines.length) {
          _showLine(_preRoundLines[_lineIndex]);
        } else {
          _startRound(1);
        }
      default:
        break;
    }
  }

  // ── Trial ──────────────────────────────────────────────────────────────

  void _beginTrial() {
    setState(() {
      _phase = _Phase.trial;
      _trialStep = 0;
      _currentRound = 0;
    });
    _setupBoard(_trialPairs.toList());
    _showLine(const _Line('MR. MENDELEEV', 'Go ahead. Pick your first card.'));
  }

  // ── Board ──────────────────────────────────────────────────────────────

  void _setupBoard(List<(String, String)> pairs) {
    for (final c in _flipCtrls.values) {
      c.dispose();
    }
    _flipCtrls.clear();

    final cards = <_Card>[];
    for (int i = 0; i < pairs.length; i++) {
      final (sym, name) = pairs[i];
      final key = 'p$i';
      cards.add(_Card(id: '${key}_s', pairKey: key, text: sym, isSymbol: true));
      cards.add(
        _Card(id: '${key}_n', pairKey: key, text: name, isSymbol: false),
      );
    }
    cards.shuffle(math.Random());

    for (final card in cards) {
      _flipCtrls[card.id] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 380),
      );
    }

    setState(() {
      _board = cards;
      _firstFlipped = null;
      _lockBoard = false;
      _matchedPairs = 0;
      _totalPairs = pairs.length;
      _showFeedback = false;
      _dialogue = '';
    });
  }

  // ── Card tap ────────────────────────────────────────────────────────────

  void _onCardTap(_Card card) {
    if (_lockBoard) return;
    if (card.matched) return;
    final ctrl = _flipCtrls[card.id]!;
    if (ctrl.value > 0.4) return; // already face-up
    if (_firstFlipped == card.id) return; // same card tapped twice

    ctrl.forward();

    if (_firstFlipped == null) {
      setState(() => _firstFlipped = card.id);
      // Trial: step 0 → 1 hint
      if (_phase == _Phase.trial && _trialStep == 0) {
        setState(() => _trialStep = 1);
        Future.delayed(const Duration(milliseconds: 420), () {
          if (mounted) {
            _showLine(const _Line('MR. MENDELEEV', 'Good. Now pick another.'));
          }
        });
      }
    } else {
      setState(() => _lockBoard = true);
      final first = _board.firstWhere((c) => c.id == _firstFlipped!);
      Future.delayed(const Duration(milliseconds: 460), () {
        if (!mounted) return;
        _checkMatch(first, card);
      });
    }
  }

  void _checkMatch(_Card a, _Card b) {
    final matched = a.pairKey == b.pairKey;

    // Trial guided feedback
    if (_phase == _Phase.trial && _trialStep == 1) {
      setState(() => _trialStep = 2);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        if (matched) {
          _showLine(const _Line('MR. MENDELEEV', "That's a match. Well done."));
        } else {
          _showLine(
            const _Line(
              'MR. MENDELEEV',
              "Not quite. Remember where you saw it.",
            ),
          );
        }
      });
    }

    if (matched) {
      setState(() {
        a.matched = true;
        b.matched = true;
        _firstFlipped = null;
        _lockBoard = false;
        _matchedPairs++;
      });
      _flashFeedback(true);

      if (_phase == _Phase.trial && _trialStep == 2) {
        Future.delayed(const Duration(milliseconds: 2200), () {
          if (mounted)
            setState(() {
              _trialStep = 3;
              _dialogue = '';
            });
        });
      }
      if (_matchedPairs == _totalPairs) _onBoardComplete();
    } else {
      _flashFeedback(false);
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        _flipCtrls[a.id]!.reverse();
        _flipCtrls[b.id]!.reverse();
        if (_phase == _Phase.trial && _trialStep == 2) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted)
              setState(() {
                _trialStep = 3;
                _dialogue = '';
              });
          });
        }
        setState(() {
          _firstFlipped = null;
          _lockBoard = false;
        });
      });
    }
  }

  void _flashFeedback(bool correct) {
    setState(() {
      _showFeedback = true;
      _feedbackText = correct ? 'Match!' : 'Not a match';
      _feedbackCorrect = correct;
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _showFeedback = false);
    });
  }

  void _onBoardComplete() {
    if (_phase == _Phase.trial) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _phase = _Phase.trialDone;
          _lineIndex = 0;
        });
        _showLine(_trialAfterLines[0]);
      });
    } else if (_phase == _Phase.playing) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        if (_currentRound < 3) {
          _showRoundComplete();
        } else {
          _triggerGameDone();
        }
      });
    }
  }

  void _startRound(int round) {
    setState(() {
      _phase = _Phase.playing;
      _currentRound = round;
    });
    final pairs = switch (round) {
      1 => _round1Pairs.toList(),
      2 => _round2Pairs.toList(),
      3 => _round3Pairs.toList(),
      _ => _round1Pairs.toList(),
    };
    _setupBoard(pairs);
  }

  void _showRoundComplete() {
    setState(() {
      _phase = _Phase.roundDone;
      _showRoundBanner = true;
      _roundBannerText = 'Round $_currentRound  ·  Complete';
    });
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (!mounted) return;
      setState(() => _showRoundBanner = false);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        _startRound(_currentRound + 1);
      });
    });
  }

  void _triggerGameDone() {
    setState(() => _phase = _Phase.gameDone);
    _endFadeCtrl.forward().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const Quest1Panel4Outro(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────

  bool get _isDialoguePhase =>
      _phase == _Phase.tutorial ||
      _phase == _Phase.trialIntro ||
      _phase == _Phase.trialDone ||
      _phase == _Phase.preRound;

  bool get _isGamePhase =>
      _phase == _Phase.trial ||
      _phase == _Phase.playing ||
      _phase == _Phase.roundDone;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _isDialoguePhase ? _onTap : null,
        child: FadeTransition(
          opacity: _fadeIn,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Lab background
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
              IgnorePointer(
                child: Container(
                  color: _isGamePhase
                      ? const Color(0x44000820)
                      : const Color(0x22000820),
                ),
              ),

              // ── Edge vignette
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.3,
                      colors: const [Colors.transparent, Color(0xBB000000)],
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),

              // ── Bottom gradient
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: size.height * (_isGamePhase ? 0.38 : 0.52),
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

              // ── Round / phase chip
              Positioned(
                top: 20,
                right: 20,
                child: _RoundChip(phase: _phase, round: _currentRound),
              ),

              // ── Card board (game phases only)
              if (_isGamePhase) _buildBoard(size),

              // ── Feedback banner
              if (_showFeedback) _buildFeedbackBanner(),

              // ── Round-complete overlay
              if (_showRoundBanner) _buildRoundBanner(),

              // ── VN dialogue / commentary box
              if (_phase == _Phase.tutorial ||
                  _phase == _Phase.trialIntro ||
                  _phase == _Phase.preRound)
                _buildInstructionCallout(size),
              _buildDialogueArea(size),

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

  // ── Card board ──────────────────────────────────────────────────────────

  Widget _buildBoard(Size size) {
    final cols = switch (_currentRound) {
      0 => 4,
      1 => 5,
      2 => 6,
      3 => 8,
      _ => 4,
    };

    const topOffset = 68.0;
    const vnBoxH = 120.0;
    final availW = size.width - 48.0;
    final availH = size.height - vnBoxH - topOffset - 12.0;
    const gap = 8.0;
    final rows = (_board.length / cols).ceil();

    final cardW = math.min(90.0, (availW - gap * (cols - 1)) / cols);
    final cardH = math.min(112.0, (availH - gap * (rows - 1)) / rows);
    final gridW = cols * cardW + gap * (cols - 1);
    final gridH = rows * cardH + gap * (rows - 1);

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      height: size.height - vnBoxH - topOffset,
      child: Center(
        child: SizedBox(
          width: gridW,
          height: gridH,
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: _board
                .map(
                  (card) => SizedBox(
                    width: cardW,
                    height: cardH,
                    child: _buildCard(card),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(_Card card) {
    final ctrl = _flipCtrls[card.id]!;
    final canTap =
        (_phase == _Phase.trial || _phase == _Phase.playing) &&
        !_lockBoard &&
        !card.matched;
    return GestureDetector(
      onTap: canTap ? () => _onCardTap(card) : null,
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) {
          final v = ctrl.value;
          final showFront = v >= 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(v * math.pi),
            child: showFront
                ? Transform.scale(scaleX: -1, child: _buildCardFront(card))
                : _buildCardBack(),
          );
        },
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E0A3C), Color(0xFF0D051E)],
        ),
        border: Border.all(color: AppColors.accent.withAlpha(150), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.accent.withAlpha(180),
              width: 1,
            ),
          ),
          child: const Center(
            child: Text(
              '?',
              style: TextStyle(
                color: AppColors.accentLight,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(_Card card) {
    final isMatched = card.matched;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isMatched
              ? const [Color(0xFF0D2212), Color(0xFF081408)]
              : const [Color(0xFF1A1030), Color(0xFF0A0820)],
        ),
        border: Border.all(
          color: isMatched
              ? const Color(0xFF40C060)
              : AppColors.accentLight.withAlpha(200),
          width: isMatched ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isMatched
                ? const Color(0x4440C060)
                : AppColors.accent.withAlpha(55),
            blurRadius: isMatched ? 10 : 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: card.isSymbol
                  ? AppColors.accent.withAlpha(30)
                  : Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              card.isSymbol ? 'SYMBOL' : 'ELEMENT',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: card.isSymbol
                    ? AppColors.accentLight
                    : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            card.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: card.isSymbol ? 18 : 11,
              fontWeight: card.isSymbol ? FontWeight.w700 : FontWeight.w500,
              color: card.isSymbol ? AppColors.accent : AppColors.textPrimary,
              letterSpacing: card.isSymbol ? 1.5 : 0.3,
              height: 1.2,
            ),
          ),
          if (isMatched) ...[
            const SizedBox(height: 4),
            const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF50D070),
              size: 12,
            ),
          ],
        ],
      ),
    );
  }

  // ── Feedback banner ─────────────────────────────────────────────────────

  Widget _buildFeedbackBanner() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 64),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: _feedbackCorrect
                ? const Color(0xDD0C2010)
                : const Color(0xDD200A0A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _feedbackCorrect
                  ? const Color(0xFF40C060)
                  : const Color(0xFFC04040),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _feedbackCorrect ? Icons.check_circle_outline : Icons.close,
                color: _feedbackCorrect
                    ? const Color(0xFF50D070)
                    : const Color(0xFFD05050),
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                _feedbackText,
                style: AppTextStyles.labelSmall.copyWith(
                  color: _feedbackCorrect
                      ? const Color(0xFF70F090)
                      : const Color(0xFFF07070),
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Round-complete overlay ────────────────────────────────────────────

  Widget _buildRoundBanner() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: const Color(0xAA000000),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.accent,
                  size: 44,
                ),
                const SizedBox(height: 14),
                Text(
                  _roundBannerText,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.accent,
                    letterSpacing: 3,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_matchedPairs pairs matched',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Dialogue / commentary box ─────────────────────────────────────────

  Widget _buildDialogueArea(Size size) {
    // During active game with no commentary: show match counter
    if (_isGamePhase && _dialogue.isEmpty && _phase != _Phase.roundDone) {
      if (_phase == _Phase.playing) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xBB060318),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withAlpha(60)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'IMPORTANT: MATCH SYMBOL + ELEMENT NAME',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accent,
                      fontSize: 9,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_matchedPairs / $_totalPairs  matched',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      if (_phase == _Phase.trial) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xBB060318),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withAlpha(60)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PRACTICE: FIND THE MATCHING PAIR',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accent,
                      fontSize: 9,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Flip 2 cards. Match symbol to full element name.',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    if (_dialogue.isEmpty) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedBuilder(
        animation: Listenable.merge([_typeCtrl, _blinkCtrl]),
        builder: (_, __) {
          final len = _typeAnim.value.clamp(0, _dialogue.length);
          final display = _dialogue.substring(0, len);
          return StoryDialogueBox(
            speaker: _speaker.isEmpty ? null : _speaker,
            displayText: display,
            textStyle: AppTextStyles.narrative,
            showBlink: _dialogueDone && _isDialoguePhase,
            blinkOpacity: _blinkCtrl.value,
            portraitMotionValue: _typeCtrl.value,
          );
        },
      ),
    );
  }

  Widget _buildInstructionCallout(Size size) {
    final width = math.min(size.width * 0.34, 320.0).toDouble();

    return Positioned(
      right: 20,
      bottom: 126,
      child: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: const Color(0xD9150D27),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.accent.withAlpha(120)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(25),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.accent.withAlpha(80)),
                  ),
                  child: Text(
                    'IMPORTANT',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 48,
                  height: 64,
                  child: Image.asset(
                    AppAssets.mendeleevPortraitInstruction,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _InstructionLine(
              label: 'GOAL',
              text: 'Match each symbol with its full element name.',
            ),
            const SizedBox(height: 6),
            _InstructionLine(
              label: 'TURN',
              text: 'Flip only 2 cards at a time.',
            ),
            const SizedBox(height: 6),
            _InstructionLine(
              label: 'MATCH',
              text: 'Correct pairs stay revealed.',
            ),
            const SizedBox(height: 6),
            _InstructionLine(label: 'MISS', text: 'Wrong pairs flip back.'),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  ROUND CHIP
// ════════════════════════════════════════════════════════════════════════════

class _RoundChip extends StatelessWidget {
  const _RoundChip({required this.phase, required this.round});
  final _Phase phase;
  final int round;

  @override
  Widget build(BuildContext context) {
    final String label;
    if (phase == _Phase.playing || phase == _Phase.roundDone) {
      label = 'Round $round / 3';
    } else if (phase == _Phase.trial ||
        phase == _Phase.trialIntro ||
        phase == _Phase.trialDone) {
      label = 'Q1  ·  Trial';
    } else {
      label = 'Q1  ·  Tutorial';
    }
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
//  VN TEXT BOX
// ════════════════════════════════════════════════════════════════════════════

class _InstructionLine extends StatelessWidget {
  const _InstructionLine({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label  ',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          TextSpan(
            text: text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
