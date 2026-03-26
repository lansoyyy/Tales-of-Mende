import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import 'app_button.dart';
import 'app_text.dart';

/// A styled game dialog for Tales of Mende with a dark-fantasy design.
///
/// ```dart
/// AppDialog.show(
///   context,
///   title: 'Quest Complete!',
///   message: 'You have collected all the potions.',
///   primaryLabel: 'Continue',
///   onPrimary: () => Navigator.pop(context),
/// );
/// ```
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.icon,
    this.isDismissible = true,
  });

  final String title;
  final String? message;

  /// Custom content shown below the message (overrides [message]).
  final Widget? content;

  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Widget? icon;
  final bool isDismissible;

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    String? primaryLabel,
    VoidCallback? onPrimary,
    String? secondaryLabel,
    VoidCallback? onSecondary,
    Widget? icon,
    bool isDismissible = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: isDismissible,
      barrierColor: AppColors.overlayDark,
      builder: (_) => AppDialog(
        title: title,
        message: message,
        content: content,
        primaryLabel: primaryLabel,
        onPrimary: onPrimary,
        secondaryLabel: secondaryLabel,
        onSecondary: onSecondary,
        icon: icon,
        isDismissible: isDismissible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        side: const BorderSide(color: AppColors.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(height: AppConstants.spacingMd),
            ],
            AppText.bodyLarge(title, textAlign: TextAlign.center),
            if (message != null || content != null) ...[
              const SizedBox(height: AppConstants.spacingMd),
              content ??
                  AppText.bodyMedium(
                    message!,
                    textAlign: TextAlign.center,
                    color: AppColors.textSecondary,
                  ),
            ],
            const SizedBox(height: AppConstants.spacingLg),
            if (primaryLabel != null)
              AppButton(label: primaryLabel!, onPressed: onPrimary),
            if (secondaryLabel != null) ...[
              const SizedBox(height: AppConstants.spacingSm),
              AppButton.ghost(label: secondaryLabel!, onPressed: onSecondary),
            ],
          ],
        ),
      ),
    );
  }
}

/// A confirmation dialog with a pre-wired Cancel + Confirm layout.
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDanger = false,
  });

  final String title;
  final String message;
  final VoidCallback onConfirm;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDanger;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDanger = false,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: AppColors.overlayDark,
      builder: (_) => AppConfirmDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDanger: isDanger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        side: const BorderSide(color: AppColors.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText.bodyLarge(title, textAlign: TextAlign.center),
            const SizedBox(height: AppConstants.spacingMd),
            AppText.bodyMedium(
              message,
              textAlign: TextAlign.center,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            isDanger
                ? AppButton.danger(
                    label: confirmLabel,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                  )
                : AppButton(
                    label: confirmLabel,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                  ),
            const SizedBox(height: AppConstants.spacingSm),
            AppButton.ghost(
              label: cancelLabel,
              onPressed: () => Navigator.of(context).pop(),
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
