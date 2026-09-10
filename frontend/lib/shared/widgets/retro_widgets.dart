import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/theme/app_theme.dart';

// ─── Authentic Early-Web Pixel Icons ──────────────────────────────────────────
enum PixelIconType {
  envelope,
  pencil,
  palette,
  user,
  bubble,
  document,
  pin,
  calendar,
  star,
}

class PixelIcon extends StatelessWidget {
  final PixelIconType type;
  final double size;
  final Color? color;

  const PixelIcon(this.type, {super.key, this.size = 14, this.color});

  static Widget mail({double size = 14, Color? color}) => PixelIcon(PixelIconType.envelope, size: size, color: color);
  static Widget write({double size = 14, Color? color}) => PixelIcon(PixelIconType.pencil, size: size, color: color);
  static Widget palette({double size = 14, Color? color}) => PixelIcon(PixelIconType.palette, size: size, color: color);
  static Widget userIcon({double size = 14, Color? color}) => PixelIcon(PixelIconType.user, size: size, color: color);
  static Widget chat({double size = 14, Color? color}) => PixelIcon(PixelIconType.bubble, size: size, color: color);
  static Widget doc({double size = 14, Color? color}) => PixelIcon(PixelIconType.document, size: size, color: color);
  static Widget pin({double size = 14, Color? color}) => PixelIcon(PixelIconType.pin, size: size, color: color);
  static Widget calendar({double size = 14, Color? color}) => PixelIcon(PixelIconType.calendar, size: size, color: color);
  static Widget star({double size = 14, Color? color}) => PixelIcon(PixelIconType.star, size: size, color: color);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PixelIconPainter(type, color),
    );
  }
}

class _PixelIconPainter extends CustomPainter {
  final PixelIconType type;
  final Color? customColor;

  _PixelIconPainter(this.type, this.customColor);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 16.0;
    canvas.save();
    canvas.scale(scale, scale);

    final pStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final pFill = Paint()..style = PaintingStyle.fill;

