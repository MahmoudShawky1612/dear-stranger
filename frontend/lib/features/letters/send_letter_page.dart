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
        const SnackBar(content: Text('Your letter has been posted to the mailboard!')),
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
            // Page Title Strip
            Container(
              width: double.infinity,
              color: RetroColors.sectionHeader,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  PixelIcon.write(size: 15),
                  const SizedBox(width: 8),
                  const Text(
                    'Drop a Letter into the Mail Box',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: RetroColors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your letter will appear on the public mailboard. An artist will pick it up and create original artwork inspired by your words.',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 11,
                color: RetroColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const RetroDivider(),

            RetroCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEEE),
                          border: Border.all(color: RetroColors.accent, width: 1),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Error: $_error',
                          style: const TextStyle(fontFamily: 'Arial', fontSize: 11, color: RetroColors.accent),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    RetroTextField(
                      controller: _titleCtrl,
                      label: 'Letter Title / Subject:',
                      hint: 'Give your letter a title...',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please add a title';
                        if (v.length > 100) return 'Max 100 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    RetroTextField(
                      controller: _msgCtrl,
                      label: 'Letter Body:',
                      hint: 'Write something heartfelt, curious, or honest...',
                      maxLines: 12,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please write something';
                        if (v.length > 2000) return 'Max 2000 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Anonymous toggle (MySpace style shaded box)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FA),
                        border: Border.all(color: const Color(0xFFD0DCEE), width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isAnonymous,
                            onChanged: (v) => setState(() => _isAnonymous = v ?? false),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isAnonymous = !_isAnonymous),
                            child: const Text(
                              'Post anonymously (hide my username from the artist)',
                              style: TextStyle(fontFamily: 'Arial', fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _loading
                        ? const RetroLoading(message: 'Posting your letter to the board')
                        : Row(
                            children: [
                              Expanded(
                                child: RetroButton(
                                  label: 'Post Letter to Board >>',
                                  onPressed: _submit,
                                  isPrimary: true,
                                  icon: PixelIcon.mail(size: 13),
                                ),
                              ),
                              const SizedBox(width: 10),
                              RetroButton(
                                label: 'Cancel',
                                onPressed: () => context.go('/'),
                              ),
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
