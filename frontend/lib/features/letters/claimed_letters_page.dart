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
            children: [
              Expanded(
                child: Container(
                  color: RetroColors.sectionHeaderPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text('■ 🎨 MY CLAIMS', style: RetroTextStyles.sectionTitle),
                ),
              ),
              const SizedBox(width: 8),
              RetroButton(
                label: '» BROWSE MAILBOARD',
                onPressed: () => context.go('/'),
                isSmall: true,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Letters you have picked up to illustrate.',
            style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary, fontStyle: FontStyle.italic),
          ),
          const RetroDivider(),
          if (_loading)
            const RetroLoading(message: 'LOADING YOUR CLAIMS')
          else if (_error != null)
            RetroError(_error!, onRetry: _load)
          else if (_letters.isEmpty)
            RetroCard(
              title: 'NO CLAIMS YET',
              titleBarColor: RetroColors.sectionHeader,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    "You haven't claimed any letters to illustrate yet.",
                    style: RetroTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  RetroButton(
                    label: '» BROWSE THE MAILBOARD',
                    onPressed: () => context.go('/'),
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
                final l = _letters[i];
                final fmt = DateFormat('dd MMM yyyy');
                final isEven = i.isEven;
                return _ClaimedRow(
                  letter: l,
                  isEven: isEven,
                  fmt: fmt,
                  onTap: () => context.go('/letters/${l.id}'),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ClaimedRow extends StatefulWidget {
  final Letter letter;
  final bool isEven;
  final DateFormat fmt;
  final VoidCallback onTap;
  const _ClaimedRow({required this.letter, required this.isEven, required this.fmt, required this.onTap});

  @override
  State<_ClaimedRow> createState() => _ClaimedRowState();
}

class _ClaimedRowState extends State<_ClaimedRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l = widget.letter;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _hovered
                ? const Color(0xFFEEDDFF)
                : (widget.isEven ? RetroColors.surface : const Color(0xFFF8F5FF)),
            border: const Border(bottom: BorderSide(color: RetroColors.border, width: 1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  l.isDelivered ? '★' : '🎨',
                  style: TextStyle(
                    fontSize: 14,
                    color: l.isDelivered ? RetroColors.accentGreen : RetroColors.sectionHeaderPurple,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.title,
                      style: RetroTextStyles.vt323.copyWith(
                        fontSize: 18,
                        color: _hovered ? RetroColors.linkVisited : RetroColors.textPrimary,
                        decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
                        decorationColor: RetroColors.linkVisited,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'From: ${l.isAnonymous ? 'Anonymous' : (l.sender?.displayHandle ?? '?')}',
                      style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.fmt.format(l.createdAt),
                style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary, fontSize: 10),
              ),
              const SizedBox(width: 8),
              StatusBadge(l.status),
              const SizedBox(width: 8),
              RetroButton(
                label: l.isDelivered ? '» VIEW' : '» ATTACH ART',
                onPressed: widget.onTap,
                isPrimary: !l.isDelivered,
                isSmall: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
