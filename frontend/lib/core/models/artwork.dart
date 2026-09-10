import 'json_parse.dart';

class Artwork {
  final int id;
  final int letterId;
  final String storageKey;
  final String contentType;
  final int fileSizeBytes;
  final bool isAnonymous;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime createdAt;

  const Artwork({
    required this.id,
    required this.letterId,
    required this.storageKey,
    required this.contentType,
    required this.fileSizeBytes,
    required this.isAnonymous,
    required this.isPublished,
    this.publishedAt,
    required this.createdAt,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) => Artwork(
        id: asInt(json['id']),
        letterId: asInt(json['letterId']),
        storageKey: asString(json['storageKey']),
        contentType: asString(json['contentType']),
        fileSizeBytes: asInt(json['fileSizeBytes']),
        isAnonymous: asBool(json['isAnonymous']),
        isPublished: asBool(json['isPublished']),
        publishedAt: asDateTime(json['publishedAt']),
        createdAt: asDateTimeRequired(json['createdAt']),
      );
}
