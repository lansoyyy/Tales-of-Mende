import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// A convenience text widget that always uses the Urbanist font via [AppTextStyles].
///
/// Instead of writing:
/// ```dart
/// Text('Hello', style: AppTextStyles.bodyMedium)
/// ```
/// you can write:
/// ```dart
/// AppText.bodyMedium('Hello')
/// ```
class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    required this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.color,
  });

  final String data;
  final TextStyle style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;

  /// Override just the color without creating a new style manually.
  final Color? color;

  // ── Named constructors for each semantic style ──────────────────────────

  factory AppText.displayLarge(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.displayLarge,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.displayMedium(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.displayMedium,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.displaySmall(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.displaySmall,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.headlineLarge(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.headlineLarge,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.headlineMedium(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.headlineMedium,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.headlineSmall(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.headlineSmall,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.titleLarge(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.titleLarge,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.titleMedium(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.titleMedium,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.titleSmall(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.titleSmall,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.bodyLarge(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.bodyLarge,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.bodyMedium(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.bodyMedium,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.bodySmall(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.bodySmall,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.labelLarge(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.labelLarge,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.labelMedium(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.labelMedium,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.labelSmall(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.labelSmall,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  // ── Game-specific ────────────────────────────────────────────────────────

  factory AppText.questTitle(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.questTitle,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.questDescription(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.questDescription,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.buttonText(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.buttonText,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.score(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.scoreText,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  factory AppText.narrative(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
  }) => AppText(
    data,
    key: key,
    style: AppTextStyles.narrative,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    color: color,
  );

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = color != null ? style.copyWith(color: color) : style;
    return Text(
      data,
      style: resolvedStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
    );
  }
}

/// A rich-text variant that wraps [RichText] but still defaults to Urbanist.
class AppRichText extends StatelessWidget {
  const AppRichText({
    super.key,
    required this.children,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
  });

  final List<InlineSpan> children;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      text: TextSpan(style: AppTextStyles.bodyMedium, children: children),
    );
  }

  /// Helper to create a [TextSpan] pre-styled with [AppTextStyles].
  static TextSpan span(
    String text, {
    TextStyle style = AppTextStyles.bodyMedium,
    Color? color,
  }) {
    return TextSpan(
      text: text,
      style: color != null ? style.copyWith(color: color) : style,
    );
  }

  /// Bold/gold span for highlighting keywords.
  static TextSpan highlight(String text) =>
      span(text, style: AppTextStyles.labelLarge, color: AppColors.questGold);
}
