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
            children: [
              Expanded(
                child: Container(
                  color: RetroColors.sectionHeader,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text('■ 📬 MY SENT MAIL', style: RetroTextStyles.sectionTitle),
                ),
              ),
              const SizedBox(width: 8),
              RetroButton(
                label: '+ DROP A LETTER',
                onPressed: () => context.go('/letters/new'),
                isPrimary: true,
                isSmall: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const RetroLoading(message: 'LOADING YOUR MAIL')
          else if (_error != null)
            RetroError(_error!, onRetry: _load)
          else if (_letters.isEmpty)
            RetroCard(
              title: 'NO SENT LETTERS',
              titleBarColor: RetroColors.sectionHeaderRed,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    "You haven't dropped any letters yet.",
                    style: RetroTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  RetroButton(
                    label: '✉ DROP YOUR FIRST LETTER',
                    onPressed: () => context.go('/letters/new'),
                    isPrimary: true,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _letters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 0),
              itemBuilder: (_, i) {
                final letter = _letters[i];
                return _SentLetterRow(
                  letter: letter,
                  index: i,
                  onTap: () => context.go('/letters/${letter.id}'),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SentLetterRow extends StatefulWidget {
  final Letter letter;
  final int index;
  final VoidCallback onTap;
  const _SentLetterRow({required this.letter, required this.index, required this.onTap});

  @override
  State<_SentLetterRow> createState() => _SentLetterRowState();
}

class _SentLetterRowState extends State<_SentLetterRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    final isEven = widget.index.isEven;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _hovered
                ? const Color(0xFFDDEEFF)
                : (isEven ? RetroColors.surface : const Color(0xFFF5F5F8)),
            border: const Border(
              bottom: BorderSide(color: RetroColors.border, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status icon
              SizedBox(
                width: 20,
                child: Text(
                  widget.letter.isDelivered ? '★' : widget.letter.isClaimed ? '►' : '✉',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.letter.isDelivered
                        ? RetroColors.accentGreen
                        : widget.letter.isClaimed
                            ? RetroColors.sectionHeader
                            : RetroColors.accentOrange,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Title
              Expanded(
                flex: 3,
                child: Text(
                  widget.letter.title,
                  style: RetroTextStyles.vt323.copyWith(
                    fontSize: 18,
                    color: _hovered ? RetroColors.link : RetroColors.textPrimary,
                    decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
                    decorationColor: RetroColors.link,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Artist
              Expanded(
                flex: 2,
                child: Text(
                  widget.letter.artist != null
                      ? 'Artist: ${widget.letter.artist!.displayHandle}'
                      : 'Awaiting an artist...',
                  style: RetroTextStyles.small.copyWith(
                    color: RetroColors.textSecondary,
                    fontStyle: widget.letter.artist == null ? FontStyle.italic : FontStyle.normal,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Date
              Text(
                fmt.format(widget.letter.createdAt),
                style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary, fontSize: 10),
              ),
              const SizedBox(width: 8),
              StatusBadge(widget.letter.status),
            ],
          ),
        ),
      ),
    );
  }
}
