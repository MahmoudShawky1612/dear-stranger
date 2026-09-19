import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetroColors {
  static const pageBackground  = Color(0xFF090D16);
  static const background      = Color(0xFF090D16);
  static const surface         = Color(0xFF111726);
  static const surfaceLight    = Color(0xFF182238);
  static const tableRow        = Color(0xFF0F1523);
  static const tableRowAlt     = Color(0xFF141D2F);
  static const headerBg        = Color(0xFF0C101B);
  static const navBg           = Color(0xFF131B2E);
  static const navText         = Color(0xFF94A3B8);
  static const navHover        = Color(0xFF6366F1);
  static const navActive       = Color(0xFF818CF8);
  static const primary         = Color(0xFF6366F1);
  static const sidebarBg       = Color(0xFF0D121F);
  static const sidebarDark     = Color(0xFF090D16);
  static const sidebarHeader   = Color(0xFF151E33);
  static const sectionHeader   = Color(0xFF182238);
  static const textPrimary     = Color(0xFFF8FAFC);
  static const textSecondary   = Color(0xFF94A3B8);
  static const textMuted       = Color(0xFF64748B);
  static const textOnDark      = Color(0xFFFFFFFF);
  static const textOnSidebar   = Color(0xFFCBD5E1);
  static const link            = Color(0xFF818CF8);
  static const linkVisited     = Color(0xFFA78BFA);
  static const linkHover       = Color(0xFFF43F5E);
  static const btnPrimary      = Color(0xFF6366F1);
  static const accent          = Color(0xFFF43F5E);
  static const accentOrange    = Color(0xFFF97316);
  static const accentGold      = Color(0xFFF59E0B);
  static const accentGreen     = Color(0xFF10B981);
  static const accentYellow    = Color(0xFFFDE047);
  static const border          = Color(0xFF1E293B);
  static const borderDark      = Color(0xFF0F172A);
  static const borderGray      = Color(0xFF334155);
  static const borderBlue      = Color(0xFF6366F1);
  static const white           = Color(0xFFFFFFFF);
  static const silver          = Color(0xFF334155);
  static const gold            = Color(0xFFF59E0B);
  static const marqueeBar      = Color(0xFF0C101B);
  static const marqueeText     = Color(0xFFF8FAFC);
  static const accentLight     = Color(0xFF1E293B);
  static const bevelLight      = Color(0xFF334155);
  static const bevelDark       = Color(0xFF0B0F19);
  static const bevelHighlight  = Color(0xFF1E293B);
  static const bevelShadow     = Color(0xFF0B0F19);
}

class RetroTextStyles {
  static TextStyle get logo => GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: RetroColors.white, letterSpacing: -0.5);
  static TextStyle get vt323 => GoogleFonts.spaceMono(color: RetroColors.textPrimary, letterSpacing: 0.5);
  static TextStyle get pixel => GoogleFonts.spaceMono(color: RetroColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold);
  static TextStyle get typewriter => GoogleFonts.ibmPlexMono(color: const Color(0xFFE2E8F0), fontSize: 13, height: 1.6);
  static TextStyle get impact => GoogleFonts.outfit(color: RetroColors.textPrimary, fontWeight: FontWeight.bold);
  static TextStyle get h1 => GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: RetroColors.white, letterSpacing: -0.5);
  static TextStyle get h2 => GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: RetroColors.white);
  static TextStyle get h3 => GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: RetroColors.textPrimary);
  static TextStyle get body => GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.5, color: const Color(0xFFCBD5E1));
  static TextStyle get small => GoogleFonts.plusJakartaSans(fontSize: 11, height: 1.4, color: RetroColors.textSecondary);
  static TextStyle get label => GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: RetroColors.textPrimary, letterSpacing: 0.5);
  static TextStyle get navLink => GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600);
  static TextStyle get sectionTitle => GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: RetroColors.white);
  static TextStyle get link => GoogleFonts.plusJakartaSans(fontSize: 13, color: RetroColors.link, fontWeight: FontWeight.w600);
  static TextStyle get linkSmall => GoogleFonts.plusJakartaSans(fontSize: 11, color: RetroColors.link, fontWeight: FontWeight.w600);
  static TextStyle get marquee => GoogleFonts.plusJakartaSans(fontSize: 12, color: RetroColors.white);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: RetroColors.pageBackground,
    colorScheme: const ColorScheme.dark(
      primary: RetroColors.primary,
      secondary: RetroColors.link,
      surface: RetroColors.surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
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
  );
}
