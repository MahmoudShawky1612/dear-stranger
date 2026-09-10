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
          // Section Title Strip
          Container(
            color: RetroColors.sectionHeader,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                PixelIcon.mail(size: 15),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'My Sent Mail — Letters You Have Posted',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: RetroColors.white,
                    ),
                  ),
                ),
                RetroButton(
                  label: 'Write New Letter >>',
                  onPressed: () => context.go('/letters/new'),
                  isPrimary: true,
                  isSmall: true,
                  icon: PixelIcon.write(size: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          if (_loading)
            const RetroLoading(message: 'Loading your sent mail')
          else if (_error != null)
            RetroError(_error!, onRetry: _load)
          else if (_letters.isEmpty)
            RetroCard(
              title: 'No Sent Letters',
              titleBarColor: RetroColors.sectionHeader,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    "You haven't posted any letters yet.\nDrop a letter on the mailboard and an artist will illustrate it for you!",
                    style: TextStyle(fontFamily: 'Arial', fontSize: 12, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  RetroButton(
                    label: 'Write Your First Letter >>',
                    onPressed: () => context.go('/letters/new'),
                    isPrimary: true,
                    icon: PixelIcon.write(size: 13),
                  ),
                ],
              ),
            )
          else ...[
            // Classic Table Header
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFD5E4F7),
                border: Border(
                  top: BorderSide(color: RetroColors.border, width: 1),
                  left: BorderSide(color: RetroColors.border, width: 1),
                  right: BorderSide(color: RetroColors.border, width: 1),
                  bottom: BorderSide(color: Color(0xFF88A8D0), width: 2),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: const Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      'STATUS',
                      style: TextStyle(fontFamily: 'Arial', fontSize: 10, fontWeight: FontWeight.bold, color: RetroColors.headerBg),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'LETTER TITLE',
                      style: TextStyle(fontFamily: 'Arial', fontSize: 10, fontWeight: FontWeight.bold, color: RetroColors.headerBg),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'ARTIST',
                      style: TextStyle(fontFamily: 'Arial', fontSize: 10, fontWeight: FontWeight.bold, color: RetroColors.headerBg),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'DATE',
                      style: TextStyle(fontFamily: 'Arial', fontSize: 10, fontWeight: FontWeight.bold, color: RetroColors.headerBg),
                    ),
                  ),
                ],
              ),
            ),
            // Table Rows
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: RetroColors.border, width: 1),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _letters.length,
                itemBuilder: (_, i) {
                  final letter = _letters[i];
                  return _SentLetterRow(
                    letter: letter,
                    index: i,
                    onTap: () => context.go('/letters/${letter.id}'),
                  );
                },
              ),
            ),
          ],
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
    final fmt = DateFormat('MMM dd, yyyy');
    final isEven = widget.index.isEven;
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
                ? const Color(0xFFDDEEFF)
                : (isEven ? RetroColors.tableRow : RetroColors.tableRowAlt),
            border: const Border(
              bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status Badge with icon
              SizedBox(
                width: 90,
                child: Row(
                  children: [
                    if (l.isDelivered)
                      PixelIcon.star(size: 11)
                    else if (l.isClaimed)
                      PixelIcon.palette(size: 11)
                    else
                      PixelIcon.mail(size: 11),
                    const SizedBox(width: 4),
                    StatusBadge(l.status),
                  ],
                ),
              ),
              // Title
              Expanded(
                flex: 3,
                child: Text(
                  l.title,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: RetroColors.link,
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
                child: Row(
                  children: [
                    PixelIcon.userIcon(size: 11, color: RetroColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        l.artist != null
                            ? l.artist!.displayHandle
                            : 'Awaiting an artist...',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 11,
                          color: l.artist != null ? RetroColors.textPrimary : RetroColors.textMuted,
                          fontStyle: l.artist == null ? FontStyle.italic : FontStyle.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Date
              SizedBox(
                width: 80,
                child: Text(
                  fmt.format(l.createdAt),
                  style: const TextStyle(fontFamily: 'Arial', fontSize: 10, color: RetroColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
