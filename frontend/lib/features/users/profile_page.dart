import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/api/users_api.dart';
import '../../core/models/user.dart';
import '../../core/models/guestbook_entry.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/retro_widgets.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _api = UsersApi();
  User? _user;
  List<GuestbookEntry> _entries = [];
  bool _loading = true;
  String? _error;
  final _gbCtrl = TextEditingController();
  bool _sendingEntry = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _gbCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final user    = await _api.getPublicProfile(widget.username);
      final entries = await _api.getGuestbook(widget.username);
      if (!mounted) return;
      setState(() { _user = user; _entries = entries; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _postEntry() async {
    final msg = _gbCtrl.text.trim();
    if (msg.isEmpty) return;
    setState(() => _sendingEntry = true);
    try {
      final e = await _api.writeGuestbookEntry(widget.username, msg);
      _gbCtrl.clear();
      setState(() { _entries = [e, ..._entries]; _sendingEntry = false; });
    } catch (e) {
      setState(() => _sendingEntry = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _deleteEntry(int id) async {
    await _api.deleteGuestbookEntry(id);
    setState(() => _entries.removeWhere((e) => e.id == id));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return RetroScaffold(body: const RetroLoading(message: 'LOADING PROFILE...'));
    if (_error != null) return RetroScaffold(body: RetroError(_error!, onRetry: _load));
    final me = context.select<AuthProvider, int?>((a) => a.user?.id);
    final isAuth = context.select<AuthProvider, bool>((a) => a.isAuthenticated);
    final isOwner = me == _user?.id;
    final fmt = DateFormat('dd MMM yyyy');

    return RetroScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile card
          RetroCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: RetroColors.border, width: 2),
                    color: RetroColors.background,
                  ),
                  child: _user?.avatarUrl != null
                      ? Image.network(_user!.avatarUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const _AvatarPlaceholder())
                      : const _AvatarPlaceholder(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_user!.displayHandle, style: RetroTextStyles.h2),
                      Text('@${_user!.username}', style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary)),
                      if (_user!.bio != null) ...
                        [const SizedBox(height: 8), Text(_user!.bio!, style: RetroTextStyles.body)],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        children: [
                          if (_user!.location != null)         _InfoChip('📍 ${_user!.location!}'),
                          if (_user!.favoriteMedium != null)   _InfoChip('🎨 ${_user!.favoriteMedium!}'),
                          if (_user!.currentlyDrawing != null) _InfoChip('✏️ ${_user!.currentlyDrawing!}'),
                          if (_user!.createdAt != null)       _InfoChip('📅 Since ${fmt.format(_user!.createdAt!)}'),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  RetroButton(label: 'EDIT PROFILE', onPressed: () => context.go('/settings'), isSmall: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Guestbook
          Text('📖 GUESTBOOK', style: RetroTextStyles.h2),
          const RetroDivider(),
          if (isAuth && !isOwner) ...
            [
              RetroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Leave a message:', style: RetroTextStyles.label),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _gbCtrl,
                      maxLines: 3,
                      style: RetroTextStyles.typewriter.copyWith(fontSize: 14),
                      decoration: const InputDecoration(hintText: 'Say something nice...'),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _sendingEntry
                          ? const RetroLoading()
                          : RetroButton(label: 'SIGN GUESTBOOK', onPressed: _postEntry, isPrimary: true, isSmall: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          if (_entries.isEmpty)
            RetroCard(
              padding: const EdgeInsets.all(24),
              child: Text('No entries yet. Be the first!', style: RetroTextStyles.body, textAlign: TextAlign.center),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final e = _entries[i];
                final canDelete = me == e.author.id || isOwner;
                return RetroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/profile/${e.author.username}'),
                            child: Text(e.author.displayHandle, style: RetroTextStyles.link),
                          ),
                          const Spacer(),
                          Text(fmt.format(e.createdAt), style: RetroTextStyles.small.copyWith(color: RetroColors.border)),
                          if (canDelete) ...
                            [
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _deleteEntry(e.id),
                                child: Text('[x]', style: RetroTextStyles.pixel.copyWith(fontSize: 7, color: RetroColors.accent)),
                              ),
                            ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(e.message, style: RetroTextStyles.body),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  const _InfoChip(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary));
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) => Center(
        child: Text('?', style: RetroTextStyles.pixel.copyWith(fontSize: 28, color: RetroColors.border)),
      );
}
