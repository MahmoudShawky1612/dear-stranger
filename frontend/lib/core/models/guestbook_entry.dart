import 'user.dart';
import 'json_parse.dart';

class GuestbookEntry {
  final int id;
  final String message;
  final DateTime createdAt;
  final User author;

  const GuestbookEntry({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.author,
  });

  factory GuestbookEntry.fromJson(Map<String, dynamic> json) {
    final authorJson = asJsonMap(json['author']);
    return GuestbookEntry(
      id: asInt(json['id']),
      message: asString(json['message']),
      createdAt: asDateTimeRequired(json['createdAt']),
      author: authorJson != null
          ? User.fromJson(authorJson)
          : const User(id: 0, username: 'Unknown'),
    );
  }
}
