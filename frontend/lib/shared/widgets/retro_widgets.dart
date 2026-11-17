library retro_widgets;

export 'pixel_icons.dart';
export 'retro_buttons.dart';
export 'retro_cards.dart';
export 'retro_inputs.dart';
export 'retro_footer.dart';
export 'retro_sidebar.dart';
export 'retro_cassette_player.dart';
export 'muse_dialog.dart';
export 'scribe_toolbar.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import 'pixel_icons.dart';
import 'retro_sidebar.dart';
import 'retro_footer.dart';
import 'retro_buttons.dart';

class RetroScaffold extends StatelessWidget {
  final Widget body;
  final bool showSidebar;
  final ScrollController? scrollController;

  const RetroScaffold({super.key, required this.body, this.showSidebar = true, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D121F),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30, offset: const Offset(0, 10)),
                BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.08), blurRadius: 40, offset: const Offset(0, 0)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SiteHeader(),
                const _NavBar(),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showSidebar) const RetroSidebar(),
                      Expanded(
                        child: Container(
                          color: const Color(0xFF090D16),
                          padding: const EdgeInsets.all(20),
                          child: body,
                        ),
                      ),
                    ],
                  ),
                ),
                const RetroFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SiteHeader extends StatelessWidget {
  const _SiteHeader();

  @override
  Widget build(BuildContext context) {
    final isAuth = context.select<AuthProvider, bool>((a) => a.isAuthenticated);
    final user   = context.select<AuthProvider, dynamic>((a) => a.user);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E1424),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFFEC4899)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 2))],
                    ),
                    child: const Center(child: Icon(Icons.mail_outline_rounded, color: Colors.white, size: 20)),
                  ),
                  const SizedBox(width: 12),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFCBD5E1)]).createShader(bounds),
                    child: Text('Dear Stranger', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('AI STUDIO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.6)),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (isAuth && user != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF161E31),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF26334D), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFEC4899)])),
                    child: Center(child: Text((user.displayName ?? user.username)[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 8),
                  Text(user.displayName ?? user.username, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ] else ...[
            RetroButton(
              label: 'Sign In / Register',
              isPrimary: true,
              isSmall: true,
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.login, size: 14, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    final isAuth = context.select<AuthProvider, bool>((a) => a.isAuthenticated);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111726),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        children: [
          _navItem(context, 'Mail Board', '/'),
          _navItem(context, 'Write Letter', '/letters/new'),
          _navItem(context, 'Member Search', '/search'),
          if (isAuth) ...[
            _navItem(context, 'My Letters', '/letters/mine'),
            _navItem(context, 'My Claims', '/letters/claimed'),
          ],
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, String title, String path) {
    return GestureDetector(
      onTap: () => context.go(path),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
        ),
      ),
    );
  }

