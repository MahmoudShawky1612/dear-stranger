import 'package:flutter/material.dart';

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

    final pStroke = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0;
    final pFill = Paint()..style = PaintingStyle.fill;

    switch (type) {
      case PixelIconType.envelope:
        pFill.color = const Color(0xFFFFFEE0);
        canvas.drawRect(const Rect.fromLTWH(1, 3, 14, 10), pFill);
        pStroke.color = const Color(0xFF003366);
        canvas.drawRect(const Rect.fromLTWH(1, 3, 14, 10), pStroke);
        final flap = Path()..moveTo(1, 3)..lineTo(8, 9)..lineTo(15, 3);
        canvas.drawPath(flap, pStroke);
        break;
      case PixelIconType.pencil:
        pFill.color = const Color(0xFFFFCC00);
        canvas.drawRect(const Rect.fromLTWH(4, 5, 8, 7), pFill);
        pFill.color = const Color(0xFFFF9999);
        canvas.drawRect(const Rect.fromLTWH(10, 2, 4, 4), pFill);
        pFill.color = const Color(0xFF333333);
        final tip = Path()..moveTo(2, 14)..lineTo(5, 11)..lineTo(2, 11)..close();
        canvas.drawPath(tip, pFill);
        pStroke.color = const Color(0xFF553300);
        canvas.drawRect(const Rect.fromLTWH(4, 5, 8, 7), pStroke);
        break;
      case PixelIconType.palette:
        pFill.color = const Color(0xFFE5C178);
        canvas.drawOval(const Rect.fromLTWH(1, 1, 14, 13), pFill);
        pStroke.color = const Color(0xFF664411);
        canvas.drawOval(const Rect.fromLTWH(1, 1, 14, 13), pStroke);
        pFill.color = const Color(0xFFCC0000); canvas.drawCircle(const Offset(5, 4), 1.5, pFill);
        pFill.color = const Color(0xFF008800); canvas.drawCircle(const Offset(10, 4), 1.5, pFill);
        pFill.color = const Color(0xFF0033CC); canvas.drawCircle(const Offset(11, 8), 1.5, pFill);
        break;
      case PixelIconType.user:
        pFill.color = customColor ?? const Color(0xFF003399);
        canvas.drawCircle(const Offset(8, 4.5), 3.0, pFill);
        final shoulders = Path()..moveTo(2, 14)..quadraticBezierTo(4, 9, 8, 9)..quadraticBezierTo(12, 9, 14, 14)..close();
        canvas.drawPath(shoulders, pFill);
        break;
      case PixelIconType.bubble:
        pFill.color = const Color(0xFFFFFFFF);
        final bubble = Path()..addRect(const Rect.fromLTWH(1, 2, 14, 9))..moveTo(3, 11)..lineTo(3, 14)..lineTo(7, 11)..close();
        canvas.drawPath(bubble, pFill);
        pStroke.color = const Color(0xFF003399);
        canvas.drawPath(bubble, pStroke);
        break;
      case PixelIconType.document:
        pFill.color = const Color(0xFFFFFFFF);
        final page = Path()..moveTo(2, 1)..lineTo(10, 1)..lineTo(14, 5)..lineTo(14, 15)..lineTo(2, 15)..close();
        canvas.drawPath(page, pFill);
        pStroke.color = const Color(0xFF003399);
        canvas.drawPath(page, pStroke);
        break;
      case PixelIconType.pin:
        pFill.color = const Color(0xFFCC0000);
        canvas.drawCircle(const Offset(8, 5), 4.0, pFill);
        pStroke.color = const Color(0xFF888888);
        canvas.drawLine(const Offset(8, 9), const Offset(8, 15), pStroke);
        break;
      case PixelIconType.calendar:
        pFill.color = const Color(0xFFCC0000);
        canvas.drawRect(const Rect.fromLTWH(2, 2, 12, 4), pFill);
        pFill.color = const Color(0xFFFFFFFF);
        canvas.drawRect(const Rect.fromLTWH(2, 6, 12, 8), pFill);
        pStroke.color = const Color(0xFF444444);
        canvas.drawRect(const Rect.fromLTWH(2, 2, 12, 12), pStroke);
        break;
      case PixelIconType.star:
        pFill.color = const Color(0xFFFFCC00);
        pStroke.color = const Color(0xFF996600);
        final star = Path()..moveTo(8, 1)..lineTo(10, 6)..lineTo(15, 6)..lineTo(11, 9.5)..lineTo(12.5, 14.5)..lineTo(8, 11.5)..lineTo(3.5, 14.5)..lineTo(5, 9.5)..lineTo(1, 6)..lineTo(6, 6)..close();
        canvas.drawPath(star, pFill);
        canvas.drawPath(star, pStroke);
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PixelIconPainter oldDelegate) => oldDelegate.type != type || oldDelegate.customColor != customColor;
}
