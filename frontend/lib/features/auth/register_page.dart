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
      _usernameCtrl.text.trim(),
      _emailCtrl.text.trim(),
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
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // Site Logo Header
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
                            'free registration · join in 30 seconds',
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

                // Registration Box
                RetroCard(
                  title: 'Create Your Account — Free!',
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
                          controller: _usernameCtrl,
                          label: 'Desired Username:',
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
                        const SizedBox(height: 10),
                        RetroTextField(
                          controller: _emailCtrl,
                          label: 'E-Mail Address:',
                          keyboardType: TextInputType.emailAddress,
                          hint: 'name@example.com',
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (!v.contains('@')) return 'Invalid email address';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        RetroTextField(
                          controller: _passwordCtrl,
                          label: 'Choose Password:',
                          hint: 'at least 8 characters',
                          obscureText: true,
                          validator: (v) {
                            if (v == null || v.length < 8) return 'At least 8 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _loading
                            ? const RetroLoading(message: 'Creating your account')
                            : RetroButton(
                                label: 'SIGN UP NOW! >>',
                                onPressed: _submit,
                                isPrimary: true,
                                icon: PixelIcon.userIcon(size: 13, color: Colors.white),
                              ),
                        const SizedBox(height: 12),
                        const RetroDivider(),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Text(
                              '› Already have an account? Click here to Login',
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
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => context.go('/'),
                          child: const MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Text(
                              '› Return to Mailboard',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 10,
                                color: RetroColors.textSecondary,
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
