import 'json_parse.dart';

class GalleryItem {
  final int id;
  final int letterId;
  final String letterTitle;
  final String url;
  final DateTime? publishedAt;
  final DateTime createdAt;

  const GalleryItem({
    required this.id,
    required this.letterId,
    required this.letterTitle,
    required this.url,
    this.publishedAt,
    required this.createdAt,
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json) => GalleryItem(
        id: asInt(json['id']),
        letterId: asInt(json['letterId']),
        letterTitle: asString(json['letterTitle']),
        url: asString(json['url']),
        publishedAt: asDateTime(json['publishedAt']),
        createdAt: asDateTimeRequired(json['createdAt']),
      );
}
