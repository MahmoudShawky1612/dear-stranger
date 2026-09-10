import 'json_parse.dart';

class User {
  final int id;
  final String username;
  final String? email;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;
  final String? location;
  final String? favoriteMedium;
  final String? currentlyDrawing;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.username,
    this.email,
    this.displayName,
    this.bio,
    this.avatarUrl,
    this.location,
    this.favoriteMedium,
    this.currentlyDrawing,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final displayName = asStringOrNull(json['displayName']);
    return User(
        id: asInt(json['id']),
        username: asString(json['username'], 'unknown'),
        email: asStringOrNull(json['email']),
        displayName: (displayName == null || displayName.isEmpty) ? null : displayName,
        bio: asStringOrNull(json['bio']),
        avatarUrl: asStringOrNull(json['avatarUrl']),
        location: asStringOrNull(json['location']),
        favoriteMedium: asStringOrNull(json['favoriteMedium']),
        currentlyDrawing: asStringOrNull(json['currentlyDrawing']),
        createdAt: asDateTime(json['createdAt']),
      );
  }

  String get displayHandle => (displayName != null && displayName!.isNotEmpty)
      ? displayName!
      : username;
}
