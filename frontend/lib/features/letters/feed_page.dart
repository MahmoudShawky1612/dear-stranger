import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/letter.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/feed_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/retro_widgets.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<LettersFeedProvider>().refresh(silent: true);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<LettersFeedProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = context.select<AuthProvider, bool>((a) => a.isAuthenticated);
    final feed   = context.watch<LettersFeedProvider>();

    return RetroScaffold(
      scrollController: _scrollCtrl,
      showSidebar: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF161F36), Color(0xFF0F1626)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF26334D), width: 1.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x336366F1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x666366F1), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, size: 12, color: Color(0xFF818CF8)),
                            const SizedBox(width: 6),
                            Text('AI-POWERED CREATIVE PLATFORM', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF818CF8), letterSpacing: 0.8)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('The Open Mail Board', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      Text('Browse open letters from strangers. Claim one to illustrate and return original art.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8), height: 1.4)),
                    ],
                  ),
                ),
                if (isAuth) ...[
                  const SizedBox(width: 16),
                  RetroButton(label: 'Write a Letter', onPressed: () => context.go('/letters/new'), isPrimary: true, icon: const Icon(Icons.edit_outlined, size: 14, color: Colors.white)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if ((feed.loading || !feed.loadedOnce) && !feed.hasCachedLetters)
            const RetroLoading(message: 'Gathering letters from the mailboard...')
          else if (feed.error != null && !feed.hasCachedLetters)
            RetroError(feed.error!, onRetry: () => feed.refresh())
          else if (feed.letters.isEmpty)
            _EmptyFeed(isAuth: isAuth)
          else
            Column(
              children: [
                for (var i = 0; i < feed.letters.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _ModernLetterCard(letter: feed.letters[i], isAuth: isAuth),
                ],
                if (feed.loadingMore) ...[
                  const SizedBox(height: 16),
                  const RetroLoading(message: 'Loading more letters...'),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  final bool isAuth;
  const _EmptyFeed({required this.isAuth});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFF111726), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1E293B), width: 1.2)),
      child: Center(
        child: Column(
          children: [
            Container(width: 50, height: 50, decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle), child: const Icon(Icons.mail_outline_rounded, color: Color(0xFF818CF8), size: 26)),
            const SizedBox(height: 12),
            Text('The Mail Board is Currently Quiet', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Be the first stranger to drop a letter for an artist to read and illustrate!', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)), textAlign: TextAlign.center),
            if (isAuth) ...[
              const SizedBox(height: 16),
              RetroButton(label: 'Write a Letter Now', onPressed: () => context.go('/letters/new'), isPrimary: true, icon: const Icon(Icons.edit, size: 14, color: Colors.white)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModernLetterCard extends StatefulWidget {
  final Letter letter;
  final bool isAuth;
  const _ModernLetterCard({required this.letter, required this.isAuth});

  @override
  State<_ModernLetterCard> createState() => _ModernLetterCardState();
}

class _ModernLetterCardState extends State<_ModernLetterCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM dd, yyyy');
    final me = context.select<AuthProvider, int?>((a) => a.user?.id);
    final isMine = widget.letter.isMine || (me != null && widget.letter.sender?.id == me);

    return MouseRegion(
      cursor: widget.isAuth ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.isAuth ? () => context.go('/letters/${widget.letter.id}') : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF141C2E) : const Color(0xFF111726),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _hovered ? const Color(0xFF6366F1) : const Color(0xFF1E293B), width: 1.2),
            boxShadow: [
              BoxShadow(color: _hovered ? const Color(0xFF6366F1).withOpacity(0.15) : Colors.black.withOpacity(0.2), blurRadius: _hovered ? 16 : 8, offset: const Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.letter.title,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: _hovered ? const Color(0xFF818CF8) : Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(widget.letter.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 13, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(widget.letter.isAnonymous ? 'Anonymous Stranger' : (widget.letter.sender?.displayHandle ?? 'Unknown'), style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
                  const Spacer(),
                  const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(fmt.format(widget.letter.createdAt), style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E293B), width: 1),
                ),
                child: Text(
                  widget.letter.message,
                  style: GoogleFonts.ibmPlexMono(fontSize: 12, height: 1.5, color: const Color(0xFFCBD5E1)),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isAuth) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RetroButton(label: isMine ? 'View Your Letter →' : 'Read & Illustrate →', onPressed: () => context.go('/letters/${widget.letter.id}'), isPrimary: !isMine, isSmall: true),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
