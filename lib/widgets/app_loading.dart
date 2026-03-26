import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// Full-screen loading overlay for Tales of Mende.
///
/// ```dart
/// AppLoading()                          // default spinner
/// AppLoading(message: 'Loading quest…') // with text
/// AppLoading.overlay(context)           // push over current screen
/// ```
class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.message,
    this.color = AppColors.accent,
    this.size = 50.0,
    this.backgroundColor,
  });

  final String? message;
  final Color color;
  final double size;

  /// Optional background. Defaults to semi-transparent dark overlay.
  final Color? backgroundColor;

  /// Shows an [AppLoading] as a full-screen modal barrier.
  static void overlay(BuildContext context, {String? message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.overlayDark,
      builder: (_) => AppLoading(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? AppColors.overlayDark,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitFadingCircle(color: color, size: size),
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A small inline spinner — useful inside buttons or list items.
class AppSpinner extends StatelessWidget {
  const AppSpinner({
    super.key,
    this.size = 24.0,
    this.color = AppColors.accent,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(color: color, size: size);
  }
}
