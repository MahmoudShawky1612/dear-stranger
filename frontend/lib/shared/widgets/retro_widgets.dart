import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/theme/app_theme.dart';

// ─── Retro beveled button ────────────────────────────────────────────────────
class RetroButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isSmall;

  const RetroButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = false,
    this.isSmall = false,
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final bg = disabled
        ? RetroColors.silver.withValues(alpha: 0.5)
        : widget.isPrimary
            ? RetroColors.marqueeBar
            : RetroColors.silver;
    final fg = widget.isPrimary ? RetroColors.white : RetroColors.textPrimary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            top: BorderSide(
              color: _pressed ? RetroColors.bevelDark : RetroColors.bevelLight,
              width: 2,
            ),
            left: BorderSide(
              color: _pressed ? RetroColors.bevelDark : RetroColors.bevelLight,
              width: 2,
            ),
            bottom: BorderSide(
              color: _pressed ? RetroColors.bevelLight : RetroColors.bevelDark,
              width: 2,
            ),
            right: BorderSide(
              color: _pressed ? RetroColors.bevelLight : RetroColors.bevelDark,
              width: 2,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isSmall ? 12 : 20,
          vertical: widget.isSmall ? 6 : 10,
        ),
        child: Text(
          widget.label,
          style: RetroTextStyles.pixel.copyWith(
            fontSize: widget.isSmall ? 7 : 8,
            color: disabled ? RetroColors.textSecondary : fg,
          ),
        ),
      ),
    );
  }
}

// ─── Retro card ──────────────────────────────────────────────────────────────
class RetroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const RetroCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? RetroColors.surface,
        border: Border.all(color: RetroColors.border, width: 2),
        boxShadow: const [BoxShadow(color: RetroColors.borderDark, offset: Offset(3, 3))],
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

// ─── Retro text field ────────────────────────────────────────────────────────
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
        Text(label, style: RetroTextStyles.label),
        const SizedBox(height: 4),
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

// ─── Retro divider ───────────────────────────────────────────────────────────
class RetroDivider extends StatelessWidget {
  final String? label;
  const RetroDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: List.generate(
            60,
            (i) => Expanded(
              child: Container(
                height: 1,
                color: i.isEven ? RetroColors.border : Colors.transparent,
              ),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: RetroColors.border, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '✦ $label ✦',
              style: RetroTextStyles.pixel.copyWith(
                fontSize: 7,
                color: RetroColors.textSecondary,
              ),
            ),
          ),
          const Expanded(child: Divider(color: RetroColors.border, thickness: 1)),
        ],
      ),
    );
  }
}

// ─── Status badge ────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'AVAILABLE' => ('[ AVAILABLE ]', RetroColors.gold),
      'CLAIMED'   => ('[ CLAIMED ]', RetroColors.accentLight),
      'DELIVERED' => ('[ DELIVERED ]', RetroColors.accent),
      _           => ('[ UNKNOWN ]', RetroColors.silver),
    };
    return Text(label, style: RetroTextStyles.pixel.copyWith(fontSize: 7, color: color));
  }
}

