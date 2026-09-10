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
          // Section Title Strip
          Container(
            color: RetroColors.sectionHeader,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                PixelIcon.palette(size: 15),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'My Claims — Letters You Are Illustrating',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: RetroColors.white,
                    ),
                  ),
                ),
                RetroButton(
                  label: 'Browse Mailboard >>',
                  onPressed: () => context.go('/'),
                  isSmall: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Letters you have picked up to illustrate. Upload artwork to deliver your response.',
            style: TextStyle(fontFamily: 'Arial', fontSize: 11, color: RetroColors.textSecondary, fontStyle: FontStyle.italic),
          ),
          const RetroDivider(),

          if (_loading)
            const RetroLoading(message: 'Loading your claimed letters')
          else if (_error != null)
            RetroError(_error!, onRetry: _load)
          else if (_letters.isEmpty)
            RetroCard(
              title: 'No Active Claims',
              titleBarColor: RetroColors.sectionHeader,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    "You haven't claimed any letters to illustrate yet.\nVisit the mailboard to pick up a letter and start painting!",
                    style: TextStyle(fontFamily: 'Arial', fontSize: 12, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  RetroButton(
                    label: 'Browse the Mailboard >>',
                    onPressed: () => context.go('/'),
                    isPrimary: true,
                    icon: PixelIcon.mail(size: 13),
                  ),
                ],
              ),
            )
          else ...[
            // Table Header
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
                      'AUTHOR',
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
                  SizedBox(
                    width: 100,
                    child: Text(
                      'ACTION',
                      style: TextStyle(fontFamily: 'Arial', fontSize: 10, fontWeight: FontWeight.bold, color: RetroColors.headerBg),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            // Table List
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: RetroColors.border, width: 1),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _letters.length,
                itemBuilder: (_, i) {
                  final l = _letters[i];
                  return _ClaimedRow(
                    letter: l,
                    isEven: i.isEven,
                    onTap: () => context.go('/letters/${l.id}'),
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

class _ClaimedRow extends StatefulWidget {
  final Letter letter;
  final bool isEven;
  final VoidCallback onTap;
  const _ClaimedRow({required this.letter, required this.isEven, required this.onTap});

  @override
  State<_ClaimedRow> createState() => _ClaimedRowState();
}

class _ClaimedRowState extends State<_ClaimedRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM dd, yyyy');
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
                : (widget.isEven ? RetroColors.tableRow : RetroColors.tableRowAlt),
            border: const Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Row(
                  children: [
                    l.isDelivered ? PixelIcon.star(size: 11) : PixelIcon.palette(size: 11),
                    const SizedBox(width: 4),
                    StatusBadge(l.status),
                  ],
                ),
              ),
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
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    PixelIcon.userIcon(size: 11, color: RetroColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        l.isAnonymous ? 'Anonymous' : (l.sender?.displayHandle ?? 'Unknown'),
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 11,
                          color: l.isAnonymous ? RetroColors.textMuted : RetroColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: Text(
                  fmt.format(l.createdAt),
                  style: const TextStyle(fontFamily: 'Arial', fontSize: 10, color: RetroColors.textSecondary),
                ),
              ),
              SizedBox(
                width: 100,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: RetroButton(
                    label: l.isDelivered ? 'View Art >>' : 'Attach Art >>',
                    onPressed: widget.onTap,
                    isPrimary: !l.isDelivered,
                    isSmall: true,
                    icon: l.isDelivered ? PixelIcon.star(size: 10) : PixelIcon.palette(size: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
