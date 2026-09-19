import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import 'retro_cassette_player.dart';

class RetroSidebar extends StatelessWidget {
  const RetroSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuth = context.select<AuthProvider, bool>((a) => a.isAuthenticated);
    final user   = context.select<AuthProvider, dynamic>((a) => a.user);

    return Container(
      width: 200,
      constraints: const BoxConstraints(minHeight: 500),
      decoration: const BoxDecoration(
        color: Color(0xFF0D121F),
        border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1.2)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SidebarSection(
            title: 'EXPLORE & DISCOVER',
            icon: Icons.explore_outlined,
            children: [
              _SidebarLink(label: 'Mail Board', path: '/', icon: Icons.mail_outline),
              _SidebarLink(label: 'Find Members', path: '/search', icon: Icons.search),
              _SidebarLink(label: 'Write Letter', path: '/letters/new', icon: Icons.edit_outlined),
              if (isAuth) ...[
                _SidebarLink(label: 'My Sent Mail', path: '/letters/mine', icon: Icons.outbox_outlined),
                _SidebarLink(label: 'My Claims', path: '/letters/claimed', icon: Icons.brush_outlined),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (isAuth && user != null) ...[
            _SidebarSection(
              title: 'CREATOR SPACE',
              icon: Icons.person_outline,
              children: [
                _SidebarLink(label: 'My Profile', path: '/profile/${user.username}', icon: Icons.account_circle_outlined),
                _SidebarLink(label: 'Settings', path: '/settings', icon: Icons.settings_outlined),
              ],
            ),
            const SizedBox(height: 16),
          ],
          const RetroCassettePlayer(),
        ],
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;
  const _SidebarSection({required this.title, this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: const Color(0xFF6366F1)),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ...children,
      ],
    );
  }
}

class _SidebarLink extends StatefulWidget {
  final String label;
  final String path;
  final IconData? icon;
  const _SidebarLink({required this.label, required this.path, this.icon});

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF1E293B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? const Color(0x336366F1) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 14, color: _hovered ? const Color(0xFF818CF8) : const Color(0xFF94A3B8)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  widget.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: _hovered ? FontWeight.w700 : FontWeight.w500,
                    color: _hovered ? Colors.white : const Color(0xFFCBD5E1),
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
