import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/app_assets.dart';

class StoryDialogueBox extends StatelessWidget {
  const StoryDialogueBox({
    super.key,
    required this.displayText,
    required this.textStyle,
    required this.showBlink,
    required this.blinkOpacity,
    this.speaker,
    this.portraitMotionValue = 1.0,
  });

  final String displayText;
  final TextStyle textStyle;
  final bool showBlink;
  final double blinkOpacity;
  final String? speaker;
  final double portraitMotionValue;

  bool get _showMendeleevPortrait {
    final normalizedSpeaker = speaker?.trim().toUpperCase();
    return normalizedSpeaker != null && normalizedSpeaker.contains('MENDELEEV');
  }

  String get _portraitAsset {
    if (!_showMendeleevPortrait) {
      return AppAssets.mendeleevPortraitIdle;
    }

    final isTalking = portraitMotionValue > 0 && portraitMotionValue < 0.98;
    if (!isTalking) {
      return AppAssets.mendeleevPortraitIdle;
    }

    final frameIndex =
        (portraitMotionValue * 10).floor() %
        AppAssets.mendeleevPortraitTalkFrames.length;
    return AppAssets.mendeleevPortraitTalkFrames[frameIndex];
  }

  @override
  Widget build(BuildContext context) {
    final hasSpeaker = speaker != null && speaker!.isNotEmpty;
    final leftPadding = _showMendeleevPortrait ? 132.0 : 20.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xD40A0718),
            border: Border(
              top: BorderSide(color: AppColors.accent, width: 1.5),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            leftPadding,
            hasSpeaker ? 10 : 14,
            20,
            20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasSpeaker) ...[
                Text(
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
        ),
        if (_showMendeleevPortrait)
          Positioned(
            left: 8,
            bottom: 0,
            child: IgnorePointer(
              child: Transform.translate(
                offset: const Offset(0, 8),
                child: SizedBox(
                  width: 118,
                  height: 154,
                  child: Image.asset(
                    _portraitAsset,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomLeft,
                    filterQuality: FilterQuality.none,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
