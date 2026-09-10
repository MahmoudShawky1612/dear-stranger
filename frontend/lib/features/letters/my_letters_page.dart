import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/api/letters_api.dart';
import '../../core/models/letter.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/retro_widgets.dart';

class MyLettersPage extends StatefulWidget {
  const MyLettersPage({super.key});

  @override
  State<MyLettersPage> createState() => _MyLettersPageState();
}

class _MyLettersPageState extends State<MyLettersPage> {
  final _api = LettersApi();
  List<Letter> _letters = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final letters = await _api.getMySent();
      if (!mounted) return;
      setState(() { _letters = letters; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RetroScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('✉ MY SENT LETTERS', style: RetroTextStyles.h2),
              RetroButton(label: '+ WRITE NEW', onPressed: () => context.go('/letters/new'), isSmall: true),
            ],
          ),
          const RetroDivider(),
          if (_loading)
            const RetroLoading(message: 'LOADING...')
          else if (_error != null)
            RetroError(_error!, onRetry: _load)
          else if (_letters.isEmpty)
            RetroCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text('[ NO LETTERS YET ]', style: RetroTextStyles.h3.copyWith(color: RetroColors.textSecondary)),
                  const SizedBox(height: 12),
                  Text("You haven't written any letters yet.", style: RetroTextStyles.body, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  RetroButton(label: 'WRITE YOUR FIRST LETTER', onPressed: () => context.go('/letters/new'), isPrimary: true),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _letters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _SentLetterRow(
                letter: _letters[i],
                onTap: () => context.go('/letters/${_letters[i].id}'),
              ),
            ),
        ],
      ),
    );
  }
}

class _SentLetterRow extends StatelessWidget {
  final Letter letter;
  final VoidCallback onTap;
  const _SentLetterRow({required this.letter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    return RetroCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(letter.title, style: RetroTextStyles.h3),
                const SizedBox(height: 4),
                if (letter.artist != null)
                  Text('Artist: ${letter.artist!.displayHandle}', style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary))
                else
                  Text('Waiting for an artist...', style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary, fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text(fmt.format(letter.createdAt), style: RetroTextStyles.small.copyWith(color: RetroColors.border)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(letter.status),
              if (letter.replyCount != null && letter.replyCount! > 0) ...
                [
                  const SizedBox(height: 4),
                  Text('${letter.replyCount} replies', style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary)),
                ],
            ],
          ),
        ],
      ),
    );
  }
}
