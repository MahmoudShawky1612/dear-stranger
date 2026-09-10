import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Early 2000s web colour palette ─────────────────────────────────────────
class RetroColors {
  // Page backgrounds
  static const pageBackground  = Color(0xFFE8E4F0); // light lavender (MySpace/Nintendo)
  static const background      = Color(0xFFE8E4F0); // alias
  static const surface         = Color(0xFFFFFFFF); // card white
  static const sidebarBg       = Color(0xFF9B77B8); // MTV purple sidebar
  static const sidebarDark     = Color(0xFF6A3B9B); // darker purple for sidebar header

  // Header / navbar
  static const headerBg        = Color(0xFF000080); // classic deep navy blue
  static const navBg           = Color(0xFF4A0080); // dark purple nav bar
  static const navHover        = Color(0xFF6A10A8); // lighter purple on hover
  static const navActive       = Color(0xFFCC0000); // active = red tab

  // Section header strips (like Nintendo "■ OFFICIAL NEWS" bars)
  static const sectionHeader   = Color(0xFF336699); // medium blue section headers
  static const sectionHeaderRed = Color(0xFF990000); // red section headers alt
  static const sectionHeaderPurple = Color(0xFF6B3CA6); // purple headers

  // Text
  static const textPrimary   = Color(0xFF000000); // pure black body text
  static const textSecondary = Color(0xFF666666); // gray secondary
  static const textOnDark    = Color(0xFFFFFFFF); // white on dark backgrounds
  static const textOnSidebar = Color(0xFFFFE8FF); // pale lavender on purple sidebar

  // Classic hyperlinks (browser defaults)
  static const link          = Color(0xFF0000EE); // unvisited blue
  static const linkVisited   = Color(0xFF551A8B); // visited purple
  static const linkHover     = Color(0xFFCC0000); // hover red

  // Accents
  static const accent        = Color(0xFFCC0000); // bold red
  static const accentOrange  = Color(0xFFFF6600); // early web orange
  static const accentGold    = Color(0xFFCC9900); // gold/amber
  static const accentGreen   = Color(0xFF006600); // success green
  static const accentYellow  = Color(0xFFFFFF00); // highlight yellow (sparingly)

  // Borders & dividers
  static const border        = Color(0xFFCCCCCC); // light gray standard border
  static const borderDark    = Color(0xFF999999); // darker gray dividers
  static const borderBlue    = Color(0xFF336699); // blue info borders

  // Button bevel (Windows 95 / early browser style)
  static const bevelLight    = Color(0xFFEEEEEE);
  static const bevelDark     = Color(0xFF999999);
  static const bevelHighlight = Color(0xFFFFFFFF);
  static const bevelShadow   = Color(0xFF888888);

  // Utility
  static const white         = Color(0xFFFFFFFF);
  static const silver        = Color(0xFFC0C0C0);
  static const gold          = Color(0xFFCC9900);
  static const marqueeBar    = Color(0xFF000080); // kept for compat
  static const marqueeText   = Color(0xFFFFFF00); // marquee ticker text
}

// ── Early 2000s web typography ─────────────────────────────────────────────
class RetroTextStyles {
  // VT323 — monospace pixel terminal font (headings)
  static TextStyle get vt323 => GoogleFonts.vt323(
        color: RetroColors.textPrimary,
        letterSpacing: 1,
      );

  // Press Start 2P — hard pixel font (labels / badges)
  static TextStyle get pixel => GoogleFonts.pressStart2p(
        color: RetroColors.textPrimary,
        letterSpacing: 1,
      );

  // Courier Prime — typewriter / body text
  static TextStyle get typewriter => GoogleFonts.courierPrime(
        color: RetroColors.textPrimary,
        letterSpacing: 0.3,
      );

  // Impact-like bold for section titles
  static TextStyle get impact => GoogleFonts.specialElite(
        color: RetroColors.textPrimary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      );

  // ── Heading scale (VT323 — large and legible) ──
  static TextStyle get h1 => vt323.copyWith(fontSize: 36, height: 1.2);
  static TextStyle get h2 => vt323.copyWith(fontSize: 26, height: 1.3);
  static TextStyle get h3 => vt323.copyWith(fontSize: 20, height: 1.4);

  // ── Body / UI scale ──
  static TextStyle get body  => typewriter.copyWith(fontSize: 14, height: 1.6);
  static TextStyle get small => typewriter.copyWith(fontSize: 12, height: 1.5);
  static TextStyle get label => pixel.copyWith(fontSize: 7, letterSpacing: 1.5, height: 2.0);

  // ── Specialized styles ──
  static TextStyle get navLink => vt323.copyWith(
        fontSize: 16,
        color: RetroColors.silver,
        letterSpacing: 1,
      );

  static TextStyle get sectionTitle => vt323.copyWith(
        fontSize: 18,
        color: RetroColors.textOnDark,
        letterSpacing: 1.5,
      );

  static TextStyle get link => typewriter.copyWith(
        fontSize: 13,
        color: RetroColors.link,
        decoration: TextDecoration.underline,
        decorationColor: RetroColors.link,
      );

  static TextStyle get linkSmall => typewriter.copyWith(
        fontSize: 12,
        color: RetroColors.link,
        decoration: TextDecoration.underline,
        decorationColor: RetroColors.link,
      );

  static TextStyle get marquee => vt323.copyWith(
        fontSize: 16,
        color: RetroColors.marqueeText,
      );
}

// ── Theme ──────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: RetroColors.pageBackground,
        colorScheme: const ColorScheme.light(
          primary: RetroColors.headerBg,
          secondary: RetroColors.sectionHeader,
          surface: RetroColors.surface,
          onPrimary: RetroColors.textOnDark,
          onSecondary: RetroColors.textOnDark,
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
            borderSide: const BorderSide(color: RetroColors.borderDark, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: const BorderSide(color: RetroColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: const BorderSide(color: RetroColors.sectionHeader, width: 2),
          ),
          labelStyle: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary),
          hintStyle: RetroTextStyles.small.copyWith(color: RetroColors.borderDark),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: RetroColors.headerBg,
          foregroundColor: RetroColors.textOnDark,
          elevation: 0,
          titleTextStyle: RetroTextStyles.vt323.copyWith(
            fontSize: 22,
            color: RetroColors.textOnDark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: RetroColors.silver,
            foregroundColor: RetroColors.textPrimary,
            elevation: 2,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            textStyle: RetroTextStyles.pixel.copyWith(fontSize: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(RetroColors.sectionHeader),
        ),
        dividerColor: RetroColors.border,
        dividerTheme: const DividerThemeData(
          color: RetroColors.border,
          thickness: 1,
        ),
      );
}
