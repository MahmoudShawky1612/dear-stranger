import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/theme/app_theme.dart';


// ─── Win95-style beveled button ──────────────────────────────────────────────
class RetroButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isSmall;
  final bool isDanger;

  const RetroButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = false,
    this.isSmall = false,
    this.isDanger = false,
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _pressed = false;
  bool _hovered = false;

  Color get _bg {
    if (widget.onPressed == null) return RetroColors.silver.withValues(alpha: 0.5);
    if (widget.isDanger) return const Color(0xFFCC0000);
    if (widget.isPrimary) return RetroColors.headerBg;
    return RetroColors.silver;
  }

  Color get _fg {
    if (widget.onPressed == null) return RetroColors.borderDark;
    if (widget.isPrimary || widget.isDanger) return RetroColors.white;
    return RetroColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed?.call();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: Container(
          decoration: BoxDecoration(
            color: _hovered && !_pressed && widget.onPressed != null
                ? Color.lerp(_bg, Colors.white, 0.15)
                : _bg,
            border: Border(
              top: BorderSide(
                color: _pressed ? RetroColors.bevelDark : RetroColors.bevelHighlight,
                width: 2,
              ),
              left: BorderSide(
                color: _pressed ? RetroColors.bevelDark : RetroColors.bevelHighlight,
                width: 2,
              ),
              bottom: BorderSide(
                color: _pressed ? RetroColors.bevelHighlight : RetroColors.bevelShadow,
                width: 2,
              ),
              right: BorderSide(
                color: _pressed ? RetroColors.bevelHighlight : RetroColors.bevelShadow,
                width: 2,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSmall ? 10 : 16,
            vertical: widget.isSmall ? 5 : 8,
          ),
          child: Text(
            widget.label,
            style: RetroTextStyles.pixel.copyWith(
              fontSize: widget.isSmall ? 7 : 8,
              color: _fg,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── White panel card (like early web content panels) ────────────────────────
class RetroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final String? title;
  final Color? titleBarColor;

  const RetroCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.title,
    this.titleBarColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? RetroColors.surface,
        border: Border.all(color: RetroColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Container(
              width: double.infinity,
              color: titleBarColor ?? RetroColors.sectionHeader,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                '■ $title',
                style: RetroTextStyles.sectionTitle.copyWith(fontSize: 16),
              ),
            ),
          Padding(
            padding: padding ?? const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: content),
      );
    }
    return content;
  }
}

// ─── Retro text field (classic HTML form style) ───────────────────────────────
class RetroTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const RetroTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: RetroTextStyles.pixel.copyWith(fontSize: 7, color: RetroColors.textPrimary)),
        const SizedBox(height: 3),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          validator: validator,
          keyboardType: keyboardType,
          style: RetroTextStyles.typewriter.copyWith(fontSize: 14),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

// ─── HR-style divider (exact early web look) ─────────────────────────────────
class RetroDivider extends StatelessWidget {
  final String? label;
  const RetroDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(color: RetroColors.borderDark, thickness: 1, height: 1),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Expanded(child: Divider(color: RetroColors.borderDark, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '[ $label ]',
              style: RetroTextStyles.pixel.copyWith(
                fontSize: 7,
                color: RetroColors.textSecondary,
              ),
            ),
          ),
          const Expanded(child: Divider(color: RetroColors.borderDark, thickness: 1)),
        ],
      ),
    );
  }
}

// ─── Status badge (early web pill style) ─────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      'AVAILABLE' => ('✦ OPEN ✦', const Color(0xFFFF9900), RetroColors.white),
      'CLAIMED'   => ('► IN PROGRESS ◄', RetroColors.sectionHeader, RetroColors.white),
      'DELIVERED' => ('★ DELIVERED ★', const Color(0xFF006600), RetroColors.white),
      _           => ('? UNKNOWN ?', RetroColors.borderDark, RetroColors.white),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      color: bg,
      child: Text(
        label,
        style: RetroTextStyles.pixel.copyWith(fontSize: 6, color: fg),
      ),
    );
  }
}

// ─── Loading widget (ASCII / text style) ─────────────────────────────────────
class RetroLoading extends StatefulWidget {
  final String? message;
  const RetroLoading({super.key, this.message});

  @override
  State<RetroLoading> createState() => _RetroLoadingState();
}

class _RetroLoadingState extends State<RetroLoading> {
  late Timer _timer;
  int _dots = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) setState(() => _dots = (_dots + 1) % 4);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message ?? 'PLEASE WAIT';
    final dotsStr = '.' * _dots + ' ' * (3 - _dots);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '[ $msg$dotsStr ]',
          style: RetroTextStyles.pixel.copyWith(
            fontSize: 8,
            color: RetroColors.sectionHeader,
          ),
        ),
      ),
    );
  }
}

