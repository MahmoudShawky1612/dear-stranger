import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api/letters_api.dart';
import '../../core/providers/feed_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/retro_widgets.dart';

class SendLetterPage extends StatefulWidget {
  const SendLetterPage({super.key});

  @override
  State<SendLetterPage> createState() => _SendLetterPageState();
}

class _SendLetterPageState extends State<SendLetterPage> {
  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _msgCtrl    = TextEditingController();
  bool _isAnonymous = false;
  bool _loading     = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await LettersApi().sendLetter(
        title: _titleCtrl.text.trim(),
        message: _msgCtrl.text.trim(),
        isAnonymous: _isAnonymous,
      );
      if (!mounted) return;
      context.read<LettersFeedProvider>().refresh(silent: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✉ Letter sent! An artist will find it soon.')),
      );
      context.go('/letters/mine');
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RetroScaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✉ WRITE A LETTER', style: RetroTextStyles.h2),
            Text('Your letter will be posted on the board. An artist will claim it and paint you a picture.',
                style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary, fontStyle: FontStyle.italic)),
            const RetroDivider(),
            RetroCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null) ...
                      [
                        Container(
                          color: RetroColors.accent.withValues(alpha: 0.1),
                          padding: const EdgeInsets.all(8),
                          child: Text('⚠ $_error', style: RetroTextStyles.small.copyWith(color: RetroColors.accent)),
                        ),
                        const SizedBox(height: 12),
                      ],
                    RetroTextField(
                      controller: _titleCtrl,
                      label: 'LETTER TITLE',
                      hint: 'What is this letter about?',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please add a title';
                        if (v.length > 100) return 'Max 100 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    RetroTextField(
                      controller: _msgCtrl,
                      label: 'YOUR LETTER',
                      hint: 'Write something heartfelt, curious, or strange...',
                      maxLines: 10,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please write something';
                        if (v.length > 2000) return 'Max 2000 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _isAnonymous,
                          onChanged: (v) => setState(() => _isAnonymous = v ?? false),
                          fillColor: WidgetStateProperty.all(RetroColors.borderDark),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isAnonymous = !_isAnonymous),
                          child: Text('Send anonymously (hide my username from the artist)',
                              style: RetroTextStyles.small),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _loading
                        ? const RetroLoading(message: 'SENDING...')
                        : Row(
                            children: [
                              Expanded(child: RetroButton(label: 'SEND LETTER', onPressed: _submit, isPrimary: true)),
                              const SizedBox(width: 12),
                              RetroButton(label: 'CANCEL', onPressed: () => context.go('/')),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
