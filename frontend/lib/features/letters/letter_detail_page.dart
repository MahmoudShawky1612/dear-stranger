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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🌍 Artwork published!')));
    } catch (e) {
      setState(() => _publishLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = context.select<AuthProvider, int?>((a) => a.user?.id);

    if (_loading) return RetroScaffold(body: const RetroLoading(message: 'LOADING LETTER...'));
    if (_error != null) return RetroScaffold(body: RetroError(_error!, onRetry: _load));
    final l = _letter!;

    final isSender = l.isMine || (me != null && l.sender?.id == me);
    final isArtist = me != null && l.artist?.id == me;
    final fmt = DateFormat('dd MMM yyyy, HH:mm');

    return RetroScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: Text('← BACK TO FEED', style: RetroTextStyles.link),
          ),
          const SizedBox(height: 16),

          // Letter card
          RetroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(l.title, style: RetroTextStyles.h2)),
                    StatusBadge(l.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Written by: ${l.isAnonymous && !isSender ? 'Anonymous' : (l.sender?.displayHandle ?? (isSender ? 'You' : '?'))} · ${fmt.format(l.createdAt)}',
                    style: RetroTextStyles.small.copyWith(color: RetroColors.textSecondary)),
                const RetroDivider(),
                Text(l.message, style: RetroTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Artwork section
          if (l.isAvailable) ...
            [
              if (isSender)
                RetroCard(
                  backgroundColor: RetroColors.background,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR LETTER', style: RetroTextStyles.h3),
                      const SizedBox(height: 8),
                      Text('You wrote this letter. It is waiting on the board for an artist to claim and illustrate it.', style: RetroTextStyles.body),
                    ],
                  ),
                )
              else
                RetroCard(
                  backgroundColor: RetroColors.background,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('INTERESTED IN THIS LETTER?', style: RetroTextStyles.h3),
                      const SizedBox(height: 8),
                      Text('Claim it, paint a picture, and deliver it back.', style: RetroTextStyles.body),
                      const SizedBox(height: 12),
                      _claimLoading
                          ? const RetroLoading(message: 'CLAIMING...')
                          : RetroButton(label: 'CLAIM THIS LETTER', onPressed: _claim, isPrimary: true),
                    ],
                  ),
                ),
            ]
          else if (l.isClaimed && isArtist) ...
            [
              RetroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('UPLOAD YOUR ARTWORK', style: RetroTextStyles.h3),
                    const SizedBox(height: 8),
                    Text('Paint something inspired by this letter, then upload it here.', style: RetroTextStyles.body),
                    const SizedBox(height: 12),
                    _uploadLoading
                        ? const RetroLoading(message: 'UPLOADING...')
                        : RetroButton(label: '📎 UPLOAD IMAGE', onPressed: _uploadArtwork, isPrimary: true),
                  ],
                ),
              ),
            ]
          else if (l.artwork != null) ...
            [
              RetroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('🎨 ARTWORK', style: RetroTextStyles.h3),
                        const Spacer(),
                        if (!l.artwork!.isPublished && isArtist)
                          RetroButton(
                            label: 'PUBLISH TO GALLERY',
                            onPressed: _publishLoading ? null : _publishArtwork,
                            isSmall: true,
                          ),
                        if (l.artwork!.isPublished)
                          Text('[ PUBLISHED ]', style: RetroTextStyles.pixel.copyWith(fontSize: 7, color: RetroColors.gold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_artworkLoading)
                      const RetroLoading(message: 'LOADING IMAGE...')
                    else if (_artworkUrl != null)
                      Image.network(
                        _artworkUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Text('Could not load image'),
                      )
                    else
                      Text('Artwork uploaded. Loading...', style: RetroTextStyles.body),
                  ],
                ),
              ),
            ],

          if (l.isDelivered) ...
            [
              const SizedBox(height: 16),
              // Reply thread
              RetroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💬 THREAD', style: RetroTextStyles.h3),
                    const RetroDivider(),
                    if (l.replies.isEmpty)
                      Text('No replies yet. Start the conversation!', style: RetroTextStyles.small.copyWith(fontStyle: FontStyle.italic))
                    else
                      ...l.replies.map((r) => _ReplyBubble(reply: r, fmt: fmt)),
                    if (isSender || isArtist) ...
                      [
                        const RetroDivider(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _replyCtrl,
                                maxLines: 3,
                                style: RetroTextStyles.typewriter.copyWith(fontSize: 14),
                                decoration: const InputDecoration(hintText: 'Write a reply...'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _sendingReply
                                ? const RetroLoading()
                                : RetroButton(label: 'SEND', onPressed: _sendReply, isPrimary: true),
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

class _ReplyBubble extends StatelessWidget {
  final dynamic reply;
  final DateFormat fmt;
  const _ReplyBubble({required this.reply, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(reply.author.displayHandle, style: RetroTextStyles.label.copyWith(color: RetroColors.accent)),
              const SizedBox(width: 8),
              Text(fmt.format(reply.createdAt), style: RetroTextStyles.small.copyWith(color: RetroColors.border)),
            ],
          ),
          const SizedBox(height: 4),
          Text(reply.message, style: RetroTextStyles.body),
        ],
      ),
    );
  }
}
