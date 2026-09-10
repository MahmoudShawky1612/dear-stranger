import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api/image_upload.dart';
import '../../core/api/users_api.dart';
import '../../core/models/user.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/retro_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _api = UsersApi();
  final _displayNameCtrl   = TextEditingController();
  final _bioCtrl           = TextEditingController();
  final _locationCtrl      = TextEditingController();
  final _mediumCtrl        = TextEditingController();
  final _drawingCtrl       = TextEditingController();
  bool _saving        = false;
  bool _avatarLoading = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefill());
  }

  void _prefill() {
    final u = context.read<AuthProvider>().user;
    if (u == null) return;
    _displayNameCtrl.text   = u.displayName ?? '';
    _bioCtrl.text           = u.bio ?? '';
    _locationCtrl.text      = u.location ?? '';
    _mediumCtrl.text        = u.favoriteMedium ?? '';
    _drawingCtrl.text       = u.currentlyDrawing ?? '';
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _mediumCtrl.dispose();
    _drawingCtrl.dispose();
    super.dispose();
  }

  String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

  Future<void> _save() async {
    setState(() { _saving = true; _error = null; _success = null; });
    try {
      final updated = await _api.updateProfile({
        'displayName':    _nullIfEmpty(_displayNameCtrl.text),
        'bio':            _nullIfEmpty(_bioCtrl.text),
        'location':       _nullIfEmpty(_locationCtrl.text),
        'favoriteMedium': _nullIfEmpty(_mediumCtrl.text),
        'currentlyDrawing': _nullIfEmpty(_drawingCtrl.text),
      });
      if (!mounted) return;
      context.read<AuthProvider>().updateUser(updated);
      setState(() { _saving = false; _success = 'Profile updated!'; });
    } catch (e) {
      setState(() { _saving = false; _error = e.toString(); });
    }
  }

  Future<void> _uploadAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    final ext = file.extension?.toLowerCase() ?? 'jpg';
    final contentType = imageContentTypeForExtension(ext);
    if (contentType == null) {
      setState(() { _error = 'Please upload a JPEG, PNG, or WebP image.'; });
      return;
    }

    setState(() { _avatarLoading = true; _error = null; });
    try {
      final updated = await _api.uploadAvatarFile(bytes: file.bytes!, contentType: contentType);
      if (!mounted) return;
      context.read<AuthProvider>().updateUser(updated);
      setState(() { _avatarLoading = false; _success = 'Profile picture updated!'; });
    } catch (e) {
      if (mounted) setState(() { _avatarLoading = false; _error = e.toString(); });
    }
  }

  Future<void> _removeAvatar() async {
    setState(() => _avatarLoading = true);
    try {
      await _api.removeAvatar();
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        final u = auth.user!;
        auth.updateUser(User(
          id: u.id,
          username: u.username,
          email: u.email,
          displayName: u.displayName,
          bio: u.bio,
          avatarUrl: null,
          location: u.location,
          favoriteMedium: u.favoriteMedium,
          currentlyDrawing: u.currentlyDrawing,
          createdAt: u.createdAt,
        ));
      }
      setState(() { _avatarLoading = false; _success = 'Profile picture removed.'; });
    } catch (e) {
      setState(() { _avatarLoading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthProvider, dynamic>((a) => a.user);
    return RetroScaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page title
            Row(
              children: [
                Expanded(
                  child: Container(
                    color: RetroColors.sectionHeaderPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text('■ MY SPACE — EDIT PROFILE', style: RetroTextStyles.sectionTitle),
                  ),
                ),
                if (user != null) ...[
                  const SizedBox(width: 8),
                  RetroButton(
                    label: '» VIEW MY PROFILE',
                    onPressed: () => context.go('/profile/${user.username}'),
                    isSmall: true,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // Success / Error banners
            if (_success != null)
              Container(
                width: double.infinity,
                color: const Color(0xFFDDFFDD),
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '✓ $_success',
                  style: RetroTextStyles.small.copyWith(color: RetroColors.accentGreen),
                ),
              ),
            if (_error != null)
              Container(
                width: double.infinity,
                color: const Color(0xFFFFEEEE),
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '⚠ $_error',
                  style: RetroTextStyles.small.copyWith(color: RetroColors.accent),
                ),
              ),

            // Profile picture section
            RetroCard(
              title: 'PROFILE PICTURE',
              titleBarColor: RetroColors.sectionHeader,
              child: Row(
                children: [
                  // Avatar with dotted border (MySpace style)
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: RetroColors.sectionHeader,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      color: RetroColors.pageBackground,
                    ),
                    child: user?.avatarUrl != null
                        ? Image.network(
                            user!.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const _AvatarPlaceholder(),
                          )
                        : const _AvatarPlaceholder(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JPG, PNG, or WebP · Max 2 MB',
                          style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _avatarLoading
                                ? const RetroLoading()
                                : RetroButton(
                                    label: '📎 UPLOAD PHOTO',
                                    onPressed: _uploadAvatar,
                                    isSmall: true,
                                  ),
                            if (user?.avatarUrl != null)
                              RetroButton(
                                label: 'REMOVE',
                                onPressed: _removeAvatar,
                                isSmall: true,
                                isDanger: true,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Profile info
            RetroCard(
              title: 'ABOUT ME',
              titleBarColor: RetroColors.sectionHeader,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RetroTextField(controller: _displayNameCtrl, label: 'DISPLAY NAME:', hint: 'Your name or alias'),
                  const SizedBox(height: 12),
                  RetroTextField(controller: _bioCtrl, label: 'BIO:', hint: 'Tell everyone about yourself', maxLines: 4),
                  const SizedBox(height: 12),
                  RetroTextField(controller: _locationCtrl, label: 'LOCATION:', hint: 'e.g. Cairo, Egypt'),
                  const SizedBox(height: 12),
                  RetroTextField(controller: _mediumCtrl, label: 'FAVORITE MEDIUM:', hint: 'e.g. Watercolor, Digital'),
                  const SizedBox(height: 12),
                  RetroTextField(controller: _drawingCtrl, label: 'CURRENTLY DRAWING:', hint: 'What are you working on?'),
                  const SizedBox(height: 16),
                  _saving
                      ? const RetroLoading(message: 'SAVING YOUR PROFILE')
                      : RetroButton(
                          label: '✓ UPDATE MY PROFILE',
                          onPressed: _save,
                          isPrimary: true,
                        ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Account
            RetroCard(
              title: 'ACCOUNT',
              titleBarColor: RetroColors.sectionHeaderRed,
              child: RetroButton(
                label: 'SIGN OUT',
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) context.go('/');
                },
                isDanger: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          '?',
          style: RetroTextStyles.vt323.copyWith(fontSize: 40, color: RetroColors.border),
        ),
      );
}
