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
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                // Site Logo Header (MySpace Style)
                Container(
                  width: double.infinity,
                  color: RetroColors.headerBg,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PixelIcon.mail(size: 20),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'dear-stranger',
                                style: RetroTextStyles.logo.copyWith(fontSize: 22),
                              ),
                              const Text(
                                '.com',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD5E4F7),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'a place for letters & hand-drawn art',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 10,
                              color: Color(0xFFB4C6DF),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Member Login Box (Iconic MySpace Box)
                RetroCard(
                  title: 'Member Login',
                  titleBarColor: RetroColors.sectionHeader,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (error != null) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEEEE),
                              border: Border.all(color: RetroColors.accent, width: 1),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'Error: $error',
                              style: const TextStyle(fontFamily: 'Arial', fontSize: 11, color: RetroColors.accent),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        RetroTextField(
                          controller: _identifierCtrl,
                          label: 'E-Mail or Username:',
                          hint: 'Enter username or email',
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        RetroTextField(
                          controller: _passwordCtrl,
                          label: 'Password:',
                          hint: 'Enter your password',
                          obscureText: true,
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),

                        _loading
                            ? const RetroLoading(message: 'Logging in')
                            : Row(
                                children: [
                                  Expanded(
                                    child: RetroButton(
                                      label: 'LOGIN',
                                      onPressed: _submit,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RetroButton(
                                      label: 'SIGN UP! >>',
                                      onPressed: () => context.go('/register'),
                                      isPrimary: true,
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 12),
                        const RetroDivider(),
                        GestureDetector(
                          onTap: () => context.go('/'),
                          child: const MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Text(
                              '› Browse the Mailboard as Guest',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 11,
                                color: RetroColors.link,
                                decoration: TextDecoration.underline,
                              ),
                              textAlign: TextAlign.center,
                            ),
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
