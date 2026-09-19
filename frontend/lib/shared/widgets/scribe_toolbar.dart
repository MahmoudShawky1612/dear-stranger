import 'package:flutter/material.dart';
import '../../core/api/agents_api.dart';
import '../../core/theme/app_theme.dart';
import 'retro_widgets.dart';

class ScribeAssistantToolbar extends StatefulWidget {
  final TextEditingController textController;
  final VoidCallback? onStyleApplied;

  const ScribeAssistantToolbar({
    super.key,
    required this.textController,
    this.onStyleApplied,
  });

  @override
  State<ScribeAssistantToolbar> createState() => _ScribeAssistantToolbarState();
}

class _ScribeAssistantToolbarState extends State<ScribeAssistantToolbar> {
  bool _loading = false;
  String? _selectedStyle;

  Future<void> _applyStyle(String styleKey) async {
    final currentText = widget.textController.text.trim();
    if (currentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a quick draft first, then select a style!')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _selectedStyle = styleKey;
    });

    try {
      final res = await AgentsApi().polishWithScribe(currentText);
      String transformed = currentText;

      switch (styleKey) {
        case 'vintage': transformed = res.vintage; break;
        case 'poetic': transformed = res.poetic; break;
        case 'midnight': transformed = res.midnightDiary; break;
        case 'minimalist': transformed = res.minimalist; break;
      }

      widget.textController.text = transformed;
      widget.onStyleApplied?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✨ Letter transformed into ${styleKey.toUpperCase()} style!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to polish: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        border: Border.all(color: const Color(0xFFB4C6DF), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PixelIcon.write(size: 13),
              const SizedBox(width: 6),
              const Text(
                'THE SCRIBE AI ASSISTANT — Polish Your Tone:',
                style: TextStyle(fontFamily: 'Arial', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF003399)),
              ),
              const Spacer(),
              if (_loading)
                const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildStyleChip('📜 Vintage 1900s', 'vintage'),
              _buildStyleChip('✨ Poetic', 'poetic'),
              _buildStyleChip('🌙 Midnight Diary', 'midnight'),
              _buildStyleChip('🖋️ Minimalist', 'minimalist'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStyleChip(String label, String key) {
    final isSelected = _selectedStyle == key;
    return GestureDetector(
      onTap: _loading ? null : () => _applyStyle(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD5E4F7) : const Color(0xFFFFFFFF),
          border: Border.all(
            color: isSelected ? const Color(0xFF003399) : const Color(0xFFCCCCCC),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF003399),
          ),
        ),
      ),
    );
  }
}
