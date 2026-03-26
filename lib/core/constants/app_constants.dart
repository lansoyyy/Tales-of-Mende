/// General configuration constants for Tales of Mende.
class AppConstants {
  AppConstants._();

  // ── App ──────────────────────────────────────────────────────────────────
  static const String appName = 'Tales of Mende';
  static const String appVersion = '1.0.0';

  // ── Layout & Spacing ─────────────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ── Border Radius ────────────────────────────────────────────────────────
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 24.0;
  static const double radiusRound = 100.0;

  // ── Animation Durations ──────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 600);
  static const Duration durationVerySlow = Duration(milliseconds: 1000);

  // ── Animation Curves ─────────────────────────────────────────────────────
  // Use Curves.easeInOut, Curves.elasticOut, etc. from Flutter

  // ── Game ─────────────────────────────────────────────────────────────────
  static const int totalPanels = 11;
  static const int totalQuests = 1; // expand as quests are added

  // ── UI Sizes ─────────────────────────────────────────────────────────────
  static const double buttonHeightSm = 40.0;
  static const double buttonHeightMd = 52.0;
  static const double buttonHeightLg = 64.0;
  static const double iconSizeSm = 20.0;
  static const double iconSizeMd = 28.0;
  static const double iconSizeLg = 40.0;
  static const double appBarHeight = 56.0;
  static const double bottomBarHeight = 72.0;

  // ── Elevation ────────────────────────────────────────────────────────────
  static const double elevationNone = 0.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
}
