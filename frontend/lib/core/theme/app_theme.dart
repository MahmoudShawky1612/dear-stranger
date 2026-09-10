import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Authentic Early 2000s Web Palette (MySpace / Yahoo / MSN 2001-2006) ──────
class RetroColors {
  // Page structure — real early 2000s sites used crisp white or very pale cool-tinted canvases
  static const pageBackground  = Color(0xFFFFFFFF); // White page canvas
  static const background      = Color(0xFFFFFFFF); // alias
  static const surface         = Color(0xFFFFFFFF); // White content box
  static const tableRow        = Color(0xFFF2F5FA); // Alternating table row (pale cool blue)
  static const tableRowAlt     = Color(0xFFFFFFFF); // White alternating row

  // Header & Navigation — Iconic MySpace Navy & Powder Blue subnav
  static const headerBg        = Color(0xFF003399); // MySpace deep navy header
  static const navBg           = Color(0xFFD5E4F7); // MySpace powder-blue subnav bar
  static const navText         = Color(0xFF003399); // Dark blue text in subnav
  static const navHover        = Color(0xFFB8D3F3); // Slightly darker powder blue on hover
  static const navActive       = Color(0xFF003399); // Active state

  // Sidebar (MTV / MySpace style)
  static const sidebarBg       = Color(0xFFEEF2F8); // Very light cool-gray sidebar
  static const sidebarDark     = Color(0xFF003399); // Navy sidebar section header
  static const sidebarHeader   = Color(0xFF003399); // Blue sidebar header

  // Section Headers & Card Title Strips
  static const sectionHeader       = Color(0xFF003399); // Primary navy title strip
  static const sectionHeaderLight  = Color(0xFFD5E4F7); // Pale blue title strip (MySpace secondary)
  static const sectionHeaderRed    = Color(0xFFCC0000); // Red warning / alert bar
  static const sectionHeaderPurple = Color(0xFF663399); // Deep plum / purple
  static const sectionHeaderGray   = Color(0xFFE0E0E0); // Neutral gray title bar

  // Typography
  static const textPrimary   = Color(0xFF000000); // Sharp black body text
  static const textSecondary = Color(0xFF555555); // Classic web gray text
  static const textMuted     = Color(0xFF888888); // Lighter muted gray
  static const textOnDark    = Color(0xFFFFFFFF); // Pure white on blue
  static const textOnSidebar = Color(0xFF000000); // Black text on sidebar

  // Classic Early-Web Hyperlinks
  static const link          = Color(0xFF003399); // Classic unvisited blue
  static const linkVisited   = Color(0xFF660099); // Classic visited purple
  static const linkHover     = Color(0xFFCC0000); // Classic red hover

  // Iconic Buttons & Accents
  static const btnPrimary    = Color(0xFFFF6600); // The legendary MySpace Orange CTA!
  static const accent        = Color(0xFFCC0000); // Error / alert red
  static const accentOrange  = Color(0xFFFF6600); // Orange badge / NEW! tag
  static const accentGold    = Color(0xFFCC9900); // Gold star
  static const accentGreen   = Color(0xFF006600); // Green success / Open status
  static const accentYellow  = Color(0xFFFFEE88); // Post-it / highlight yellow

  // Borders & Dividers
  static const border        = Color(0xFFB4C6DF); // Classic MySpace soft-blue border
  static const borderDark    = Color(0xFF8090A0); // Darker border
  static const borderGray    = Color(0xFFCCCCCC); // Neutral 1px gray border
  static const borderBlue    = Color(0xFF003399); // Form input active blue

  // Win98 / Windows XP Bevel Buttons
  static const bevelLight    = Color(0xFFFFFFFF); // White highlight
  static const bevelDark     = Color(0xFF808080); // Gray shadow
  static const bevelHighlight = Color(0xFFECE9D8); // Off-white
  static const bevelShadow   = Color(0xFF404040); // Deep shadow

