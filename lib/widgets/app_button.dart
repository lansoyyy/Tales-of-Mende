import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';

/// Variants for the game button.
enum AppButtonVariant { primary, secondary, outline, ghost, danger }

/// A styled game button for Tales of Mende.
///
/// ```dart
/// AppButton(
///   label: 'Start Quest',
///   onPressed: () {},
/// )
/// AppButton.outline(
///   label: 'Cancel',
///   onPressed: () {},
/// )
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = AppConstants.buttonHeightMd,
    this.borderRadius = AppConstants.radiusMd,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  // ── Named constructors ───────────────────────────────────────────────────

  factory AppButton.outline({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isLoading = false,
    bool isFullWidth = true,
  }) => AppButton(
    key: key,
    label: label,
    onPressed: onPressed,
    variant: AppButtonVariant.outline,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    isLoading: isLoading,
    isFullWidth: isFullWidth,
  );

  factory AppButton.ghost({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    Widget? prefixIcon,
    bool isFullWidth = false,
  }) => AppButton(
    key: key,
    label: label,
    onPressed: onPressed,
    variant: AppButtonVariant.ghost,
    prefixIcon: prefixIcon,
    isFullWidth: isFullWidth,
  );

  factory AppButton.danger({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isFullWidth = true,
  }) => AppButton(
    key: key,
    label: label,
    onPressed: onPressed,
    variant: AppButtonVariant.danger,
    isFullWidth: isFullWidth,
  );

  // ── Helpers ──────────────────────────────────────────────────────────────

  Color _backgroundColor() {
    return switch (variant) {
      AppButtonVariant.primary => AppColors.accent,
      AppButtonVariant.secondary => AppColors.secondary,
      AppButtonVariant.outline => AppColors.transparent,
      AppButtonVariant.ghost => AppColors.transparent,
      AppButtonVariant.danger => AppColors.dangerRed,
    };
  }

  Color _foregroundColor() {
    return switch (variant) {
      AppButtonVariant.primary => AppColors.textOnAccent,
      AppButtonVariant.secondary => AppColors.textOnDark,
      AppButtonVariant.outline => AppColors.accent,
      AppButtonVariant.ghost => AppColors.accent,
      AppButtonVariant.danger => AppColors.textOnDark,
    };
  }

  BorderSide _borderSide() {
    return switch (variant) {
      AppButtonVariant.outline => const BorderSide(
        color: AppColors.accent,
        width: 2,
      ),
      AppButtonVariant.danger => const BorderSide(color: AppColors.dangerRed),
      _ => BorderSide.none,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;

    Widget child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _foregroundColor(),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcon != null) ...[
                prefixIcon!,
                const SizedBox(width: AppConstants.spacingSm),
              ],
              Text(
                label,
                style: AppTextStyles.buttonText.copyWith(
                  color: _foregroundColor(),
                ),
              ),
              if (suffixIcon != null) ...[
                const SizedBox(width: AppConstants.spacingSm),
                suffixIcon!,
              ],
            ],
          );

    final button = SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled
              ? AppColors.textDisabled
              : _backgroundColor(),
          foregroundColor: _foregroundColor(),
          elevation: variant == AppButtonVariant.ghost
              ? 0
              : AppConstants.elevationMd,
          padding:
              padding ??
              const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLg,
                vertical: AppConstants.spacingSm,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: _borderSide(),
          ),
        ),
        child: child,
      ),
    );

    return button;
  }
}
