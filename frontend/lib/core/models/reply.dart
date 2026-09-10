import 'user.dart';
import 'json_parse.dart';

class Reply {
  final int id;
  final String message;
  final DateTime createdAt;
  final User author;

  const Reply({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.author,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    final authorJson = asJsonMap(json['author']);
    return Reply(
      id: asInt(json['id']),
      message: asString(json['message']),
      createdAt: asDateTimeRequired(json['createdAt']),
      author: authorJson != null
          ? User.fromJson(authorJson)
          : const User(id: 0, username: 'Unknown'),
    );
  }
}
