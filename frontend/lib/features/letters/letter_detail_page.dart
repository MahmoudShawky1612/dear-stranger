import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/api/image_upload.dart';
import '../../core/api/letter_socket.dart';
import '../../core/api/letters_api.dart';
import '../../core/models/letter.dart';
import '../../core/models/reply.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/retro_widgets.dart';

class LetterDetailPage extends StatefulWidget {
  final int letterId;
  const LetterDetailPage({super.key, required this.letterId});

  @override
  State<LetterDetailPage> createState() => _LetterDetailPageState();
}

class _LetterDetailPageState extends State<LetterDetailPage> {
  final _api = LettersApi();
  Letter? _letter;
  bool _loading = true;
  String? _error;

  String? _artworkUrl;
  bool _artworkLoading = false;

  final _replyCtrl = TextEditingController();
  bool _sendingReply = false;

  bool _claimLoading   = false;
  bool _uploadLoading  = false;
  bool _publishLoading = false;

  LetterSocket? _socket;
  StreamSubscription<Reply>? _socketSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    _socket?.dispose();
    _replyCtrl.dispose();
    super.dispose();
  }

  void _setupSocket(Letter l) {
    if (!l.isDelivered) return;
    if (_socket != null) return;
    _socket = LetterSocket(letterId: widget.letterId);
    _socketSub = _socket!.replies.listen((reply) {
      if (!mounted) return;
      setState(() {
        if (_letter == null) return;
        if (_letter!.replies.any((r) => r.id == reply.id)) return;
        _letter = Letter(
          id: _letter!.id,
          title: _letter!.title,
          message: _letter!.message,
          status: _letter!.status,
          isAnonymous: _letter!.isAnonymous,
          isMine: _letter!.isMine,
          createdAt: _letter!.createdAt,
          claimedAt: _letter!.claimedAt,
          deliveredAt: _letter!.deliveredAt,
          sender: _letter!.sender,
          artist: _letter!.artist,
          artwork: _letter!.artwork,
          replies: [..._letter!.replies, reply],
          replyCount: (_letter!.replyCount ?? _letter!.replies.length) + 1,
        );
      });
    });
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final l = await _api.getLetter(widget.letterId);
      if (!mounted) return;
      setState(() { _letter = l; _loading = false; });
      if (l.artwork != null) _loadArtworkUrl(l.artwork!.id);
      _setupSocket(l);
      if (mounted) {
        context.read<NotificationProvider>().markLetterAsRead(widget.letterId);
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _loadArtworkUrl(int artworkId) async {
    if (mounted) setState(() => _artworkLoading = true);
    try {
      final url = await _api.getArtworkUrl(artworkId);
      if (mounted) setState(() { _artworkUrl = url; _artworkLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _artworkLoading = false);
    }
  }

  Future<void> _claim() async {
    final letter = _letter;
    if (letter == null || letter.isMine) return;
    setState(() => _claimLoading = true);
    try {
      await _api.claimLetter(widget.letterId);
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _claimLoading = false);
    }
  }

  Future<void> _uploadArtwork() async {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a JPEG, PNG, or WebP image.')),
        );
      }
      return;
    }

    setState(() => _uploadLoading = true);
    try {
      await _api.uploadArtworkFile(
        letterId: widget.letterId,
        bytes: file.bytes!,
        contentType: contentType,
      );
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎨 Artwork delivered!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploadLoading = false);
    }
  }

  Future<void> _sendReply() async {
    final msg = _replyCtrl.text.trim();
    if (msg.isEmpty) return;
    setState(() => _sendingReply = true);
    try {
      final reply = await _api.sendReply(widget.letterId, msg);
      _replyCtrl.clear();
      setState(() {
        if (_letter != null && !_letter!.replies.any((r) => r.id == reply.id)) {
          _letter = Letter(
            id: _letter!.id,
            title: _letter!.title,
            message: _letter!.message,
            status: _letter!.status,
            isAnonymous: _letter!.isAnonymous,
            isMine: _letter!.isMine,
            createdAt: _letter!.createdAt,
            claimedAt: _letter!.claimedAt,
            deliveredAt: _letter!.deliveredAt,
            sender: _letter!.sender,
            artist: _letter!.artist,
            artwork: _letter!.artwork,
            replies: [..._letter!.replies, reply],
            replyCount: (_letter!.replyCount ?? _letter!.replies.length) + 1,
          );
        }
        _sendingReply = false;
      });
    } catch (e) {
      setState(() => _sendingReply = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _publishArtwork() async {
    setState(() => _publishLoading = true);
    try {
      await _api.publishArtwork(widget.letterId);
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🌍 Artwork shared with everyone!')));
    } catch (e) {
      setState(() => _publishLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = context.select<AuthProvider, int?>((a) => a.user?.id);

    if (_loading) return RetroScaffold(body: const RetroLoading(message: 'LOADING LETTER'));
    if (_error != null) return RetroScaffold(body: RetroError(_error!, onRetry: _load));
    final l = _letter!;

    final isSender = l.isMine || (me != null && l.sender?.id == me);
    final isArtist = me != null && l.artist?.id == me;
    final fmt = DateFormat('dd MMM yyyy, HH:mm');

    return RetroScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          GestureDetector(
            onTap: () => context.go('/'),
            child: Text(
              '« Back to the Mailboard',
              style: RetroTextStyles.link,
            ),
          ),
          const SizedBox(height: 12),

          // The letter itself
          RetroCard(
            title: 'THE LETTER',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        l.title,
                        style: RetroTextStyles.vt323.copyWith(fontSize: 26),
                      ),
                    ),
                    StatusBadge(l.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Written by: ${l.isAnonymous && !isSender ? 'Anonymous' : (l.sender?.displayHandle ?? (isSender ? 'You' : '?'))}  ·  ${fmt.format(l.createdAt)}',
                  style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary),
                ),
                const RetroDivider(),
                // Letter body on parchment-ish background
                Container(
                  width: double.infinity,
                  color: const Color(0xFFFFFDF5),
                  padding: const EdgeInsets.all(16),
                  child: Text(l.message, style: RetroTextStyles.typewriter.copyWith(fontSize: 15, height: 1.8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action panel
          if (l.isAvailable) ...[
            if (isSender)
              RetroCard(
                title: 'YOUR LETTER IS WAITING',
                titleBarColor: RetroColors.accentGold,
                child: Text(
                  'Your letter is posted on the mailboard. An artist will pick it up and draw something for you.',
                  style: RetroTextStyles.body,
                ),
              )
            else
              RetroCard(
                title: 'INTERESTED IN THIS LETTER?',
                titleBarColor: RetroColors.sectionHeaderPurple,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pick it up, draw something inspired by it, and deliver it back!',
                      style: RetroTextStyles.body,
                    ),
                    const SizedBox(height: 12),
                    _claimLoading
                        ? const RetroLoading(message: 'PICKING UP LETTER')
                        : RetroButton(
                            label: '► PICK IT UP ◄',
                            onPressed: _claim,
                            isPrimary: true,
                          ),
                  ],
                ),
              ),
          ] else if (l.isClaimed && isArtist) ...[
            RetroCard(
              title: '📎 ATTACH YOUR DRAWING',
              titleBarColor: RetroColors.sectionHeader,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paint or draw something inspired by this letter, then attach your image below.',
                    style: RetroTextStyles.body,
                  ),
                  const SizedBox(height: 12),
                  _uploadLoading
                      ? const RetroLoading(message: 'UPLOADING YOUR ART')
                      : RetroButton(
                          label: '📎 ATTACH YOUR DRAWING',
                          onPressed: _uploadArtwork,
                          isPrimary: true,
                        ),
                ],
              ),
            ),
          ] else if (l.artwork != null) ...[
            RetroCard(
              title: '🎨 THE ARTWORK',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!l.artwork!.isPublished && isArtist) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RetroButton(
                          label: '🌍 SHARE WITH EVERYONE',
                          onPressed: _publishLoading ? null : _publishArtwork,
                          isPrimary: true,
                          isSmall: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (l.artwork!.isPublished)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          color: RetroColors.accentGreen,
                          child: Text(
                            '★ PUBLISHED TO GALLERY ★',
                            style: RetroTextStyles.pixel.copyWith(fontSize: 6, color: RetroColors.white),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  if (_artworkLoading)
                    const RetroLoading(message: 'LOADING IMAGE')
                  else if (_artworkUrl != null)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: RetroColors.border, width: 2),
                      ),
                      child: Image.network(
                        _artworkUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            '[ IMAGE UNAVAILABLE ]',
                            style: RetroTextStyles.pixel.copyWith(fontSize: 8, color: RetroColors.textSecondary),
                          ),
                        ),
                      ),
                    )
                  else
                    Text('Artwork uploaded. Loading preview...', style: RetroTextStyles.body),
                ],
              ),
            ),
          ],

          // Reply thread — only for delivered letters
          if (l.isDelivered) ...[
            const SizedBox(height: 14),
            RetroCard(
              title: '💬 MESSAGES',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (l.replies.isEmpty)
                    Text(
                      'No messages yet. Start the conversation!',
                      style: RetroTextStyles.body.copyWith(
                        color: RetroColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    ...l.replies.asMap().entries.map(
                      (e) => _ReplyRow(reply: e.value, index: e.key, fmt: fmt),
                    ),

                  if (isSender || isArtist) ...[
                    const RetroDivider(label: 'YOUR REPLY'),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _replyCtrl,
                            maxLines: 3,
                            style: RetroTextStyles.typewriter.copyWith(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Your message:',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _sendingReply
                            ? const RetroLoading()
                            : RetroButton(
                                label: 'SEND REPLY »',
                                onPressed: _sendReply,
                                isPrimary: true,
                              ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReplyRow extends StatelessWidget {
  final dynamic reply;
  final int index;
  final DateFormat fmt;
  const _ReplyRow({required this.reply, required this.index, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isEven = index.isEven;
    return Container(
      color: isEven ? RetroColors.surface : const Color(0xFFF0F0F8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar placeholder (like old forum posts)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: RetroColors.pageBackground,
              border: Border.all(color: RetroColors.border, width: 1),
            ),
            child: Center(
              child: Text(
                (reply.author.displayHandle.isNotEmpty
                    ? reply.author.displayHandle[0].toUpperCase()
                    : '?'),
                style: RetroTextStyles.vt323.copyWith(
                  fontSize: 20,
                  color: RetroColors.sectionHeader,
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
                    Text(
                      reply.author.displayHandle,
                      style: RetroTextStyles.pixel.copyWith(
                        fontSize: 7,
                        color: RetroColors.sectionHeader,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fmt.format(reply.createdAt),
                      style: RetroTextStyles.small.copyWith(
                        color: RetroColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(reply.message, style: RetroTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