// ─── Error widget ─────────────────────────────────────────────────────────────
class RetroError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const RetroError(this.message, {super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RetroCard(
        title: '⚠ ERROR',
        titleBarColor: RetroColors.accent,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: RetroTextStyles.body, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              RetroButton(label: '↺ TRY AGAIN', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Blinking NEW badge ───────────────────────────────────────────────────────
class BlinkingBadge extends StatefulWidget {
  final String text;
  final Color color;
  const BlinkingBadge({super.key, required this.text, this.color = RetroColors.accent});

  @override
  State<BlinkingBadge> createState() => _BlinkingBadgeState();
}

class _BlinkingBadgeState extends State<BlinkingBadge> {
  late Timer _timer;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (mounted) setState(() => _visible = !_visible);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        color: widget.color,
        child: Text(
          widget.text,
          style: RetroTextStyles.pixel.copyWith(
            fontSize: 6,
            color: RetroColors.white,
          ),
        ),
      ),
    );
  }
}

// ─── Marquee ticker ───────────────────────────────────────────────────────────
class MarqueeTicker extends StatefulWidget {
  final List<String> items;
  const MarqueeTicker({super.key, required this.items});

  @override
  State<MarqueeTicker> createState() => _MarqueeTickerState();
}

class _MarqueeTickerState extends State<MarqueeTicker> {
  late final ScrollController _ctrl;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  void _startScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!_ctrl.hasClients) return;
      final max = _ctrl.position.maxScrollExtent;
      final cur = _ctrl.offset;
      if (cur >= max) {
        _ctrl.jumpTo(0);
      } else {
        _ctrl.jumpTo(cur + 1.5);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final text = widget.items.map((e) => '★ $e').join('   •   ');
    return Container(
      color: RetroColors.headerBg,
      height: 22,
      child: SingleChildScrollView(
        controller: _ctrl,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            '$text   $text   $text',
            style: RetroTextStyles.marquee,
          ),
        ),
      ),
    );
  }
}

// ─── Full app scaffold (shell with header, nav, sidebar, footer) ──────────────
class RetroScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final ScrollController? scrollController;
  final bool showSidebar;

  const RetroScaffold({
    super.key,
    required this.body,
    this.title,
    this.scrollController,
    this.showSidebar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RetroColors.pageBackground,
      body: Column(
        children: [
          const _SiteHeader(),
          const _NavBar(),
          const _MarqueeBar(),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: showSidebar
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Sidebar(),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: body,
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: body,
                        ),
                ),
              ),
            ),
          ),
          const _Footer(),
        ],
      ),
    );
  }
}

// ─── Site header banner ───────────────────────────────────────────────────────
class _SiteHeader extends StatelessWidget {
  const _SiteHeader();

