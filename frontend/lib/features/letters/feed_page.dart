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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('✉ OPEN LETTERS', style: RetroTextStyles.h2),
              if (isAuth)
                RetroButton(label: 'WRITE A LETTER', onPressed: () => context.go('/letters/new'), isPrimary: true, isSmall: true),
            ],
          ),
          const SizedBox(height: 4),
          Text('Letters awaiting an artist. Pick one up and paint them a picture.',
              style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary, fontStyle: FontStyle.italic)),
          const RetroDivider(),
          if ((feed.loading || !feed.loadedOnce) && !feed.hasCachedLetters)
            const Padding(padding: EdgeInsets.all(40), child: RetroLoading(message: 'FETCHING LETTERS...'))
          else if (feed.error != null && !feed.hasCachedLetters)
            RetroError(feed.error!, onRetry: () => feed.refresh())
          else if (feed.letters.isEmpty)
            _EmptyFeed(isAuth: isAuth)
          else
            Column(
              children: [
                for (var i = 0; i < feed.letters.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _LetterCard(letter: feed.letters[i], isAuth: isAuth),
                ],
                if (feed.loadingMore) ...[
                  const SizedBox(height: 12),
                  const RetroLoading(message: 'LOADING MORE...'),
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
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Text('[ NO LETTERS ]', style: RetroTextStyles.h3.copyWith(color: RetroColors.textSecondary)),
          const SizedBox(height: 12),
          Text('No letters are waiting right now.\nBe the first to write one!',
              style: RetroTextStyles.body, textAlign: TextAlign.center),
          if (isAuth) ...[const SizedBox(height: 16), RetroButton(label: 'WRITE A LETTER', onPressed: () => context.go('/letters/new'))],
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
    return RetroCard(
      onTap: isAuth ? () => context.go('/letters/${letter.id}') : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(letter.title, style: RetroTextStyles.h3, overflow: TextOverflow.ellipsis, maxLines: 2),
              ),
              const SizedBox(width: 8),
              StatusBadge(letter.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            letter.message,
            style: RetroTextStyles.body,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('From: ', style: RetroTextStyles.label),
              Text(
                letter.isAnonymous ? 'Anonymous' : (letter.sender?.displayHandle ?? 'Unknown'),
                style: letter.isAnonymous
                    ? RetroTextStyles.small.copyWith(fontStyle: FontStyle.italic)
                    : RetroTextStyles.link,
              ),
              const Spacer(),
              Text(fmt.format(letter.createdAt), style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary)),
            ],
          ),
          if (isAuth) ...
            [
              const SizedBox(height: 12),
              const RetroDivider(),
              Builder(
                builder: (context) {
                  final me = context.select<AuthProvider, int?>((a) => a.user?.id);
                  final isMine = letter.isMine || (me != null && letter.sender?.id == me);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RetroButton(
                        label: isMine ? 'VIEW YOUR LETTER →' : 'VIEW & CLAIM →',
                        onPressed: () => context.go('/letters/${letter.id}'),
                        isSmall: true,
                      ),
                    ],
                  );
                },
              ),
            ],
        ],
      ),
    );
  }
}
