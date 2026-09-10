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

    if (_loading) return RetroScaffold(body: const RetroLoading(message: 'Loading letter details'));
    if (_error != null) return RetroScaffold(body: RetroError(_error!, onRetry: _load));
    final l = _letter!;

    final isSender = l.isMine || (me != null && l.sender?.id == me);
    final isArtist = me != null && l.artist?.id == me;
    final fmt = DateFormat('MMM dd, yyyy, HH:mm');

    return RetroScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          GestureDetector(
            onTap: () => context.go('/'),
            child: const MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                '« Back to Mail Board',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 11,
                  color: RetroColors.link,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // The letter card
          RetroCard(
            title: 'The Letter',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PixelIcon.doc(size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.title,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: RetroColors.headerBg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(l.status),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    PixelIcon.userIcon(size: 11, color: RetroColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Written by: ',
                      style: TextStyle(fontFamily: 'Arial', fontSize: 11, color: RetroColors.textSecondary),
                    ),
                    Text(
                      l.isAnonymous && !isSender ? 'Anonymous' : (l.sender?.displayHandle ?? (isSender ? 'You' : 'Unknown')),
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: l.isAnonymous && !isSender ? RetroColors.textSecondary : RetroColors.link,
                      ),
                    ),
                    const Spacer(),
                    PixelIcon.calendar(size: 11),
                    const SizedBox(width: 4),
                    Text(
                      fmt.format(l.createdAt),
                      style: const TextStyle(fontFamily: 'Arial', fontSize: 10, color: RetroColors.textSecondary),
                    ),
                  ],
                ),
                const RetroDivider(),
                // Letter body in typewriter font
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFF8),
                    border: Border.all(color: const Color(0xFFE8E8E0), width: 1),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    l.message,
                    style: RetroTextStyles.typewriter.copyWith(fontSize: 13, height: 1.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action panel
          if (l.isAvailable) ...[
            if (isSender)
              const RetroCard(
                title: 'Letter Status: Waiting on Mailboard',
                titleBarColor: Color(0xFF446699),
                child: Text(
                  'Your letter is currently waiting on the mailboard. When an artist claims it, you will receive a notification in your mailbox.',
                  style: TextStyle(fontFamily: 'Arial', fontSize: 12, height: 1.4),
                ),
              )
            else
              RetroCard(
                title: 'Claim This Letter',
                titleBarColor: RetroColors.sectionHeader,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Are you inspired by this letter? Pick it up to create an illustration for this stranger!',
                      style: TextStyle(fontFamily: 'Arial', fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    _claimLoading
                        ? const RetroLoading(message: 'Claiming letter')
                        : RetroButton(
                            label: 'Claim This Letter to Illustrate >>',
                            onPressed: _claim,
                            isPrimary: true,
                            icon: PixelIcon.palette(size: 13),
                          ),
                  ],
                ),
              ),
          ] else if (l.isClaimed && isArtist) ...[
            RetroCard(
              title: 'Attach Artwork',
              titleBarColor: RetroColors.sectionHeader,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Paint or draw something inspired by this letter, then upload your artwork file below (JPEG, PNG, or WebP).',
                    style: TextStyle(fontFamily: 'Arial', fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  _uploadLoading
                      ? const RetroLoading(message: 'Uploading artwork')
                      : RetroButton(
                          label: 'Attach Artwork File >>',
                          onPressed: _uploadArtwork,
                          isPrimary: true,
                          icon: PixelIcon.palette(size: 13),
                        ),
                ],
              ),
            ),
          ] else if (l.artwork != null) ...[
            RetroCard(
              title: 'Original Artwork',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!l.artwork!.isPublished && isArtist) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RetroButton(
                          label: 'Publish to Public Gallery >>',
                          onPressed: _publishLoading ? null : _publishArtwork,
                          isPrimary: true,
                          isSmall: true,
                          icon: PixelIcon.star(size: 11),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PixelIcon.star(size: 10),
                              const SizedBox(width: 4),
                              const Text(
                                'PUBLISHED TO PUBLIC GALLERY',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: RetroColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  if (_artworkLoading)
                    const RetroLoading(message: 'Loading image')
                  else if (_artworkUrl != null)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: RetroColors.border, width: 1),
                      ),
                      child: Image.network(
                        _artworkUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            '[ Image could not be loaded ]',
                            style: TextStyle(fontFamily: 'Arial', fontSize: 11, color: RetroColors.textSecondary),
                          ),
                        ),
                      ),
                    )
                  else
                    const Text('Artwork uploaded. Loading preview...', style: TextStyle(fontFamily: 'Arial', fontSize: 12)),
                ],
              ),
            ),
          ],

          // Reply thread — only for delivered letters
          if (l.isDelivered) ...[
            const SizedBox(height: 12),
            RetroCard(
              title: 'Correspondence & Messages',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (l.replies.isEmpty)
                    const Text(
                      'No messages yet. Send a response to the artist!',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        color: RetroColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    ...l.replies.asMap().entries.map(
                      (e) {
                        final reply = e.value;
                        final isReplyByMe = me != null && reply.author.id == me;
                        final isReplyAuthorSender = isSender
                            ? isReplyByMe
                            : (reply.author.username.toLowerCase() == 'anonymous' ||
                                reply.author.id == 0 ||
                                (l.sender != null && reply.author.id == l.sender!.id));
                        return _ReplyRow(
                          reply: reply,
                          index: e.key,
                          fmt: fmt,
                          isLetterAnonymous: l.isAnonymous,
                          isMe: isReplyByMe,
                          isReplyAuthorSender: isReplyAuthorSender,
                        );
                      },
                    ),

                  if (isSender || isArtist) ...[
                    const RetroDivider(label: 'SEND A MESSAGE'),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _replyCtrl,
                            maxLines: 3,
                            style: const TextStyle(fontFamily: 'Arial', fontSize: 12),
                            decoration: const InputDecoration(
                              hintText: 'Type your message here...',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _sendingReply
                            ? const RetroLoading()
                            : RetroButton(
                                label: 'Send Reply >>',
                                onPressed: _sendReply,
                                isPrimary: true,
                                icon: PixelIcon.chat(size: 12),
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
  final Reply reply;
  final int index;
  final DateFormat fmt;
  final bool isLetterAnonymous;
  final bool isMe;
  final bool isReplyAuthorSender;

  const _ReplyRow({
    required this.reply,
    required this.index,
    required this.fmt,
    required this.isLetterAnonymous,
    required this.isMe,
    required this.isReplyAuthorSender,
  });

  @override
  Widget build(BuildContext context) {
    final isEven = index.isEven;
    final isAnonymousAuthor = isLetterAnonymous && isReplyAuthorSender;

    final String authorName;
    if (isAnonymousAuthor) {
      authorName = isMe ? 'You (Anonymous)' : 'Anonymous';
    } else {
      authorName = isMe ? 'You' : reply.author.displayHandle;
    }

    final hasAvatar = !isAnonymousAuthor &&
        reply.author.avatarUrl != null &&
        reply.author.avatarUrl!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isEven ? RetroColors.tableRow : RetroColors.tableRowAlt,
        border: Border.all(color: const Color(0xFFE4EBF5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar box
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFD5E4F7),
              border: Border.all(color: RetroColors.border, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasAvatar
                ? Image.network(
                    reply.author.avatarUrl!,
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
                    Text(
                      authorName,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isAnonymousAuthor
                            ? RetroColors.textSecondary
                            : RetroColors.link,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fmt.format(reply.createdAt),
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: RetroColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(reply.message, style: const TextStyle(fontFamily: 'Arial', fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


