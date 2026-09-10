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
    if (_loading) return RetroScaffold(body: const RetroLoading(message: 'Loading user profile'));
    if (_error != null) return RetroScaffold(body: RetroError(_error!, onRetry: _load));
    final me = context.select<AuthProvider, int?>((a) => a.user?.id);
    final isAuth = context.select<AuthProvider, bool>((a) => a.isAuthenticated);
    final isOwner = me == _user?.id;
    final fmt = DateFormat('MMM dd, yyyy');

    return RetroScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header card (MySpace profile layout)
          RetroCard(
            title: isOwner ? '${_user!.displayHandle}\'s Space (Your Profile)' : '${_user!.displayHandle}\'s Space',
            titleBarColor: RetroColors.sectionHeader,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Avatar Photo Box
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFB4C6DF), width: 1),
                    color: const Color(0xFFF2F5FA),
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
                      Text(
                        _user!.displayHandle,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: RetroColors.headerBg,
                        ),
                      ),
                      Text(
                        '@${_user!.username}',
                        style: const TextStyle(fontFamily: 'Arial', fontSize: 11, color: RetroColors.textSecondary),
                      ),
                      if (_user!.bio != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _user!.bio!,
                          style: const TextStyle(fontFamily: 'Arial', fontSize: 12, height: 1.4),
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Info chips with PixelIcons
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          if (_user!.location != null)
                            _InfoTag(icon: PixelIcon.pin(size: 11), text: _user!.location!),
                          if (_user!.favoriteMedium != null)
                            _InfoTag(icon: PixelIcon.palette(size: 11), text: _user!.favoriteMedium!),
                          if (_user!.currentlyDrawing != null)
                            _InfoTag(icon: PixelIcon.write(size: 11), text: 'Drawing: ${_user!.currentlyDrawing!}'),
                          if (_user!.createdAt != null)
                            _InfoTag(icon: PixelIcon.calendar(size: 11), text: 'Member since ${fmt.format(_user!.createdAt!)}'),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  RetroButton(
                    label: 'Edit Profile >>',
                    onPressed: () => context.go('/settings'),
                    isSmall: true,
                    icon: PixelIcon.write(size: 11),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Guestbook Section
          Container(
            color: RetroColors.sectionHeader,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                PixelIcon.doc(size: 14),
                const SizedBox(width: 8),
                const Text(
                  'User Guestbook — Leave a Message for this Stranger',
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
          const SizedBox(height: 8),

          if (isAuth && !isOwner) ...[
            RetroCard(
              title: 'Sign the Guestbook',
              titleBarColor: const Color(0xFF446699),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _gbCtrl,
                    maxLines: 3,
                    style: const TextStyle(fontFamily: 'Arial', fontSize: 12),
                    decoration: const InputDecoration(hintText: 'Leave a friendly message on this profile...'),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _sendingEntry
                        ? const RetroLoading()
                        : RetroButton(
                            label: 'Sign Guestbook >>',
                            onPressed: _postEntry,
                            isPrimary: true,
                            isSmall: true,
                            icon: PixelIcon.write(size: 11),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (_entries.isEmpty)
            RetroCard(
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: Text(
                  'No guestbook entries yet. Be the first to leave a message!',
                  style: TextStyle(fontFamily: 'Arial', fontSize: 12, color: RetroColors.textSecondary, fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (_, i) {
                final e = _entries[i];
                final canDelete = me == e.author.id || isOwner;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: i.isEven ? RetroColors.tableRow : RetroColors.tableRowAlt,
                    border: Border.all(color: const Color(0xFFE4EBF5), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mini avatar silhouette
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD5E4F7),
                          border: Border.all(color: RetroColors.border, width: 1),
                        ),
                        child: Center(
                          child: PixelIcon.userIcon(size: 18),
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
                                  child: Text(
                                    e.author.displayHandle,
                                    style: const TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: RetroColors.link,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  fmt.format(e.createdAt),
                                  style: const TextStyle(fontFamily: 'Arial', fontSize: 10, color: RetroColors.textSecondary),
                                ),
                                if (canDelete) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _deleteEntry(e.id),
                                    child: const Text(
                                      '[delete]',
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 10,
                                        color: RetroColors.accent,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              e.message,
                              style: const TextStyle(fontFamily: 'Arial', fontSize: 12, height: 1.4),
                            ),
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
  final Widget icon;
  final String text;
  const _InfoTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EFF9),
          border: Border.all(color: const Color(0xFFC0D2EB), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 4),
            Text(text, style: const TextStyle(fontFamily: 'Arial', fontSize: 11, color: RetroColors.textPrimary)),
          ],
        ),
      );
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) => Center(
        child: PixelIcon.userIcon(size: 44, color: const Color(0xFFB4C6DF)),
      );
}