    switch (type) {
      case PixelIconType.envelope:
        // Classic Windows 98 / Outlook Express envelope icon
        pFill.color = const Color(0xFFFFFEE0); // Cream paper
        canvas.drawRect(const Rect.fromLTWH(1, 3, 14, 10), pFill);
        pStroke.color = const Color(0xFF003366);
        canvas.drawRect(const Rect.fromLTWH(1, 3, 14, 10), pStroke);
        // Flap
        final flap = Path()
          ..moveTo(1, 3)
          ..lineTo(8, 9)
          ..lineTo(15, 3);
        canvas.drawPath(flap, pStroke);
        // Bottom folds
        final folds = Path()
          ..moveTo(1, 13)
          ..lineTo(6, 8)
          ..moveTo(15, 13)
          ..lineTo(10, 8);
        canvas.drawPath(folds, pStroke);
        break;

      case PixelIconType.pencil:
        // Yellow pencil with pink eraser and graphite tip
        pFill.color = const Color(0xFFFFCC00); // Yellow shaft
        canvas.drawRect(const Rect.fromLTWH(4, 5, 8, 7), pFill);
        pFill.color = const Color(0xFFFF9999); // Pink eraser
        canvas.drawRect(const Rect.fromLTWH(10, 2, 4, 4), pFill);
        pFill.color = const Color(0xFF333333); // Graphite tip
        final tip = Path()
          ..moveTo(2, 14)
          ..lineTo(5, 11)
          ..lineTo(2, 11)
          ..close();
        canvas.drawPath(tip, pFill);
        pStroke.color = const Color(0xFF553300);
        canvas.drawRect(const Rect.fromLTWH(4, 5, 8, 7), pStroke);
        break;

      case PixelIconType.palette:
        // Artist's wooden palette with primary color blobs
        pFill.color = const Color(0xFFE5C178); // Light wood
        canvas.drawOval(const Rect.fromLTWH(1, 1, 14, 13), pFill);
        pStroke.color = const Color(0xFF664411);
        canvas.drawOval(const Rect.fromLTWH(1, 1, 14, 13), pStroke);
        // Paint blobs
        pFill.color = const Color(0xFFCC0000); // Red
        canvas.drawCircle(const Offset(5, 4), 1.5, pFill);
        pFill.color = const Color(0xFF008800); // Green
        canvas.drawCircle(const Offset(10, 4), 1.5, pFill);
        pFill.color = const Color(0xFF0033CC); // Blue
        canvas.drawCircle(const Offset(11, 8), 1.5, pFill);
        pFill.color = const Color(0xFFFF9900); // Orange
        canvas.drawCircle(const Offset(5, 9), 1.5, pFill);
        break;

      case PixelIconType.user:
        // Classic MSN / MySpace buddy silhouette
        pFill.color = customColor ?? const Color(0xFF003399);
        // Head
        canvas.drawCircle(const Offset(8, 4.5), 3.0, pFill);
        // Shoulders
        final shoulders = Path()
          ..moveTo(2, 14)
          ..quadraticBezierTo(4, 9, 8, 9)
          ..quadraticBezierTo(12, 9, 14, 14)
          ..close();
        canvas.drawPath(shoulders, pFill);
        break;

      case PixelIconType.bubble:
        // Speech bubble for messages/replies
        pFill.color = const Color(0xFFFFFFFF);
        final bubble = Path()
          ..addRect(const Rect.fromLTWH(1, 2, 14, 9))
          ..moveTo(3, 11)
          ..lineTo(3, 14)
          ..lineTo(7, 11)
          ..close();
        canvas.drawPath(bubble, pFill);
        pStroke.color = const Color(0xFF003399);
        canvas.drawPath(bubble, pStroke);
        // Lines of text inside
        pStroke.color = const Color(0xFF88A0C0);
        canvas.drawLine(const Offset(4, 5), const Offset(12, 5), pStroke);
        canvas.drawLine(const Offset(4, 8), const Offset(10, 8), pStroke);
        break;

      case PixelIconType.document:
        // Folded sheet of paper
        pFill.color = const Color(0xFFFFFFFF);
        final page = Path()
          ..moveTo(2, 1)
          ..lineTo(10, 1)
          ..lineTo(14, 5)
          ..lineTo(14, 15)
          ..lineTo(2, 15)
          ..close();
        canvas.drawPath(page, pFill);
        pStroke.color = const Color(0xFF003399);
        canvas.drawPath(page, pStroke);
        // Corner fold
        final fold = Path()
          ..moveTo(10, 1)
          ..lineTo(10, 5)
          ..lineTo(14, 5);
        canvas.drawPath(fold, pStroke);
        // Text lines
        pStroke.color = const Color(0xFF99AACC);
        canvas.drawLine(const Offset(4, 7), const Offset(12, 7), pStroke);
        canvas.drawLine(const Offset(4, 10), const Offset(12, 10), pStroke);
        canvas.drawLine(const Offset(4, 13), const Offset(9, 13), pStroke);
        break;

      case PixelIconType.pin:
        // Pushpin
        pFill.color = const Color(0xFFCC0000);
        canvas.drawCircle(const Offset(8, 5), 4.0, pFill);
        pStroke.color = const Color(0xFF888888);
        canvas.drawLine(const Offset(8, 9), const Offset(8, 15), pStroke);
        break;

      case PixelIconType.calendar:
        // Calendar sheet
        pFill.color = const Color(0xFFCC0000); // Red header
        canvas.drawRect(const Rect.fromLTWH(2, 2, 12, 4), pFill);
        pFill.color = const Color(0xFFFFFFFF); // White body
        canvas.drawRect(const Rect.fromLTWH(2, 6, 12, 8), pFill);
        pStroke.color = const Color(0xFF444444);
        canvas.drawRect(const Rect.fromLTWH(2, 2, 12, 12), pStroke);
        break;

      case PixelIconType.star:
        // Yellow 5-point star
        pFill.color = const Color(0xFFFFCC00);
        pStroke.color = const Color(0xFF996600);
        final star = Path()
          ..moveTo(8, 1)
          ..lineTo(10, 6)
          ..lineTo(15, 6)
          ..lineTo(11, 9.5)
          ..lineTo(12.5, 14.5)
          ..lineTo(8, 11.5)
          ..lineTo(3.5, 14.5)
          ..lineTo(5, 9.5)
          ..lineTo(1, 6)
          ..lineTo(6, 6)
          ..close();
        canvas.drawPath(star, pFill);
        canvas.drawPath(star, pStroke);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PixelIconPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.customColor != customColor;
}

// ─── Authentic Early-Web "NEW!" Badge ─────────────────────────────────────────
class NewBadge extends StatelessWidget {
  const NewBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: RetroColors.accentOrange,
        border: Border.all(color: const Color(0xFFCC3300), width: 1),
      ),
      child: const Text(
        'NEW!',
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: RetroColors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Buttons: Iconic Orange CTA or Win98 Bevel ────────────────────────────────
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
  bool _pressed = false;

  Color get _bg {
    if (widget.onPressed == null) return const Color(0xFFDDDDDD);
    if (widget.isDanger) return RetroColors.accent;
    if (widget.isPrimary) return RetroColors.btnPrimary; // Iconic MySpace Orange!
    return RetroColors.silver; // Classic Win98 / XP Button Gray
  }

  Color get _fg {
    if (widget.onPressed == null) return RetroColors.textMuted;
    if (widget.isPrimary || widget.isDanger) return RetroColors.white;
    return RetroColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final borderLight = widget.isPrimary ? const Color(0xFFFF9933) : RetroColors.bevelLight;
    final borderDark = widget.isPrimary ? const Color(0xFFCC4400) : RetroColors.bevelDark;

    return MouseRegion(
      cursor: widget.onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed?.call();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: Container(
          decoration: BoxDecoration(
            color: _bg,
            border: Border(
              top: BorderSide(
                color: _pressed ? borderDark : borderLight,
                width: 2,
              ),
              left: BorderSide(
                color: _pressed ? borderDark : borderLight,
                width: 2,
              ),
              bottom: BorderSide(
                color: _pressed ? borderLight : borderDark,
                width: 2,
              ),
              right: BorderSide(
                color: _pressed ? borderLight : borderDark,
                width: 2,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSmall ? 8 : 12,
            vertical: widget.isSmall ? 3 : 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 4),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: widget.isSmall ? 10 : 11,
                  fontWeight: FontWeight.bold,
                  color: _fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Early-Web Card Panel (MySpace-style content box) ─────────────────────────
class RetroCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Color? titleBarColor;
  final EdgeInsetsGeometry? padding;
  final Widget? trailing;

  const RetroCard({
    super.key,
    required this.child,
    this.title,
    this.titleBarColor,
    this.padding,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = titleBarColor ?? RetroColors.sectionHeader;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: RetroColors.surface,
        border: Border.all(color: RetroColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Container(
              width: double.infinity,
              color: barColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: RetroColors.textOnDark,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          Padding(
            padding: padding ?? EdgeInsets.all(title != null ? 10 : 12),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─── HTML Form Field ──────────────────────────────────────────────────────────
class RetroTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;

  const RetroTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: RetroColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        TextFormField(
          controller: controller,
          maxLines: obscureText ? 1 : maxLines,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onTap: onTap,
          style: const TextStyle(fontFamily: 'Arial', fontSize: 12),
          decoration: InputDecoration(hintText: hint),
          validator: validator,
        ),
      ],
    );
  }
}

// ─── Divider Line ─────────────────────────────────────────────────────────────
class RetroDivider extends StatelessWidget {
  final String? label;
  const RetroDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Divider(color: RetroColors.border, height: 1, thickness: 1),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(child: Divider(color: RetroColors.border, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label!,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 10,
                color: RetroColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(child: Divider(color: RetroColors.border, height: 1)),
        ],
      ),
    );
  }
}

// ─── Loading Indicator ────────────────────────────────────────────────────────
class RetroLoading extends StatefulWidget {
  final String message;
  const RetroLoading({super.key, this.message = 'Loading'});

  @override
  State<RetroLoading> createState() => _RetroLoadingState();
}

class _RetroLoadingState extends State<RetroLoading> {
  int _dots = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) setState(() => _dots = (_dots + 1) % 4);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotsStr = '.' * _dots;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PixelIcon.mail(size: 14),
          const SizedBox(width: 6),
          Text(
            '${widget.message}$dotsStr',
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 11,
              color: RetroColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error Display ────────────────────────────────────────────────────────────
class RetroError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const RetroError(this.message, {super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RetroCard(
        title: 'Error Encountered',
        titleBarColor: RetroColors.accent,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: RetroTextStyles.body, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              RetroButton(label: 'Try Again', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  static Color _bgFor(String s) {
    switch (s.toLowerCase()) {
      case 'open':       return const Color(0xFF008800);
      case 'claimed':    return const Color(0xFF003399);
      case 'delivered':  return const Color(0xFF663399);
      default:           return RetroColors.textMuted;
    }
  }

  static String _labelFor(String s) {
    switch (s.toLowerCase()) {
      case 'open':       return 'OPEN';
      case 'claimed':    return 'CLAIMED';
      case 'delivered':  return 'DELIVERED';
      default:           return s.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: _bgFor(status),
        border: Border.all(color: Colors.black26, width: 1),
      ),
      child: Text(
        _labelFor(status),
        style: const TextStyle(
          fontFamily: 'Arial',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: RetroColors.white,
        ),
      ),
    );
  }
}

// ─── App Scaffold Shell ───────────────────────────────────────────────────────
class RetroScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final ScrollController? scrollController;
  final bool showSidebar;

  const RetroScaffold({
    super.key,
    required this.body,
    this.title,
    this.scrollController,
    this.showSidebar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RetroColors.pageBackground,
      body: Column(
        children: [
          const _SiteHeader(),
          const _NavBar(),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: showSidebar
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Sidebar(),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: body,
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: body,
                        ),
                ),
              ),
            ),
          ),
          const _Footer(),
        ],
      ),
    );
  }
}

// ─── Top Navy Header Banner (MySpace Style) ───────────────────────────────────
class _SiteHeader extends StatelessWidget {
  const _SiteHeader();

  @override
  Widget build(BuildContext context) {
    final notifs = context.watch<NotificationProvider>();
    final isAuth = context.select<AuthProvider, bool>((a) => a.isAuthenticated);
    final user = context.select<AuthProvider, dynamic>((a) => a.user);
    final unread = notifs.unreadCount;

    return Container(
      width: double.infinity,
      color: RetroColors.headerBg,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo with Pixel Envelope
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PixelIcon.mail(size: 20),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'dear-stranger',
                                style: RetroTextStyles.logo.copyWith(fontSize: 24),
                              ),
                              const Text(
                                '.com',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD5E4F7),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'a place for letters & hand-drawn art',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 10,
                              color: Color(0xFFB4C6DF),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // User / Notification quick link in header
              if (isAuth && user != null) ...[
                Text(
                  'Hello, ${user.displayHandle}',
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 11,
                    color: RetroColors.white,
                  ),
                ),
                const Text(' | ', style: TextStyle(color: Color(0xFF7799CC))),
                GestureDetector(
                  onTap: () => _NotificationsNavButton(notifs: notifs).show(context),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          unread > 0 ? 'Mail ($unread)' : 'Mail (0)',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: unread > 0 ? const Color(0xFFFFCC00) : RetroColors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: unread > 0 ? const Color(0xFFFFCC00) : RetroColors.white,
                          ),
                        ),
                        if (unread > 0) ...[
                          const SizedBox(width: 4),
                          const NewBadge(),
                        ],
                      ],
                    ),
                  ),
                ),
              ] else ...[
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: RetroColors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: RetroColors.white,
                      ),
                    ),
                  ),
                ),
                const Text(' | ', style: TextStyle(color: Color(0xFF7799CC))),
                GestureDetector(
                  onTap: () => context.go('/register'),
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFCC00),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFFFFCC00),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-Nav Bar (Iconic MySpace Powder Blue) ─────────────────────────────────
class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    final isAuth = context.select<AuthProvider, bool>((a) => a.isAuthenticated);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: RetroColors.navBg,
        border: Border(
          bottom: BorderSide(color: Color(0xFFB4C6DF), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _NavLink(label: 'Home', path: '/'),
                _Pipe(),
                _NavLink(label: 'Mail Board', path: '/'),
                _Pipe(),
                _NavLink(label: 'Write a Letter', path: '/letters/new'),
                if (isAuth) ...[
                  _Pipe(),
                  _NavLink(label: 'My Sent Mail', path: '/letters/mine'),
                  _Pipe(),
                  _NavLink(label: 'My Claims', path: '/letters/claimed'),
                  _Pipe(),
                  _NavLink(label: 'My Profile', path: '/settings'),
                ],
                if (!isAuth) ...[
                  _Pipe(),
                  _NavLink(label: 'Member Login', path: '/login'),
                  _Pipe(),
                  _NavLink(label: 'Create Account', path: '/register'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pipe extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 4),
    child: Text(
      '|',
      style: TextStyle(
        fontFamily: 'Arial',
        fontSize: 11,
        color: Color(0xFF88A8D0),
      ),
    ),
  );
}

class _NavLink extends StatefulWidget {
  final String label;
  final String path;
  const _NavLink({required this.label, required this.path});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final isActive = widget.path != '/' && currentPath == widget.path;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.path),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isActive ? RetroColors.btnPrimary : RetroColors.navText,
              decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
              decorationColor: RetroColors.navText,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Notification Bell / Popup ────────────────────────────────────────────────
class _NotificationsNavButton extends StatelessWidget {
  final NotificationProvider notifs;
  const _NotificationsNavButton({required this.notifs});

  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => const _NotificationsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = notifs.unreadCount;
    final hasUnread = count > 0;

    return GestureDetector(
      onTap: () => show(context),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PixelIcon.mail(size: 13),
            const SizedBox(width: 4),
            Text(
              hasUnread ? 'Mail ($count)' : 'Mail',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: hasUnread ? const Color(0xFFFFCC00) : RetroColors.white,
                decoration: TextDecoration.underline,
                decorationColor: hasUnread ? const Color(0xFFFFCC00) : RetroColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Notification Dialog ──────────────────────────────────────────────────────
class _NotificationsDialog extends StatefulWidget {
  const _NotificationsDialog();

  @override
  State<_NotificationsDialog> createState() => _NotificationsDialogState();
}

class _NotificationsDialogState extends State<_NotificationsDialog> {
  @override
  Widget build(BuildContext context) {
    final notifs = context.watch<NotificationProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Container(
              width: double.infinity,
              color: RetroColors.headerBg,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                children: [
                  PixelIcon.mail(size: 14),
                  const SizedBox(width: 6),
                  const Text(
                    'Your Mailbox',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: RetroColors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      '[X]',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: RetroColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Container(
              color: RetroColors.surface,
              child: notifs.notifications.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No new mail. Check back later!',
                        style: RetroTextStyles.body.copyWith(color: RetroColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 420),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: notifs.notifications.length,
                        itemBuilder: (ctx, i) {
                          final n = notifs.notifications[i];
                          final isUnread = !n.isRead;
                          return GestureDetector(
                            onTap: () async {
                              await notifs.markAsRead(n.id);
                              if (ctx.mounted) {
                                Navigator.of(ctx).pop();
                                ctx.go('/letters/${n.letterId}');
                              }
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                color: isUnread
                                    ? const Color(0xFFFFFDE0)
                                    : (i.isEven ? RetroColors.surface : RetroColors.tableRow),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isUnread ? '>> ' : '   ',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: RetroColors.accent,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n.title,
                                            style: TextStyle(
                                              fontFamily: 'Arial',
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isUnread ? RetroColors.link : RetroColors.textPrimary,
                                              decoration: isUnread ? TextDecoration.underline : TextDecoration.none,
                                              decorationColor: RetroColors.link,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(n.message, style: RetroTextStyles.small),
                                        ],
                                      ),
                                    ),
                                    if (isUnread) ...[
                                      const SizedBox(width: 4),
                                      const NewBadge(),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            // Footer
            Container(
              width: double.infinity,
              color: RetroColors.tableRow,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${notifs.unreadCount} unread',
                    style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text('>> Close', style: RetroTextStyles.linkSmall),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Left Sidebar (MTV / MySpace Style) ───────────────────────────────────────
class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    final isAuth = context.select<AuthProvider, bool>((a) => a.isAuthenticated);
    final user   = context.select<AuthProvider, dynamic>((a) => a.user);

    return Container(
      width: 156,
      constraints: const BoxConstraints(minHeight: 400),
      decoration: const BoxDecoration(
        color: RetroColors.sidebarBg,
        border: Border(right: BorderSide(color: RetroColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SidebarSection(
            title: 'Getting Around',
            children: [
              _SidebarLink(label: 'Mail Board', path: '/'),
              _SidebarLink(label: 'Write a Letter', path: '/letters/new'),
              if (isAuth) ...[
                _SidebarLink(label: 'My Sent Mail', path: '/letters/mine'),
                _SidebarLink(label: 'My Claims', path: '/letters/claimed'),
              ],
            ],
          ),
          if (isAuth) ...[
            _SidebarSection(
              title: 'My Account',
              children: [
                if (user != null) _SidebarLink(label: 'Edit Profile', path: '/settings'),
                if (user != null) _SidebarLink(label: 'My Profile', path: '/profile/${user.username}'),
              ],
            ),
          ],
          _SidebarSection(
            title: 'What Is This?',
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
                child: Text(
                  'Write a heartfelt letter to a stranger. An artist will read it and paint an original piece of art for you.',
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 11,
                    color: RetroColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SidebarSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: RetroColors.sidebarHeader,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: RetroColors.white,
            ),
          ),
        ),
        ...children,
        Container(height: 1, color: RetroColors.border),
      ],
    );
  }
}

class _SidebarLink extends StatefulWidget {
  final String label;
  final String path;
  const _SidebarLink({required this.label, required this.path});

  @override
  State<_SidebarLink> createState() => _SidebarLinkState();
}

class _SidebarLinkState extends State<_SidebarLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.path),
        child: Container(
          color: _hovered ? const Color(0xFFD5E4F7) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              const Text(
                '› ',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: RetroColors.link,
                ),
              ),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 11,
                    color: RetroColors.link,
                    decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
                    decorationColor: RetroColors.link,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Footer (MySpace-style) ───────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF002277),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              _FooterLink('About Us'),
              const _FooterPipe(),
              _FooterLink('FAQ'),
              const _FooterPipe(),
              _FooterLink('Terms of Service'),
              const _FooterPipe(),
              _FooterLink('Privacy Policy'),
              const _FooterPipe(),
              _FooterLink('Safety Tips'),
              const _FooterPipe(),
              _FooterLink('Contact'),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '© 2004-2008 Dear Stranger. All Rights Reserved.',
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 10,
              color: Color(0xFF88AACC),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          const Text(
            'Best experienced with Internet Explorer 6.0 or Netscape Navigator 7.0 at 1024×768 resolution.',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 9,
              color: Color(0xFF6688AA),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FooterPipe extends StatelessWidget {
  const _FooterPipe();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 4),
    child: Text(
      '|',
      style: TextStyle(fontFamily: 'Arial', fontSize: 10, color: Color(0xFF5577AA)),
    ),
  );
}

class _FooterLink extends StatefulWidget {
  final String label;
  const _FooterLink(this.label);

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Text(
        widget.label,
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: 10,
          color: _hovered ? RetroColors.white : const Color(0xFFB0C8E8),
          decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
          decorationColor: RetroColors.white,
        ),
      ),
    );
  }
}
