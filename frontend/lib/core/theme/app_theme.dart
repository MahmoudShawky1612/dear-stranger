import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colour palette ──────────────────────────────────────────────────────────
class RetroColors {
  static const background = Color(0xFFF0E6C8);   // old parchment
  static const surface    = Color(0xFFFAF4E4);   // slightly lighter card
  static const border     = Color(0xFF8B7355);   // warm brown
  static const borderDark = Color(0xFF4A3728);   // dark border / dividers
  static const textPrimary   = Color(0xFF1C1209); // near-black ink
  static const textSecondary = Color(0xFF5C4A2A); // faded ink
  static const link          = Color(0xFF000080); // classic navy blue link
  static const linkVisited   = Color(0xFF551A8B); // visited purple
  static const accent        = Color(0xFF8B2500); // rust red
  static const accentLight   = Color(0xFFB8651A); // amber
  static const gold          = Color(0xFF8B6914); // old gold
  static const silver        = Color(0xFFC0C0C0); // classic silver
  static const white         = Color(0xFFFFFDF5);
  static const marqueeBar    = Color(0xFF000080);

  // Button bevel colours (Windows 95 style)
  static const bevelLight = Color(0xFFEDE0C4);
  static const bevelDark  = Color(0xFF6B5740);
}

// ── Typography ───────────────────────────────────────────────────────────────
class RetroTextStyles {
  static TextStyle get pixel => GoogleFonts.pressStart2p(
        color: RetroColors.textPrimary,
        letterSpacing: 1,
      );

  static TextStyle get typewriter => GoogleFonts.specialElite(
        color: RetroColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get mono => GoogleFonts.courierPrime(
        color: RetroColors.textPrimary,
      );

  // Page header (pixel font, large)
  static TextStyle get h1 => pixel.copyWith(fontSize: 18, height: 1.6);
  static TextStyle get h2 => pixel.copyWith(fontSize: 12, height: 1.8);
  static TextStyle get h3 => pixel.copyWith(fontSize: 9, height: 2.0);

  // Body + UI
  static TextStyle get body  => typewriter.copyWith(fontSize: 15, height: 1.6);
  static TextStyle get small => typewriter.copyWith(fontSize: 12, height: 1.5);
  static TextStyle get label => pixel.copyWith(fontSize: 7, letterSpacing: 2);
  static TextStyle get link  => typewriter.copyWith(
        fontSize: 15,
        color: RetroColors.link,
        decoration: TextDecoration.underline,
        decorationColor: RetroColors.link,
      );
}

// ── Theme ─────────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: RetroColors.background,
        colorScheme: const ColorScheme.light(
          primary: RetroColors.accent,
          secondary: RetroColors.gold,
          surface: RetroColors.surface,
          onPrimary: RetroColors.white,
          onSecondary: RetroColors.white,
          onSurface: RetroColors.textPrimary,
        ),
        textTheme: TextTheme(
          displayLarge:  RetroTextStyles.h1,
          displayMedium: RetroTextStyles.h2,
          displaySmall:  RetroTextStyles.h3,
          bodyLarge:     RetroTextStyles.body,
          bodyMedium:    RetroTextStyles.body,
          bodySmall:     RetroTextStyles.small,
          labelSmall:    RetroTextStyles.label,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: RetroColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: const BorderSide(color: RetroColors.borderDark, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: const BorderSide(color: RetroColors.border, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: const BorderSide(color: RetroColors.accent, width: 2),
          ),
          labelStyle: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary),
          hintStyle: RetroTextStyles.small.copyWith(color: RetroColors.silver),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: RetroColors.marqueeBar,
          foregroundColor: RetroColors.white,
          elevation: 0,
          titleTextStyle: RetroTextStyles.pixel.copyWith(
            fontSize: 11,
            color: RetroColors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: RetroColors.silver,
            foregroundColor: RetroColors.textPrimary,
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            textStyle: RetroTextStyles.pixel.copyWith(fontSize: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        dividerColor: RetroColors.border,
      );
}
