import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/retro_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      _usernameCtrl.text.trim().toLowerCase(),
      _emailCtrl.text.trim().toLowerCase(),
      _passwordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final error = context.select<AuthProvider, String?>((a) => a.error);
    return Scaffold(
      backgroundColor: RetroColors.pageBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                // Site banner
                Container(
                  width: double.infinity,
                  color: RetroColors.headerBg,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'dear stranger',
                        style: RetroTextStyles.vt323.copyWith(fontSize: 30, color: RetroColors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        color: RetroColors.accentOrange,
                        child: Text(
                          "It's FREE and takes 30 seconds!",
                          style: RetroTextStyles.pixel.copyWith(fontSize: 7, color: RetroColors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                RetroCard(
                  title: 'CREATE YOUR ACCOUNT',
                  titleBarColor: RetroColors.sectionHeaderPurple,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (error != null) ...[
                          Container(
                            color: const Color(0xFFFFEEEE),
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              '⚠ $error',
                              style: RetroTextStyles.small.copyWith(color: RetroColors.accent),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        RetroTextField(
                          controller: _usernameCtrl,
                          label: 'USERNAME:',
                          hint: 'letters, numbers, underscores only',
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v.length < 3) return 'At least 3 characters';
                            if (v.length > 20) return 'Max 20 characters';
                            if (!RegExp(r'^[a-z0-9_]+$').hasMatch(v.toLowerCase())) {
                              return 'Letters, numbers, underscores only';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        RetroTextField(
                          controller: _emailCtrl,
                          label: 'E-MAIL ADDRESS:',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (!v.contains('@')) return 'Invalid email address';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        RetroTextField(
                          controller: _passwordCtrl,
                          label: 'PASSWORD:',
                          hint: 'at least 8 characters',
                          obscureText: true,
                          validator: (v) {
                            if (v == null || v.length < 8) return 'At least 8 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _loading
                            ? const RetroLoading(message: 'CREATING ACCOUNT')
                            : RetroButton(
                                label: 'SIGN ME UP! »',
                                onPressed: _submit,
                                isPrimary: true,
                              ),
                        const SizedBox(height: 12),
                        const RetroDivider(),
                        Text(
                          'By creating an account you agree to our terms of service.',
                          style: RetroTextStyles.small.copyWith(
                            fontSize: 10,
                            color: RetroColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            '» Already have an account? Login here',
                            style: RetroTextStyles.link,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
