import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RetroFooter extends StatelessWidget {
  const RetroFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF002277),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [
          const Wrap(
            alignment: WrapAlignment.center,
            children: [
              _FooterLink('About Us'),
              _FooterPipe(),
              _FooterLink('FAQ'),
              _FooterPipe(),
              _FooterLink('The Muse AI'),
              _FooterPipe(),
              _FooterLink('Terms of Service'),
              _FooterPipe(),
              _FooterLink('Privacy'),
              _FooterPipe(),
              _FooterLink('Contact'),
            ],
          ),
          const SizedBox(height: 5),
          const Text('© 2004-2008 Dear Stranger. All Rights Reserved.', style: TextStyle(fontFamily: 'Arial', fontSize: 10, color: Color(0xFF88AACC)), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          const Text('Crafted with AI Agents & Human Creativity.', style: TextStyle(fontFamily: 'Arial', fontSize: 9, color: Color(0xFF6688AA), fontStyle: FontStyle.italic), textAlign: TextAlign.center),
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
    child: Text('|', style: TextStyle(fontFamily: 'Arial', fontSize: 10, color: Color(0xFF5577AA))),
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
        style: TextStyle(fontFamily: 'Arial', fontSize: 10, color: _hovered ? Colors.white : const Color(0xFFB0C8E8), decoration: _hovered ? TextDecoration.underline : TextDecoration.none),
      ),
    );
  }
}
