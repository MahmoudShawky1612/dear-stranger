import 'package:flutter/material.dart';
import '../../core/models/muse_inspiration.dart';
import '../../core/theme/app_theme.dart';
import 'retro_widgets.dart';

class MuseInspirationDialog extends StatelessWidget {
  final MuseInspiration inspiration;
  const MuseInspirationDialog({super.key, required this.inspiration});

  static void show(BuildContext context, MuseInspiration inspiration) {
    showDialog(
      context: context,
      builder: (_) => MuseInspirationDialog(inspiration: inspiration),
    );
  }

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return Colors.brown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(color: const Color(0xFF003399), width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black45, offset: Offset(4, 4), blurRadius: 0),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: const Color(0xFF003399),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                children: [
                  PixelIcon.palette(size: 14),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'THE MUSE — Creative Inspiration Studio',
                      style: TextStyle(fontFamily: 'Arial', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      color: const Color(0xFFCC0000),
                      child: const Text('✕', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('EMOTIONAL MOOD: ', style: TextStyle(fontFamily: 'Arial', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9E6),
                              border: Border.all(color: const Color(0xFFE5C178), width: 1),
                            ),
                            child: Text(
                              inspiration.mood,
                              style: const TextStyle(fontFamily: 'Arial', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF996600)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('SUGGESTED COLOR PALETTE:', style: TextStyle(fontFamily: 'Arial', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF003399))),
                    const SizedBox(height: 6),
                    Row(
                      children: inspiration.palette.map((c) {
                        final color = _parseHex(c.hex);
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: color,
                                    border: Border.all(color: Colors.black26, width: 1),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  c.name,
                                  style: const TextStyle(fontFamily: 'Arial', fontSize: 9, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                Text(c.hex, style: const TextStyle(fontFamily: 'Arial', fontSize: 8, color: Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text('VISUAL METAPHORS & SCENE IDEAS:', style: TextStyle(fontFamily: 'Arial', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF003399))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F5FA),
                        border: Border.all(color: const Color(0xFFB4C6DF), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: inspiration.visualMetaphors.map((m) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('✦ ', style: TextStyle(color: Color(0xFFFF6600), fontSize: 11)),
                                Expanded(
                                  child: Text(m, style: const TextStyle(fontFamily: 'Arial', fontSize: 11, height: 1.35, color: Colors.black87)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('COMPOSITION & TECHNIQUE TIP:', style: TextStyle(fontFamily: 'Arial', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF003399))),
                    const SizedBox(height: 4),
                    Text(
                      inspiration.compositionTip,
                      style: const TextStyle(fontFamily: 'Arial', fontSize: 11, height: 1.4, fontStyle: FontStyle.italic, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EFF9),
                        border: Border.all(color: const Color(0xFF003399), width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.music_note, size: 14, color: Color(0xFF003399)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Music Ambience: ${inspiration.musicVibe}',
                              style: const TextStyle(fontFamily: 'Arial', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF003399)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: const Color(0xFFECE9D8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: RetroButton(
                  label: 'Got It! Start Painting >>',
                  isPrimary: true,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: PixelIcon.palette(size: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
