import 'package:flutter/material.dart';

/// Centralized color palette for Tales of Mende.
/// Inspired by a dark-fantasy aesthetic: deep purples, mystic gold, forest green.
class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A0A2E); // Deep midnight purple
  static const Color primaryLight = Color(0xFF2D1B4E);
  static const Color primaryDark = Color(0xFF0D0518);

  // ── Accent / Gold ────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFD4A853); // Mystic gold
  static const Color accentLight = Color(0xFFE8C47A);
  static const Color accentDark = Color(0xFFB8892E);

  // ── Secondary / Forest ───────────────────────────────────────────────────
  static const Color secondary = Color(0xFF2A6B3C); // Forest green
  static const Color secondaryLight = Color(0xFF3D8F52);
  static const Color secondaryDark = Color(0xFF1A4526);

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0F0520); // Dark mystic void
  static const Color surface = Color(0xFF1E1035);
  static const Color surfaceVariant = Color(0xFF2A1A45);
  static const Color cardBackground = Color(0xFF231545);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5EDD8); // Warm parchment
  static const Color textSecondary = Color(0xFFB8A88A);
  static const Color textDisabled = Color(0xFF6B5E4A);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF1A0A2E);
  static const Color textOnLight = Color(0xFF0F0520);

  // ── Game-specific ─────────────────────────────────────────────────────────
  static const Color questGold = Color(0xFFFFD700);
  static const Color dangerRed = Color(0xFFCC3333);
  static const Color successGreen = Color(0xFF33CC66);
  static const Color warningAmber = Color(0xFFFFAA00);
  static const Color infoBlue = Color(0xFF5599FF);
  static const Color xpPurple = Color(0xFFAA55FF);

  // ── UI Chrome ────────────────────────────────────────────────────────────
  static const Color borderColor = Color(0xFF3D2A6E);
  static const Color dividerColor = Color(0xFF2D1B4E);
  static const Color shadowColor = Color(0x80000000);
  static const Color overlayDark = Color(0xCC000000);
  static const Color overlayLight = Color(0x33FFFFFF);
  static const Color transparent = Colors.transparent;
}
