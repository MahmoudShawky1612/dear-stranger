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
          // Page title bar
          Row(
            children: [
              Expanded(
                child: Container(
                  color: RetroColors.sectionHeader,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    '■ THE MAILBOARD',
                    style: RetroTextStyles.sectionTitle,
                  ),
                ),
              ),
              if (isAuth)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: RetroButton(
                    label: '✉ DROP A LETTER',
                    onPressed: () => context.go('/letters/new'),
                    isPrimary: true,
                    isSmall: true,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              'Letters awaiting an artist. Pick one up and paint them a picture.',
              style: RetroTextStyles.small.copyWith(
                color: RetroColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const RetroDivider(),

          // Content
          if ((feed.loading || !feed.loadedOnce) && !feed.hasCachedLetters)
            const RetroLoading(message: 'LOADING THE MAILBOARD')
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
                  const RetroLoading(message: 'LOADING MORE'),
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
      title: 'NO LETTERS YET',
      titleBarColor: RetroColors.sectionHeaderRed,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'The mailboard is empty.\nBe the first to drop a letter!',
            style: RetroTextStyles.body,
            textAlign: TextAlign.center,
          ),
          if (isAuth) ...[
            const SizedBox(height: 16),
            RetroButton(
              label: '✉ DROP A LETTER',
              onPressed: () => context.go('/letters/new'),
              isPrimary: true,
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
    final fmt = DateFormat('dd MMM yyyy');
    final me = context.select<AuthProvider, int?>((a) => a.user?.id);
    final isMine = letter.isMine || (me != null && letter.sender?.id == me);

    return RetroCard(
      onTap: isAuth ? () => context.go('/letters/${letter.id}') : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  letter.title,
                  style: RetroTextStyles.vt323.copyWith(
                    fontSize: 20,
                    color: RetroColors.link,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(letter.status),
            ],
          ),
          const SizedBox(height: 4),

          // Sender + date meta row
          Row(
            children: [
              Text('From: ', style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary)),
              Text(
                letter.isAnonymous ? 'Anonymous' : (letter.sender?.displayHandle ?? 'Unknown'),
                style: letter.isAnonymous
                    ? RetroTextStyles.small.copyWith(fontStyle: FontStyle.italic, color: RetroColors.textSecondary)
                    : RetroTextStyles.small.copyWith(color: RetroColors.link, decoration: TextDecoration.underline, decorationColor: RetroColors.link),
              ),
              const Spacer(),
              Text(
                fmt.format(letter.createdAt),
                style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Letter preview
          Container(
            width: double.infinity,
            color: const Color(0xFFF9F9F9),
            padding: const EdgeInsets.all(8),
            child: Text(
              letter.message,
              style: RetroTextStyles.typewriter.copyWith(fontSize: 13, color: RetroColors.textPrimary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          if (isAuth) ...[
            const SizedBox(height: 8),
            const RetroDivider(),
            Align(
              alignment: Alignment.centerRight,
              child: RetroButton(
                label: isMine ? '» VIEW YOUR LETTER' : '» READ & CLAIM',
                onPressed: () => context.go('/letters/${letter.id}'),
                isPrimary: !isMine,
                isSmall: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
