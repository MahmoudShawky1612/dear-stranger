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
    if (_loading) return RetroScaffold(body: const RetroLoading(message: 'LOADING PROFILE'));
    if (_error != null) return RetroScaffold(body: RetroError(_error!, onRetry: _load));
    final me = context.select<AuthProvider, int?>((a) => a.user?.id);
    final isAuth = context.select<AuthProvider, bool>((a) => a.isAuthenticated);
    final isOwner = me == _user?.id;
    final fmt = DateFormat('dd MMM yyyy');

    return RetroScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          RetroCard(
            title: isOwner ? 'MY SPACE — ${_user!.displayHandle.toUpperCase()}' : '${_user!.displayHandle.toUpperCase()}\'S SPACE',
            titleBarColor: RetroColors.sectionHeaderPurple,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Large avatar (MySpace style)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: RetroColors.sectionHeaderPurple, width: 3),
                    color: RetroColors.pageBackground,
                  ),
                  child: _user?.avatarUrl != null
                      ? Image.network(
                          _user!.avatarUrl!,
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
                      Text(_user!.displayHandle, style: RetroTextStyles.vt323.copyWith(fontSize: 28)),
                      Text(
                        '@${_user!.username}',
                        style: RetroTextStyles.small.copyWith(color: RetroColors.link),
                      ),
                      if (_user!.bio != null) ...[
                        const SizedBox(height: 8),
                        Text(_user!.bio!, style: RetroTextStyles.body),
                      ],
                      const SizedBox(height: 8),
                      // Info chips
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          if (_user!.location != null)
                            _InfoTag('📍 ${_user!.location!}'),
                          if (_user!.favoriteMedium != null)
                            _InfoTag('🎨 ${_user!.favoriteMedium!}'),
                          if (_user!.currentlyDrawing != null)
                            _InfoTag('✏️ Working on: ${_user!.currentlyDrawing!}'),
                          if (_user!.createdAt != null)
                            _InfoTag('📅 Member since ${fmt.format(_user!.createdAt!)}'),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  RetroButton(
                    label: '✏ EDIT PROFILE',
                    onPressed: () => context.go('/settings'),
                    isSmall: true,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Guestbook
          Container(
            color: RetroColors.sectionHeader,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text('■ 📖 GUESTBOOK', style: RetroTextStyles.sectionTitle),
          ),
          const SizedBox(height: 8),

          if (isAuth && !isOwner) ...[
            RetroCard(
              title: 'LEAVE A MESSAGE',
              titleBarColor: RetroColors.sectionHeaderPurple,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                        : RetroButton(
                            label: '✍ SIGN GUESTBOOK',
                            onPressed: _postEntry,
                            isPrimary: true,
                            isSmall: true,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (_entries.isEmpty)
            RetroCard(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No guestbook entries yet. Be the first to sign!',
                style: RetroTextStyles.body.copyWith(color: RetroColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 0),
              itemBuilder: (_, i) {
                final e = _entries[i];
                final canDelete = me == e.author.id || isOwner;
                return Container(
                  color: i.isEven ? RetroColors.surface : const Color(0xFFF5F5F8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: RetroColors.border, width: 1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mini avatar
                      Container(
                        width: 32,
                        height: 32,
                        color: RetroColors.sectionHeaderPurple,
                        child: Center(
                          child: Text(
                            e.author.displayHandle.isNotEmpty
                                ? e.author.displayHandle[0].toUpperCase()
                                : '?',
                            style: RetroTextStyles.vt323.copyWith(
                              fontSize: 18,
                              color: RetroColors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
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
                                Text(
                                  fmt.format(e.createdAt),
                                  style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary, fontSize: 10),
                                ),
                                if (canDelete) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _deleteEntry(e.id),
                                    child: Text(
                                      '[delete]',
                                      style: RetroTextStyles.small.copyWith(
                                        fontSize: 10,
                                        color: RetroColors.accent,
                                        decoration: TextDecoration.underline,
                                        decorationColor: RetroColors.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(e.message, style: RetroTextStyles.body),
                          ],
                        ),
                      ),
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

class _InfoTag extends StatelessWidget {
  final String text;
  const _InfoTag(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        color: const Color(0xFFEEEEFF),
        child: Text(text, style: RetroTextStyles.small.copyWith(fontSize: 11, color: RetroColors.textPrimary)),
      );
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
