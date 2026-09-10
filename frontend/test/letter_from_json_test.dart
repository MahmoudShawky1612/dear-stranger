import 'package:flutter_test/flutter_test.dart';
import 'package:dear_stranger/core/models/letter.dart';

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
}
