import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final feed = context.watch<LettersFeedProvider>();

    return RetroScaffold(
      scrollController: _scrollCtrl,
      showSidebar: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Bar (MySpace style)
          Container(
            color: RetroColors.sectionHeader,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                PixelIcon.mail(size: 15),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'The Mail Board — Recent Letters Awaiting Artists',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: RetroColors.white,
                    ),
                  ),
                ),
                if (isAuth)
                  RetroButton(
                    label: 'Write a Letter >>',
                    onPressed: () => context.go('/letters/new'),
                    isPrimary: true,
                    isSmall: true,
                    icon: PixelIcon.write(size: 12),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Browse open letters from strangers. Claim one to illustrate and return original art.',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 11,
              color: RetroColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const RetroDivider(),

          // Feed Letters
          if ((feed.loading || !feed.loadedOnce) && !feed.hasCachedLetters)
            const RetroLoading(message: 'Loading letters from the mailboard')
          else if (feed.error != null && !feed.hasCachedLetters)
            RetroError(feed.error!, onRetry: () => feed.refresh())
          else if (feed.letters.isEmpty)
            _EmptyFeed(isAuth: isAuth)
          else
            Column(
              children: [
                for (var i = 0; i < feed.letters.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _LetterCard(letter: feed.letters[i], isAuth: isAuth),
                ],
                if (feed.loadingMore) ...[
                  const SizedBox(height: 12),
                  const RetroLoading(message: 'Loading more letters'),
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
    return RetroCard(
      title: 'No Letters on the Board',
      titleBarColor: RetroColors.sectionHeader,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'The mailboard is currently empty.\nBe the first to drop a letter for an artist to read!',
            style: TextStyle(fontFamily: 'Arial', fontSize: 12, height: 1.5),
            textAlign: TextAlign.center,
          ),
          if (isAuth) ...[
            const SizedBox(height: 16),
            RetroButton(
              label: 'Write a Letter Now >>',
              onPressed: () => context.go('/letters/new'),
              isPrimary: true,
              icon: PixelIcon.write(size: 14),
            ),
          ],
        ],
      ),
    );
  }
}

class _LetterCard extends StatelessWidget {
  final Letter letter;
  final bool isAuth;
  const _LetterCard({required this.letter, required this.isAuth});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM dd, yyyy');
    final me = context.select<AuthProvider, int?>((a) => a.user?.id);
    final isMine = letter.isMine || (me != null && letter.sender?.id == me);

    return GestureDetector(
      onTap: isAuth ? () => context.go('/letters/${letter.id}') : null,
      child: MouseRegion(
        cursor: isAuth ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Container(
          decoration: BoxDecoration(
            color: RetroColors.surface,
            border: Border.all(color: RetroColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Blue Top Strip with Title
              Container(
                color: const Color(0xFFE8EFF9), // Soft blue title bar
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    PixelIcon.doc(size: 13),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        letter.title,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: RetroColors.link,
                          decoration: TextDecoration.underline,
                          decorationColor: RetroColors.link,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(letter.status),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender + Date row
                    Row(
                      children: [
                        PixelIcon.userIcon(size: 11, color: RetroColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Posted by: ',
                          style: TextStyle(fontFamily: 'Arial', fontSize: 11, color: RetroColors.textSecondary),
                        ),
                        Text(
                          letter.isAnonymous ? 'Anonymous Stranger' : (letter.sender?.displayHandle ?? 'Unknown'),
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: letter.isAnonymous ? RetroColors.textSecondary : RetroColors.link,
                          ),
                        ),
                        const Spacer(),
                        PixelIcon.calendar(size: 11),
                        const SizedBox(width: 4),
                        Text(
                          fmt.format(letter.createdAt),
                          style: TextStyle(fontFamily: 'Arial', fontSize: 10, color: RetroColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Letter Preview in Courier typewriter box
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        letter.message,
                        style: RetroTextStyles.typewriter.copyWith(fontSize: 12, height: 1.45),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    if (isAuth) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: RetroButton(
                          label: isMine ? 'View Your Letter >>' : 'Read & Claim Letter >>',
                          onPressed: () => context.go('/letters/${letter.id}'),
                          isPrimary: !isMine,
                          isSmall: true,
                          icon: isMine ? PixelIcon.mail(size: 12) : PixelIcon.palette(size: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
