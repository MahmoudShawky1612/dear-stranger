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
            constraints: const BoxConstraints(maxWidth: 420),
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
                      Text(
                        'a letter exchange',
                        style: RetroTextStyles.typewriter.copyWith(
                          fontSize: 11, color: RetroColors.silver, fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Login form card
                RetroCard(
                  title: 'MEMBER LOGIN',
                  titleBarColor: RetroColors.sectionHeader,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (error != null) ...[
                          Container(
                            color: const Color(0xFFFFEEEE),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                const Text('⚠ ', style: TextStyle(fontSize: 14)),
                                Expanded(
                                  child: Text(
                                    error,
                                    style: RetroTextStyles.small.copyWith(color: RetroColors.accent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        RetroTextField(
                          controller: _identifierCtrl,
                          label: 'E-MAIL OR USERNAME:',
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        RetroTextField(
                          controller: _passwordCtrl,
                          label: 'PASSWORD:',
                          obscureText: true,
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _loading
                            ? const RetroLoading(message: 'SIGNING IN')
                            : RetroButton(
                                label: 'LOGIN »',
                                onPressed: _submit,
                                isPrimary: true,
                              ),
                        const SizedBox(height: 12),
                        const RetroDivider(),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Text(
                            '» Not a member? JOIN FOR FREE!',
                            style: RetroTextStyles.link.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => context.go('/'),
                          child: Text(
                            '» Browse the mailboard without signing in',
                            style: RetroTextStyles.linkSmall.copyWith(color: RetroColors.textSecondary),
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
