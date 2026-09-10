import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/api/letters_api.dart';
import '../../core/models/letter.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/retro_widgets.dart';

class ClaimedLettersPage extends StatefulWidget {
  const ClaimedLettersPage({super.key});

  @override
  State<ClaimedLettersPage> createState() => _ClaimedLettersPageState();
}

class _ClaimedLettersPageState extends State<ClaimedLettersPage> {
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
      final letters = await _api.getMyClaimed();
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
              Text('🎨 MY CLAIMED LETTERS', style: RetroTextStyles.h2),
              RetroButton(label: 'BROWSE MORE', onPressed: () => context.go('/'), isSmall: true),
            ],
          ),
          Text('Letters you have claimed to illustrate.', style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary, fontStyle: FontStyle.italic)),
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
                  Text('[  NO CLAIMED LETTERS ]', style: RetroTextStyles.h3.copyWith(color: RetroColors.textSecondary)),
                  const SizedBox(height: 12),
                  Text("You haven't claimed any letters to illustrate yet.", style: RetroTextStyles.body, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  RetroButton(label: 'BROWSE LETTERS', onPressed: () => context.go('/'), isPrimary: true),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _letters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final l = _letters[i];
                return RetroCard(
                  onTap: () => context.go('/letters/${l.id}'),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.title, style: RetroTextStyles.h3),
                            const SizedBox(height: 4),
                            Text('From: ${l.isAnonymous ? 'Anonymous' : (l.sender?.displayHandle ?? '?')}',
                                style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary)),
                            Text(DateFormat('dd MMM yyyy').format(l.createdAt),
                                style: RetroTextStyles.small.copyWith(color: RetroColors.border)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusBadge(l.status),
                          const SizedBox(height: 8),
                          RetroButton(label: l.isDelivered ? 'VIEW →' : 'UPLOAD ART →', onPressed: () => context.go('/letters/${l.id}'), isSmall: true),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
