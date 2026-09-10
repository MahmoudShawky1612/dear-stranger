import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/api/users_api.dart';
import '../../core/models/user.dart';
import '../../core/models/guestbook_entry.dart';
import '../../core/models/gallery_item.dart';
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
  List<GalleryItem> _gallery = [];
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
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.username != widget.username) {
      _gbCtrl.clear();
      _load();
    }
  }

  @override
  void dispose() {
    _gbCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final user = await _api.getPublicProfile(widget.username);
      final entries = await _api.getGuestbook(widget.username);
      var gallery = <GalleryItem>[];
      try {
        gallery = await _api.getGallery(widget.username);
      } catch (_) {
        gallery = const [];
      }
      if (!mounted) return;
      setState(() {
        _user = user;
        _entries = entries;
        _gallery = gallery;
        _loading = false;
      });
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

  void _openArtwork(GalleryItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        final fmt = DateFormat('MMM dd, yyyy');
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  color: RetroColors.headerBg,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Row(
                    children: [
                      PixelIcon.palette(size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.letterTitle.isEmpty ? 'Published Artwork' : item.letterTitle,
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: RetroColors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: const Text(
                          '[X]',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: RetroColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: RetroColors.surface,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: RetroColors.border, width: 1),
                        ),
                        child: Image.network(
                          item.url,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              '[ Image could not be loaded ]',
                              style: TextStyle(fontFamily: 'Arial', fontSize: 11, color: RetroColors.textSecondary),
                            ),
                          ),
                        ),
                      ),
                      if (item.publishedAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Published ${fmt.format(item.publishedAt!)}',
                          style: const TextStyle(fontFamily: 'Arial', fontSize: 10, color: RetroColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          RetroCard(
            title: isOwner ? '${_user!.displayHandle}\'s Space (Your Profile)' : '${_user!.displayHandle}\'s Space',
            titleBarColor: RetroColors.sectionHeader,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

          _SectionBar(
            icon: PixelIcon.palette(size: 14),
            label: 'Public Gallery — Published Artworks',
          ),
          const SizedBox(height: 8),
          if (_gallery.isEmpty)
            RetroCard(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  isOwner
                      ? 'You have not published any artwork yet. Publish a delivered piece from a letter to hang it here.'
                      : 'This stranger has not published any artwork yet.',
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    color: RetroColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final item in _gallery)
                  _GalleryTile(
                    item: item,
                    dateLabel: item.publishedAt != null ? fmt.format(item.publishedAt!) : '',
                    onTap: () => _openArtwork(item),
                  ),
              ],
            ),
          const SizedBox(height: 16),

          _SectionBar(
            icon: PixelIcon.doc(size: 14),
            label: 'Guestbook — Leave a Letter for this Stranger',
          ),
          const SizedBox(height: 8),

          if (isAuth && !isOwner) ...[
            RetroCard(
              title: 'Write a Letter in the Guestbook',
              titleBarColor: const Color(0xFF446699),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Leave a short letter on this profile. Keep it kind — this is a public guestbook, not a private mailbox.',
                    style: TextStyle(fontFamily: 'Arial', fontSize: 11, color: RetroColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFF8),
                      border: Border.all(color: const Color(0xFFE8E8E0), width: 1),
                    ),
                    child: TextField(
                      controller: _gbCtrl,
                      maxLines: 5,
                      maxLength: 300,
                      style: RetroTextStyles.typewriter.copyWith(fontSize: 13, height: 1.55),
                      decoration: const InputDecoration(
                        hintText: 'Dear stranger,\n\nI saw your space and wanted to say...',
                        counterText: '',
                        filled: true,
                        fillColor: Color(0xFFFFFFF8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _sendingEntry
                        ? const RetroLoading()
                        : RetroButton(
                            label: 'Leave Letter >>',
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
          ] else if (!isAuth) ...[
            RetroCard(
              title: 'Sign in to Leave a Letter',
              titleBarColor: const Color(0xFF446699),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Members can leave a letter in this guestbook. Create an account or sign in first.',
                      style: TextStyle(fontFamily: 'Arial', fontSize: 12, height: 1.4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  RetroButton(
                    label: 'Sign In >>',
                    onPressed: () => context.go('/login'),
                    isPrimary: true,
                    isSmall: true,
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
                  'No guestbook letters yet. Be the first to leave a message!',
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
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD5E4F7),
                          border: Border.all(color: RetroColors.border, width: 1),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: e.author.avatarUrl != null && e.author.avatarUrl!.trim().isNotEmpty
                            ? Image.network(
                                e.author.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: PixelIcon.userIcon(size: 18),
                                ),
                              )
                            : Center(
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
                              style: RetroTextStyles.typewriter.copyWith(fontSize: 12, height: 1.45),
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

class _SectionBar extends StatelessWidget {
  final Widget icon;
  final String label;
  const _SectionBar({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RetroColors.sectionHeader,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: RetroColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final GalleryItem item;
  final String dateLabel;
  final VoidCallback onTap;
  const _GalleryTile({required this.item, required this.dateLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: 168,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 168,
                height: 126,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F5FA),
                  border: Border.all(color: RetroColors.headerBg, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  item.url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(child: PixelIcon.palette(size: 28)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.letterTitle.isEmpty ? 'Untitled' : item.letterTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: RetroColors.link,
                  decoration: TextDecoration.underline,
                ),
              ),
              if (dateLabel.isNotEmpty)
                Text(
                  dateLabel,
                  style: const TextStyle(fontFamily: 'Arial', fontSize: 10, color: RetroColors.textSecondary),
                ),
            ],
          ),
        ),
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
