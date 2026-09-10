import 'user.dart';
import 'artwork.dart';
import 'reply.dart';
import 'json_parse.dart';

class Letter {
  final int id;
  final String title;
  final String message;
  final String status;
  final bool isAnonymous;
  final bool isMine;
  final DateTime createdAt;
  final DateTime? claimedAt;
  final DateTime? deliveredAt;
  final User? sender;
  final User? artist;
  final Artwork? artwork;
  final List<Reply> replies;
  final int? replyCount;

  const Letter({
    required this.id,
    required this.title,
    required this.message,
    required this.status,
    required this.isAnonymous,
    this.isMine = false,
    required this.createdAt,
    this.claimedAt,
    this.deliveredAt,
    this.sender,
    this.artist,
    this.artwork,
    this.replies = const [],
    this.replyCount,
  });

  factory Letter.fromJson(Map<String, dynamic> json) {
    final senderJson = asJsonMap(json['sender']);
    final artistJson = asJsonMap(json['artist']);
    final artworkJson = asJsonMap(json['artwork']);
    final repliesJson = json['replies'];

    return Letter(
      id: asInt(json['id']),
      title: asString(json['title']),
      message: asString(json['message']),
      status: asString(json['status'], 'AVAILABLE'),
      isAnonymous: asBool(json['isAnonymous']),
      isMine: asBool(json['isMine']),
      createdAt: asDateTimeRequired(json['createdAt']),
      claimedAt: asDateTime(json['claimedAt']),
      deliveredAt: asDateTime(json['deliveredAt']),
      sender: senderJson != null ? User.fromJson(senderJson) : null,
      artist: artistJson != null ? User.fromJson(artistJson) : null,
      artwork: artworkJson != null ? Artwork.fromJson(artworkJson) : null,
      replies: repliesJson is List
          ? repliesJson
              .map((r) => asJsonMap(r))
              .whereType<Map<String, dynamic>>()
              .map(Reply.fromJson)
              .toList()
          : const [],
      replyCount: asIntOrNull(json['replyCount']),
    );
  }

  bool get isAvailable => status == 'AVAILABLE';
  bool get isClaimed   => status == 'CLAIMED';
  bool get isDelivered => status == 'DELIVERED';
}
