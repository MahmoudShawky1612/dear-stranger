import 'package:flutter_test/flutter_test.dart';
import 'package:dear_stranger/core/models/letter.dart';
import 'package:dear_stranger/core/models/reply.dart';

void main() {
  test('Letter.fromJson accepts null displayName, dates, and sender', () {
    final letter = Letter.fromJson({
      'id': 1,
      'title': 'Hello',
      'message': 'A note',
      'status': 'AVAILABLE',
      'isAnonymous': false,
      'isMine': false,
      'createdAt': '2026-09-09T12:00:00.000Z',
      'claimedAt': null,
      'deliveredAt': null,
      'sender': {
        'id': 2,
        'username': 'ada',
        'displayName': null,
      },
      'artist': null,
      'artwork': null,
    });

    expect(letter.title, 'Hello');
    expect(letter.sender?.username, 'ada');
    expect(letter.sender?.displayHandle, 'ada');
    expect(letter.claimedAt, isNull);
  });

  test('Reply.fromJson parses avatarUrl and handles anonymous author', () {
    final replyWithAvatar = Reply.fromJson({
      'id': 10,
      'message': 'Great artwork!',
      'createdAt': '2026-09-10T12:00:00.000Z',
      'author': {
        'id': 5,
        'username': 'artist1',
        'displayName': 'Awesome Artist',
        'avatarUrl': 'https://example.com/avatars/5/avatar.png',
      },
    });

    expect(replyWithAvatar.id, 10);
    expect(replyWithAvatar.author.displayHandle, 'Awesome Artist');
    expect(replyWithAvatar.author.avatarUrl, 'https://example.com/avatars/5/avatar.png');

    final anonymousReply = Reply.fromJson({
      'id': 11,
      'message': 'Thank you!',
      'createdAt': '2026-09-10T12:05:00.000Z',
      'author': {
        'id': 0,
        'username': 'Anonymous',
        'displayName': 'Anonymous',
        'avatarUrl': null,
      },
    });

    expect(anonymousReply.id, 11);
    expect(anonymousReply.author.id, 0);
    expect(anonymousReply.author.displayHandle, 'Anonymous');
    expect(anonymousReply.author.avatarUrl, isNull);
  });
}

