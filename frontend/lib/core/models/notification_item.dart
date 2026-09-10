import 'json_parse.dart';

class NotificationItem {
  final int id;
  final int letterId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.letterId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: asInt(json['id']),
      letterId: asInt(json['letterId']),
      type: asString(json['type']),
      title: asString(json['title']),
      message: asString(json['message']),
      isRead: asBool(json['isRead']),
      createdAt: asDateTimeRequired(json['createdAt']),
    );
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      letterId: letterId,
      type: type,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
