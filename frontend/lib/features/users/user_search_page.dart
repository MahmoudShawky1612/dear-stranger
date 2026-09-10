import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/users_api.dart';
import '../../core/models/user.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/retro_widgets.dart';

class UserSearchPage extends StatefulWidget {
  final String initialQuery;
  const UserSearchPage({super.key, this.initialQuery = ''});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final _api = UsersApi();
  late final TextEditingController _ctrl;
  List<User> _users = [];
  bool _loading = false;
  bool _searched = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _search(widget.initialQuery);
      });
    }
  }

  @override
  void didUpdateWidget(covariant UserSearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery) {
      _ctrl.text = widget.initialQuery;
      if (widget.initialQuery.trim().isEmpty) {
        setState(() {
          _users = [];
          _searched = false;
          _error = null;
          _loading = false;
        });
      } else {
        _search(widget.initialQuery);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit(String raw) {
    var q = raw.trim();
    if (q.startsWith('@')) q = q.substring(1).trim();
    if (q.isEmpty) {
      context.go('/search');
      return;
    }
    final dest = '/search?q=${Uri.encodeQueryComponent(q)}';
    final currentQ = GoRouterState.of(context).uri.queryParameters['q'] ?? '';
    if (currentQ == q) {
      _search(q);
    } else {
      context.go(dest);
    }
  }

  Future<void> _search(String raw) async {
    var q = raw.trim();
    if (q.startsWith('@')) q = q.substring(1).trim();
    if (q.isEmpty) {
      setState(() {
        _users = [];
        _searched = false;
        _error = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });
    try {
      final users = await _api.searchUsers(q);
      if (!mounted) return;
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RetroScaffold(
      showSidebar: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: RetroColors.sectionHeader,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                PixelIcon.userIcon(size: 15),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Member Search — Find a Stranger by Username',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: RetroColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Look up another member and visit their space, guestbook, and public gallery.',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 11,
              color: RetroColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const RetroDivider(),
          RetroCard(
            title: 'Search the Member Directory',
            titleBarColor: const Color(0xFF446699),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onSubmitted: _submit,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(fontFamily: 'Arial', fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'username (letters, numbers, underscores)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                RetroButton(
                  label: 'Search >>',
                  onPressed: () => _submit(_ctrl.text),
                  isPrimary: true,
                  isSmall: true,
                  icon: PixelIcon.userIcon(size: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const RetroLoading(message: 'Searching the member directory')
          else if (_error != null)
            RetroError(_error!, onRetry: () => _submit(_ctrl.text))
          else if (!_searched)
            RetroCard(
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: Text(
                  'Type a username and hit Search to find a member\'s space.',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    color: RetroColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else if (_users.isEmpty)
            RetroCard(
              title: 'No Members Found',
              titleBarColor: RetroColors.sectionHeader,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Nobody matches "${_ctrl.text.trim()}". Try another username.',
                  style: const TextStyle(fontFamily: 'Arial', fontSize: 12, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < _users.length; i++) ...[
                  if (i > 0) const SizedBox(height: 6),
                  _UserResultCard(user: _users[i], stripe: i.isEven),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _UserResultCard extends StatelessWidget {
  final User user;
  final bool stripe;
  const _UserResultCard({required this.user, required this.stripe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/profile/${user.username}'),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: stripe ? RetroColors.tableRow : RetroColors.tableRowAlt,
            border: Border.all(color: const Color(0xFFE4EBF5), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F5FA),
                  border: Border.all(color: const Color(0xFFB4C6DF), width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty
                    ? Image.network(
                        user.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(child: PixelIcon.userIcon(size: 28)),
                      )
                    : Center(child: PixelIcon.userIcon(size: 28)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayHandle,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: RetroColors.link,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Text(
                      '@${user.username}',
                      style: const TextStyle(fontFamily: 'Arial', fontSize: 11, color: RetroColors.textSecondary),
                    ),
                    if (user.bio != null && user.bio!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.bio!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Arial', fontSize: 12, height: 1.35),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 10,
                      children: [
                        if (user.location != null)
                          Text(user.location!, style: const TextStyle(fontFamily: 'Arial', fontSize: 10, color: RetroColors.textSecondary)),
                        if (user.favoriteMedium != null)
                          Text(user.favoriteMedium!, style: const TextStyle(fontFamily: 'Arial', fontSize: 10, color: RetroColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const Text(
                'View Space >>',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: RetroColors.btnPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
