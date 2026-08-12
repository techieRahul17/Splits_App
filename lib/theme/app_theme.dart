import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Brand colors ─────────────────────────────────────────────────────────────
// Gold & chrome on true black — a premium, high-contrast identity with a
// single loud metallic accent (no purple, no gradients-on-everything).
class SplitsColors {
  SplitsColors._();

  // Brand accent — warm metallic gold. Used as a FILL in both themes.
  static const Color primary = Color(0xFFF5B93D);
  static const Color primaryBright = Color(0xFFFFD873);
  static const Color primaryDim = Color(0xFFC98F12);

  /// Gold reads well as a fill but is far too light to use as TEXT on a white
  /// background, so light mode swaps in a deep bronze for accent-colored text.
  static const Color primaryOnLight = Color(0xFF9A6B0B);

  // Text/icon color to use ON TOP of a solid gold fill — gold is a light,
  // bright accent, so filled buttons/badges need dark ink for contrast.
  static const Color onGold = Color(0xFF1F1703);

  // Chrome — cool steel accent for secondary/active states, distinct from gold
  static const Color chrome = Color(0xFFAFC0CC);
  static const Color chromeDim = Color(0xFF7C8A96);

  // Semantic — bright variants for dark mode, deep variants for light mode
  static const Color positive = Color(0xFF22D68A);
  static const Color positiveDim = Color(0xFF13A468);
  static const Color positiveOnLight = Color(0xFF078351);
  static const Color negative = Color(0xFFFF5C6A);
  static const Color negativeDim = Color(0xFFD9425A);
  static const Color negativeOnLight = Color(0xFFC22B3E);
  static const Color warning = Color(0xFFFF8A3D);
  static const Color info = Color(0xFF52B4E8);
  static const Color infoOnLight = Color(0xFF1B6F9E);
  static const Color whatsapp = Color(0xFF25D366);

  // Dark surfaces — warm-neutral graphite, subtly lifted off pure black so
  // cards separate from the background without needing heavy borders.
  static const Color darkBg = Color(0xFF0A0A0B);
  static const Color darkSurface = Color(0xFF151517);
  static const Color darkSurfaceRaised = Color(0xFF1D1D20);
  static const Color darkSurfaceHigh = Color(0xFF27272B);
  static const Color darkBorder = Color(0x14FFFFFF);
  static const Color darkBorderStrong = Color(0x2BFFFFFF);

