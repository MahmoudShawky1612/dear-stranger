import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class RetroCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Color? titleBarColor;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const RetroCard({super.key, required this.child, this.title, this.titleBarColor, this.trailing, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111726),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF161E31),
                border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4, height: 14,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFA855F7)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(title!, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3)),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class RetroDivider extends StatelessWidget {
  final String? label;
  const RetroDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Container(margin: const EdgeInsets.symmetric(vertical: 12), height: 1, color: const Color(0xFF1E293B));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: const Color(0xFF1E293B))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(label!, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF64748B), letterSpacing: 0.8)),
          ),
          Expanded(child: Container(height: 1, color: const Color(0xFF1E293B))),
        ],
      ),
    );
  }
}