  @override
  Widget build(BuildContext context) {
    final notifs = context.watch<NotificationProvider>();
    final unread = notifs.unreadCount;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF000060), Color(0xFF0000CC), Color(0xFF000060)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          // Logo / site name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '★ dear stranger ★',
                  style: RetroTextStyles.vt323.copyWith(
                    fontSize: 32,
                    color: RetroColors.white,
                    shadows: [
                      const Shadow(offset: Offset(2, 2), color: Color(0xFF000033)),
                      const Shadow(offset: Offset(-1, -1), color: Color(0xFF6666FF)),
                    ],
                  ),
                ),
                Text(
                  ':: a letter exchange for artists & dreamers since 2024 ::',
                  style: RetroTextStyles.typewriter.copyWith(
                    fontSize: 11,
                    color: RetroColors.silver,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // Top-right: notification bell
          if (unread > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BlinkingBadge(text: '✉ YOU HAVE MAIL', color: RetroColors.accent),
                const SizedBox(height: 4),
                Text(
                  '$unread unread',
                  style: RetroTextStyles.typewriter.copyWith(fontSize: 10, color: RetroColors.silver),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Marquee activity bar ─────────────────────────────────────────────────────
class _MarqueeBar extends StatelessWidget {
  const _MarqueeBar();

  @override
  Widget build(BuildContext context) {
    return const MarqueeTicker(
      items: [
        'New letters are waiting on the mailboard!',
        'Drop a letter · an artist will illustrate it for you',
        'Best experienced at 1024×768 resolution',
        'Join now — it\'s FREE!',
        'New artworks delivered today!',
      ],
    );
  }
}

// ─── Navigation bar (tab-style) ───────────────────────────────────────────────
class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    final isAuth = context.select<AuthProvider, bool>((a) => a.isAuthenticated);
    final notifs = context.watch<NotificationProvider>();

    return Container(
      width: double.infinity,
      color: RetroColors.navBg,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _NavTab(label: 'HOME', path: '/'),
            _NavTab(label: 'THE MAILBOARD', path: '/'),
            _NavTab(label: 'DROP A LETTER', path: '/letters/new'),
            if (isAuth) ...[
              _NavTab(label: 'MY SENT MAIL', path: '/letters/mine'),
              _NavTab(label: 'MY CLAIMS', path: '/letters/claimed'),
              _NavTab(label: 'MY SPACE', path: '/settings'),
            ],
            if (!isAuth) ...[
              _NavTab(label: 'SIGN IN', path: '/login'),
              _NavTab(label: 'JOIN FREE!', path: '/register', isHighlight: true),
            ],
            if (isAuth)
              _NotificationsNavButton(notifs: notifs),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatefulWidget {
  final String label;
  final String path;
  final bool isHighlight;
  const _NavTab({required this.label, required this.path, this.isHighlight = false});

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final isActive = currentPath == widget.path && widget.path != '/';

    Color bg;
    Color fg;
    if (isActive) {
      bg = RetroColors.navActive;
      fg = RetroColors.white;
    } else if (widget.isHighlight) {
      bg = _hovered ? const Color(0xFFFFCC00) : const Color(0xFFFF9900);
      fg = RetroColors.textPrimary;
    } else if (_hovered) {
      bg = RetroColors.navHover;
      fg = RetroColors.white;
    } else {
      bg = Colors.transparent;
      fg = RetroColors.silver;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.path),
        child: Container(
          color: bg,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            widget.label,
            style: RetroTextStyles.navLink.copyWith(color: fg, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

// ─── Notification bell nav button ─────────────────────────────────────────────
class _NotificationsNavButton extends StatelessWidget {
  final NotificationProvider notifs;
  const _NotificationsNavButton({required this.notifs});

  @override
  Widget build(BuildContext context) {
    final count = notifs.unreadCount;
    final hasUnread = count > 0;

    return GestureDetector(
      onTap: () => _showNotificationsDialog(context),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: hasUnread ? RetroColors.accent : const Color(0xFF220044),
            border: Border.all(
              color: hasUnread ? const Color(0xFFFF6666) : RetroColors.navHover,
              width: 1,
            ),
          ),
          child: Text(
            hasUnread ? '✉ MAIL ($count)' : '✉ MAIL',
            style: RetroTextStyles.vt323.copyWith(
              fontSize: 15,
              color: hasUnread ? RetroColors.white : RetroColors.silver,
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => const _NotificationsDialog(),
    );
  }
}

// ─── Notifications dialog ─────────────────────────────────────────────────────
class _NotificationsDialog extends StatefulWidget {
  const _NotificationsDialog();

  @override
  State<_NotificationsDialog> createState() => _NotificationsDialogState();
}

class _NotificationsDialogState extends State<_NotificationsDialog> {
  @override
  Widget build(BuildContext context) {
    final notifs = context.watch<NotificationProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Container(
              width: double.infinity,
              color: RetroColors.headerBg,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '✉ YOUR MAILBOX',
                    style: RetroTextStyles.vt323.copyWith(fontSize: 18, color: RetroColors.white),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      '[X]',
                      style: RetroTextStyles.pixel.copyWith(fontSize: 8, color: RetroColors.silver),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Container(
              color: RetroColors.surface,
              child: notifs.notifications.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No new mail. Check back later!',
                        style: RetroTextStyles.body.copyWith(color: RetroColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 420),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: notifs.notifications.length,
                        itemBuilder: (ctx, i) {
                          final n = notifs.notifications[i];
                          final isUnread = !n.isRead;
                          return GestureDetector(
                            onTap: () async {
                              await notifs.markAsRead(n.id);
                              if (ctx.mounted) {
                                Navigator.of(ctx).pop();
                                ctx.go('/letters/${n.letterId}');
                              }
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                color: isUnread
                                    ? const Color(0xFFFFF8E0)
                                    : (i.isEven ? RetroColors.surface : const Color(0xFFF5F5F5)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isUnread ? '✉ ' : '· ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isUnread ? RetroColors.accent : RetroColors.borderDark,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n.title,
                                            style: RetroTextStyles.pixel.copyWith(
                                              fontSize: 7,
                                              color: isUnread ? RetroColors.accent : RetroColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(n.message, style: RetroTextStyles.small),
                                        ],
                                      ),
                                    ),
                                    if (isUnread)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        color: RetroColors.accentOrange,
                                        child: Text(
                                          'NEW',
                                          style: RetroTextStyles.pixel.copyWith(fontSize: 5, color: RetroColors.white),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            // Footer
            Container(
              width: double.infinity,
              color: RetroColors.pageBackground,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${notifs.unreadCount} unread',
                    style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text('» Close', style: RetroTextStyles.linkSmall),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Left sidebar ("getting around") ─────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    final isAuth = context.select<AuthProvider, bool>((a) => a.isAuthenticated);
    final user = context.select<AuthProvider, dynamic>((a) => a.user);

    return Container(
      width: 150,
      constraints: const BoxConstraints(minHeight: 400),
      decoration: const BoxDecoration(
        color: RetroColors.sidebarBg,
        border: Border(right: BorderSide(color: RetroColors.sidebarDark, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Getting around section
          _SidebarSection(
            title: 'GETTING AROUND',
            children: [
              _SidebarLink(label: '» Home', path: '/'),
              _SidebarLink(label: '» The Mailboard', path: '/'),
              _SidebarLink(label: '» Drop a Letter', path: '/letters/new'),
              if (isAuth) ...[
                _SidebarLink(label: '» My Sent Mail', path: '/letters/mine'),
                _SidebarLink(label: '» My Claims', path: '/letters/claimed'),
              ],
            ],
          ),
          if (isAuth) ...[
            _SidebarSection(
              title: 'MY ACCOUNT',
              children: [
                if (user != null)
                  _SidebarLink(label: '» My Space', path: '/settings'),
                if (user != null)
                  _SidebarLink(label: '» My Profile', path: '/profile/${user.username}'),
              ],
            ),
          ],
          _SidebarSection(
            title: 'WHAT IS THIS?',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'A place to write letters to strangers and receive hand-drawn art in return.',
                  style: RetroTextStyles.small.copyWith(
                    fontSize: 10,
                    color: RetroColors.textOnSidebar,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          // Online counter
          Container(
            color: RetroColors.sidebarDark,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ONLINE NOW',
                  style: RetroTextStyles.pixel.copyWith(fontSize: 6, color: RetroColors.accentGold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(width: 8, height: 8, color: const Color(0xFF00FF00)),
                    const SizedBox(width: 4),
                    Text(
                      '${DateTime.now().second % 12 + 3} users',
                      style: RetroTextStyles.small.copyWith(fontSize: 10, color: RetroColors.textOnSidebar),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SidebarSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: RetroColors.sidebarDark,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(
            title,
            style: RetroTextStyles.pixel.copyWith(fontSize: 6, color: RetroColors.accentGold),
          ),
        ),
        ...children,
        const SizedBox(height: 4),
      ],
    );
  }
}

class _SidebarLink extends StatefulWidget {
  final String label;
  final String path;
  const _SidebarLink({required this.label, required this.path});

  @override
  State<_SidebarLink> createState() => _SidebarLinkState();
}

class _SidebarLinkState extends State<_SidebarLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.path),
        child: Container(
          color: _hovered ? RetroColors.sidebarDark.withValues(alpha: 0.6) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            widget.label,
            style: RetroTextStyles.small.copyWith(
              fontSize: 11,
              color: _hovered ? RetroColors.white : RetroColors.textOnSidebar,
              decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
              decorationColor: RetroColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF222244),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [
          // Links row
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            children: [
              _FooterLink('about'),
              const Text(' · ', style: TextStyle(color: RetroColors.silver, fontSize: 11)),
              _FooterLink('contact'),
              const Text(' · ', style: TextStyle(color: RetroColors.silver, fontSize: 11)),
              _FooterLink('terms'),
              const Text(' · ', style: TextStyle(color: RetroColors.silver, fontSize: 11)),
              _FooterLink('privacy'),
              const Text(' · ', style: TextStyle(color: RetroColors.silver, fontSize: 11)),
              _FooterLink('site map'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '© ${DateTime.now().year} Dear Stranger · Best viewed at 1024×768 · Made with ♥ on the web',
            style: RetroTextStyles.small.copyWith(fontSize: 9, color: RetroColors.borderDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  const _FooterLink(this.label);

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Text(
        '• ${widget.label}',
        style: RetroTextStyles.small.copyWith(
          fontSize: 10,
          color: _hovered ? RetroColors.white : RetroColors.silver,
          decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
          decorationColor: RetroColors.white,
        ),
      ),
    );
  }
}