  // Light surfaces — warm off-white, never clinical grey-blue
  static const Color lightBg = Color(0xFFFAFAF8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceRaised = Color(0xFFF4F4F1);
  static const Color lightSurfaceHigh = Color(0xFFE9E9E4);
  static const Color lightBorder = Color(0x12141414);
  static const Color lightBorderStrong = Color(0x26141414);

  // Text
  static const Color textDarkPrimary = Color(0xFFF7F7F5);
  static const Color textDarkSecondary = Color(0xFF9E9E9B);
  static const Color textDarkTertiary = Color(0xFF6A6A67);

  static const Color textLightPrimary = Color(0xFF17160F);
  static const Color textLightSecondary = Color(0xFF64635B);
  static const Color textLightTertiary = Color(0xFF97968D);

  // Hero gradient — metallic gold sheen, reserved for hero headers only
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFFFD873), Color(0xFFE7A81E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [positiveDim, positive],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ── Spacing / radius tokens ───────────────────────────────────────────────────
class SplitsSpacing {
  SplitsSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class SplitsRadius {
  SplitsRadius._();
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 999;
}

// ── Palette accessor ──────────────────────────────────────────────────────────
/// Theme-aware surface/text colors, resolved once per brightness so screens
/// never need to branch on `isDark` themselves.
class AppPalette {
  const AppPalette({
    required this.bg,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceHigh,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accentText,
    required this.positiveText,
    required this.negativeText,
    required this.infoText,
    required this.isDark,
  });

  final Color bg;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceHigh;
  final Color border;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Accent-colored TEXT/ICONS drawn directly on [bg]/[surface]. Distinct from
  /// [SplitsColors.primary], which is the accent used as a solid fill.
  final Color accentText;
  final Color positiveText;
  final Color negativeText;
  final Color infoText;
  final bool isDark;

  /// Tint strength for accent-on-surface chips — light mode needs a stronger
  /// wash than dark mode for the same perceived weight.
  double get tint => isDark ? 0.14 : 0.13;

  static const dark = AppPalette(
    bg: SplitsColors.darkBg,
    surface: SplitsColors.darkSurface,
    surfaceRaised: SplitsColors.darkSurfaceRaised,
    surfaceHigh: SplitsColors.darkSurfaceHigh,
    border: SplitsColors.darkBorder,
    borderStrong: SplitsColors.darkBorderStrong,
    textPrimary: SplitsColors.textDarkPrimary,
    textSecondary: SplitsColors.textDarkSecondary,
    textTertiary: SplitsColors.textDarkTertiary,
    accentText: SplitsColors.primary,
    positiveText: SplitsColors.positive,
    negativeText: SplitsColors.negative,
    infoText: SplitsColors.info,
    isDark: true,
  );

  static const light = AppPalette(
    bg: SplitsColors.lightBg,
    surface: SplitsColors.lightSurface,
    surfaceRaised: SplitsColors.lightSurfaceRaised,
    surfaceHigh: SplitsColors.lightSurfaceHigh,
    border: SplitsColors.lightBorder,
    borderStrong: SplitsColors.lightBorderStrong,
    textPrimary: SplitsColors.textLightPrimary,
    textSecondary: SplitsColors.textLightSecondary,
    textTertiary: SplitsColors.textLightTertiary,
    accentText: SplitsColors.primaryOnLight,
    positiveText: SplitsColors.positiveOnLight,
    negativeText: SplitsColors.negativeOnLight,
    infoText: SplitsColors.infoOnLight,
    isDark: false,
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

// ── Theme builder ─────────────────────────────────────────────────────────────
class SplitsTheme {
  SplitsTheme._();

  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final p = isDark ? AppPalette.dark : AppPalette.light;
    final base = ThemeData(brightness: brightness, useMaterial3: true);

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: p.textPrimary,
      displayColor: p.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: p.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SplitsColors.primary,
        brightness: brightness,
        primary: SplitsColors.primary,
        secondary: SplitsColors.positive,
        surface: p.surface,
        error: SplitsColors.negative,
      ),
      textTheme: textTheme.copyWith(
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: p.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: p.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SplitsRadius.lg),
          side: BorderSide(color: p.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SplitsRadius.md),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SplitsRadius.md),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SplitsRadius.md),
          borderSide: const BorderSide(color: SplitsColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SplitsRadius.md),
          borderSide: const BorderSide(color: SplitsColors.negative, width: 1.4),
        ),
        labelStyle: TextStyle(color: p.textSecondary),
        hintStyle: TextStyle(color: p.textTertiary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceRaised,
        selectedColor: SplitsColors.primary.withOpacity(0.18),
        side: BorderSide(color: p.border),
        labelStyle: TextStyle(color: p.textPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SplitsRadius.sm)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        modalBackgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SplitsRadius.xl)),
        titleTextStyle: GoogleFonts.inter(
          color: p.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.inter(
          color: p.textSecondary,
          fontSize: 14,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.surfaceHigh,
        contentTextStyle: TextStyle(color: p.textPrimary),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SplitsRadius.md)),
        behavior: SnackBarBehavior.floating,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SplitsRadius.md),
          side: BorderSide(color: p.border),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SplitsColors.primary,
        foregroundColor: SplitsColors.onGold,
        elevation: 0,
        shape: StadiumBorder(),
      ),
      iconTheme: IconThemeData(color: p.textPrimary),
    );
  }
}

/// Semantic color roles. Resolve through [AppPalette] so each theme gets a
/// value with the right contrast, rather than one hardcoded bright color that
/// looks correct on black and washes out on white.
enum Tone { accent, positive, negative, info, neutral }

extension ToneResolver on Tone {
  /// The color for text/icons of this tone drawn on a page/card surface.
  Color text(AppPalette p) => switch (this) {
        Tone.accent => p.accentText,
        Tone.positive => p.positiveText,
        Tone.negative => p.negativeText,
        Tone.info => p.infoText,
        Tone.neutral => p.textSecondary,
      };

  /// The saturated base color for this tone, used for solid fills and tints.
  Color base() => switch (this) {
        Tone.accent => SplitsColors.primary,
        Tone.positive => SplitsColors.positive,
        Tone.negative => SplitsColors.negative,
        Tone.info => SplitsColors.info,
        Tone.neutral => SplitsColors.chromeDim,
      };
}

/// Tabular-figure style for money amounts — keeps digits aligned in lists.
TextStyle amountStyle({
  required double size,
  required FontWeight weight,
  required Color color,
  double letterSpacing = -0.3,
}) {
  return TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
