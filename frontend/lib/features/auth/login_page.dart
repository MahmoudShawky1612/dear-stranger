import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/retro_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_identifierCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = context.select<AuthProvider, String?>((a) => a.error);
    return Scaffold(
      backgroundColor: RetroColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  color: RetroColors.marqueeBar,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('★ DEAR STRANGER ★', style: RetroTextStyles.pixel.copyWith(fontSize: 14, color: RetroColors.white)),
                      const SizedBox(height: 4),
                      Text(':: a letter exchange ::', style: RetroTextStyles.typewriter.copyWith(fontSize: 11, color: RetroColors.silver, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                RetroCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('SIGN IN', style: RetroTextStyles.h2),
                        const RetroDivider(),
                        if (error != null) ...
                          [
                            Container(
                              color: RetroColors.accent.withValues(alpha: 0.1),
                              padding: const EdgeInsets.all(8),
                              child: Text('⚠ $error', style: RetroTextStyles.small.copyWith(color: RetroColors.accent)),
                            ),
                            const SizedBox(height: 12),
                          ],
                        RetroTextField(
                          controller: _identifierCtrl,
                          label: 'USERNAME OR EMAIL',
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        RetroTextField(
                          controller: _passwordCtrl,
                          label: 'PASSWORD',
                          obscureText: true,
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 20),
                        _loading
                            ? const RetroLoading(message: 'SIGNING IN...')
                            : RetroButton(label: 'SIGN IN', onPressed: _submit, isPrimary: true),
                        const SizedBox(height: 16),
                        const RetroDivider(),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Text(
                            '[ New here? Create an account ]',
                            style: RetroTextStyles.link,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => context.go('/'),
                          child: Text(
                            '[ Browse letters without signing in ]',
                            style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary),
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
