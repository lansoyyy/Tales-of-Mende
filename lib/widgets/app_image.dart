import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// A thin wrapper around [Image.asset] that provides:
/// - Consistent error placeholder for missing assets
/// - Optional fit / alignment defaults suitable for game panels
///
/// Usage:
/// ```dart
/// AppImage(AppAssets.splashBackground, fit: BoxFit.cover)
/// AppImage.panel(AppAssets.homeBackground)  // fills its parent
/// ```
class AppImage extends StatelessWidget {
  const AppImage(
    this.assetPath, {
    super.key,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.color,
    this.colorBlendMode,
    this.semanticLabel,
  });

  final String assetPath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final AlignmentGeometry alignment;
  final Color? color;
  final BlendMode? colorBlendMode;
  final String? semanticLabel;

  /// Fills the available space — ideal for full-screen panel backgrounds.
  factory AppImage.panel(
    String assetPath, {
    Key? key,
    AlignmentGeometry alignment = Alignment.center,
    Color? color,
    BlendMode? colorBlendMode,
    String? semanticLabel,
  }) =>
      AppImage(
        assetPath,
        key: key,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        alignment: alignment,
        color: color,
        colorBlendMode: colorBlendMode,
        semanticLabel: semanticLabel,
      );

  /// Preserves aspect ratio and fills width.
  factory AppImage.fullWidth(
    String assetPath, {
    Key? key,
    double? height,
    String? semanticLabel,
  }) =>
      AppImage(
        assetPath,
        key: key,
        fit: BoxFit.fitWidth,
        width: double.infinity,
        height: height,
        semanticLabel: semanticLabel,
      );

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      semanticLabel: semanticLabel,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: AppColors.surfaceVariant,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.textDisabled,
          ),
        );
      },
    );
  }
}