  // Utility
  static const white         = Color(0xFFFFFFFF);
  static const silver        = Color(0xFFECE9D8); // Windows XP button gray
  static const gold          = Color(0xFFCC9900);
  static const marqueeBar    = Color(0xFF003399);
  static const marqueeText   = Color(0xFFFFFFFF);
  static const accentLight   = Color(0xFFD5E4F7);
}

// ── Authentic Typography (Arial / Verdana web standards) ─────────────────────
class RetroTextStyles {
  // Logo font — classic serif / Trebuchet style
  static TextStyle get logo => const TextStyle(
    fontFamily: 'Arial',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: RetroColors.white,
    letterSpacing: -0.5,
  );

  // VT323 preserved for compatibility
  static TextStyle get vt323 => GoogleFonts.vt323(
    color: RetroColors.textPrimary,
    letterSpacing: 0.5,
  );

  // Press Start 2P for retro pixel badges
  static TextStyle get pixel => GoogleFonts.pressStart2p(
    color: RetroColors.textPrimary,
    letterSpacing: 0.5,
  );

  // Courier Prime for typewriter letter reading experience
  static TextStyle get typewriter => GoogleFonts.courierPrime(
    color: RetroColors.textPrimary,
  );

  // Special Elite for vintage feel
  static TextStyle get impact => GoogleFonts.specialElite(
    color: RetroColors.textPrimary,
    fontWeight: FontWeight.bold,
  );

  // ── Standard Headings ──
  static TextStyle get h1 => const TextStyle(
    fontFamily: 'Arial',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: RetroColors.headerBg,
  );
  static TextStyle get h2 => const TextStyle(
    fontFamily: 'Arial',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: RetroColors.headerBg,
  );
  static TextStyle get h3 => const TextStyle(
    fontFamily: 'Arial',
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: RetroColors.headerBg,
  );

  // ── Body / UI Scale ──
  static TextStyle get body => const TextStyle(
    fontFamily: 'Arial',
    fontSize: 12,
    height: 1.45,
    color: RetroColors.textPrimary,
  );
  static TextStyle get small => const TextStyle(
    fontFamily: 'Arial',
    fontSize: 11,
    height: 1.35,
    color: RetroColors.textSecondary,
  );
  static TextStyle get label => const TextStyle(
    fontFamily: 'Arial',
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: RetroColors.textPrimary,
  );

  // ── Specialized UI Elements ──
  static TextStyle get navLink => const TextStyle(
    fontFamily: 'Arial',
    fontSize: 11,
    color: RetroColors.navText,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.none,
  );

  static TextStyle get sectionTitle => const TextStyle(
    fontFamily: 'Arial',
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: RetroColors.textOnDark,
    letterSpacing: 0.3,
  );

  static TextStyle get link => const TextStyle(
    fontFamily: 'Arial',
    fontSize: 12,
    color: RetroColors.link,
    decoration: TextDecoration.underline,
    decorationColor: RetroColors.link,
  );

  static TextStyle get linkSmall => const TextStyle(
    fontFamily: 'Arial',
    fontSize: 11,
    color: RetroColors.link,
    decoration: TextDecoration.underline,
    decorationColor: RetroColors.link,
  );

  static TextStyle get marquee => const TextStyle(
    fontFamily: 'Arial',
    fontSize: 12,
    color: RetroColors.white,
  );
}

// ── Theme Definition ──────────────────────────────────────────────────────────
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
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: RetroColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: RetroColors.borderDark, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: RetroColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: RetroColors.borderBlue, width: 2),
      ),
      labelStyle: TextStyle(fontFamily: 'Arial', fontSize: 11, color: RetroColors.textSecondary),
      hintStyle: TextStyle(fontFamily: 'Arial', fontSize: 11, color: RetroColors.borderDark),
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: RetroColors.headerBg,
      foregroundColor: RetroColors.textOnDark,
      elevation: 0,
      titleTextStyle: RetroTextStyles.h2.copyWith(color: RetroColors.textOnDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: RetroColors.silver,
        foregroundColor: RetroColors.textPrimary,
        elevation: 1,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: const TextStyle(fontFamily: 'Arial', fontSize: 11, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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