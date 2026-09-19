import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class NewBadge extends StatelessWidget {
  const NewBadge({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFFFB7185)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: const Color(0xFFF43F5E).withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Text('NEW', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.8)),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    Color bg; Color border; Color dotColor; String label;
    switch (status.toUpperCase()) {
      case 'AVAILABLE': bg = const Color(0x1A10B981); border = const Color(0x4D10B981); dotColor = const Color(0xFF10B981); label = 'OPEN FOR ART'; break;
      case 'CLAIMED':   bg = const Color(0x1AF59E0B); border = const Color(0x4DF59E0B); dotColor = const Color(0xFFF59E0B); label = 'IN PROGRESS'; break;
      case 'DELIVERED': bg = const Color(0x1A6366F1); border = const Color(0x4D6366F1); dotColor = const Color(0xFF818CF8); label = 'DELIVERED'; break;
      default:          bg = const Color(0x1A64748B); border = const Color(0x4D64748B); dotColor = const Color(0xFF94A3B8); label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: border, width: 1)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: dotColor.withOpacity(0.6), blurRadius: 4)])),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: dotColor, letterSpacing: 0.6)),
        ],
      ),
    );
  }
}

class RetroButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isSmall;
  final bool isDanger;
  final Widget? icon;

  const RetroButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = false,
    this.isSmall = false,
    this.isDanger = false,
    this.icon,
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final pad = widget.isSmall ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5) : const EdgeInsets.symmetric(horizontal: 16, vertical: 9);
    final fs = widget.isSmall ? 11.0 : 12.0;

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => isEnabled ? setState(() => _pressed = true) : null,
        onTapUp: (_) { if (isEnabled) { setState(() => _pressed = false); widget.onPressed?.call(); } },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.diagonal3Values(_pressed ? 0.97 : (_hovered ? 1.02 : 1.0), _pressed ? 0.97 : (_hovered ? 1.02 : 1.0), 1.0),
          padding: pad,
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                : (widget.isDanger ? const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFBE123C)]) : null),
            color: (!widget.isPrimary && !widget.isDanger) ? (_hovered ? const Color(0xFF1E293B) : const Color(0xFF131A29)) : null,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: widget.isPrimary ? Colors.transparent : (widget.isDanger ? const Color(0xFFF43F5E) : (_hovered ? const Color(0xFF6366F1) : const Color(0xFF26334D))),
              width: 1.2,
            ),
            boxShadow: [
              if (widget.isPrimary && _hovered) BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))
              else if (widget.isDanger && _hovered) BoxShadow(color: const Color(0xFFE11D48).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 6)],
              Text(widget.label, style: GoogleFonts.plusJakartaSans(fontSize: fs, fontWeight: FontWeight.w700, color: isEnabled ? (widget.isPrimary || widget.isDanger ? Colors.white : const Color(0xFFE2E8F0)) : const Color(0xFF64748B), letterSpacing: 0.2)),
            ],
          ),
        ),
      ),
    );
  }
}