// ─── Loading widget ───────────────────────────────────────────────────────────
class RetroLoading extends StatelessWidget {
  final String? message;
  const RetroLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: RetroColors.accent,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: RetroTextStyles.pixel.copyWith(fontSize: 8, color: RetroColors.textSecondary),
            ),
          ],
        ],
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '⚠ ERROR',
              style: RetroTextStyles.pixel.copyWith(fontSize: 10, color: RetroColors.accent),
            ),
            const SizedBox(height: 8),
            Text(message, style: RetroTextStyles.body, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              RetroButton(label: 'RETRY', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Retro scaffold (app shell with nav) ─────────────────────────────────────
class RetroScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final ScrollController? scrollController;

  const RetroScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RetroColors.background,
      body: Column(
        children: [
          const _SiteHeader(),
          const _NavBar(),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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

// ─── Site header ─────────────────────────────────────────────────────────────
class _SiteHeader extends StatelessWidget {
  const _SiteHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: RetroColors.marqueeBar,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [
          Text(
            '★ DEAR STRANGER ★',
            style: RetroTextStyles.pixel.copyWith(
              fontSize: 16,
              color: RetroColors.white,
              shadows: [const Shadow(offset: Offset(2, 2), color: Colors.black45)],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            ':: a letter exchange for artists and dreamers ::',
            style: RetroTextStyles.typewriter.copyWith(
              fontSize: 12,
              color: RetroColors.silver,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Nav bar ──────────────────────────────────────────────────────────────────
class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    final isAuth = context.select<AuthProvider, bool>((a) => a.isAuthenticated);
    final notifs = context.watch<NotificationProvider>();

    return Container(
      width: double.infinity,
      color: RetroColors.borderDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const _NavLink('HOME', '/'),
            _navSep(),
            const _NavLink('BROWSE LETTERS', '/'),
            _navSep(),
            const _NavLink('WRITE A LETTER', '/letters/new'),
            _navSep(),
            const _NavLink('MY LETTERS', '/letters/mine'),
            _navSep(),
            const _NavLink('MY CLAIMED', '/letters/claimed'),
            _navSep(),
            const _NavLink('SETTINGS', '/settings'),
            if (isAuth) ...[
              _navSep(),
              _NotificationsNavButton(notifs: notifs),
            ],
          ],
        ),
      ),
    );
  }

  Widget _navSep() => Text(
        ' | ',
        style: RetroTextStyles.pixel.copyWith(fontSize: 7, color: RetroColors.silver),
      );
}

class _NotificationsNavButton extends StatelessWidget {
  final NotificationProvider notifs;
  const _NotificationsNavButton({required this.notifs});

  @override
  Widget build(BuildContext context) {
    final count = notifs.unreadCount;
    final hasUnread = count > 0;

    return GestureDetector(
      onTap: () => _showNotificationsDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: hasUnread ? RetroColors.gold.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: hasUnread ? RetroColors.gold : RetroColors.silver,
            width: 1,
          ),
        ),
        child: Text(
          hasUnread ? '🔔 ($count)' : '🔔 (0)',
          style: RetroTextStyles.pixel.copyWith(
            fontSize: 7,
            color: hasUnread ? RetroColors.gold : RetroColors.silver,
          ),
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return const _NotificationsDialog();
      },
    );
  }
}

class _NotificationsDialog extends StatelessWidget {
  const _NotificationsDialog();

  @override
  Widget build(BuildContext context) {
    final notifs = context.watch<NotificationProvider>();
    final items = notifs.notifications;
    final fmt = DateFormat('dd MMM, HH:mm');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
        child: RetroCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('🔔 NOTIFICATIONS', style: RetroTextStyles.h3),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text('[X]', style: RetroTextStyles.pixel.copyWith(fontSize: 8, color: RetroColors.accent)),
                  ),
                ],
              ),
              const RetroDivider(),
              const SizedBox(height: 4),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No notifications yet.',
                    style: RetroTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final item = items[i];
                      return GestureDetector(
                        onTap: () {
                          context.read<NotificationProvider>().markAsRead(item.id);
                          Navigator.of(context).pop();
                          context.go('/letters/${item.letterId}');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: item.isRead
                                ? RetroColors.background
                                : RetroColors.gold.withValues(alpha: 0.12),
                            border: Border.all(
                              color: item.isRead ? RetroColors.border : RetroColors.gold,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (!item.isRead) ...[
                                    Text('● ', style: RetroTextStyles.pixel.copyWith(fontSize: 8, color: RetroColors.gold)),
                                  ],
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: RetroTextStyles.pixel.copyWith(
                                        fontSize: 7,
                                        color: item.isRead ? RetroColors.textPrimary : RetroColors.gold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    fmt.format(item.createdAt),
                                    style: RetroTextStyles.small.copyWith(
                                      fontSize: 10,
                                      color: RetroColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.message,
                                style: RetroTextStyles.body.copyWith(fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final String path;
  const _NavLink(this.label, this.path);

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const baseColor = RetroColors.silver;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.path),
        child: Text(
          widget.label,
          style: RetroTextStyles.pixel.copyWith(
            fontSize: 7,
            color: _hovered ? RetroColors.accentLight : baseColor,
            decoration: _hovered ? TextDecoration.underline : null,
            decorationColor: RetroColors.accentLight,
          ),
        ),
      ),
    );
  }
}

// ─── Footer ──────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: RetroColors.borderDark,
      padding: const EdgeInsets.all(12),
      child: Text(
        '✦ Dear Stranger © 2026 ✦ Best viewed at 1024x768 ✦ No cookies were eaten in the making of this site ✦',
        style: RetroTextStyles.pixel.copyWith(fontSize: 6, color: RetroColors.silver),
        textAlign: TextAlign.center,
      ),
    );
  }
}
