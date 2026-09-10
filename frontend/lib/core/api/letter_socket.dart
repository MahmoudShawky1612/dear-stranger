import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/reply.dart';
import '../models/user.dart';
import '../models/json_parse.dart';

const String kWsBaseUrl = 'ws://localhost:3000';

/// Manages a WebSocket connection for real-time replies on a specific letter.
///
/// Usage:
///   final socket = LetterSocket(letterId: 42);
///   socket.replies.listen((reply) => ...);
///   // When done:
///   socket.dispose();
class LetterSocket {
  final int letterId;

  WebSocketChannel? _channel;
  final _replyController = StreamController<Reply>.broadcast();
  bool _disposed = false;

  LetterSocket({required this.letterId}) {
    _connect();
  }

  /// Stream of new Reply objects pushed from the server in real time.
  Stream<Reply> get replies => _replyController.stream;

  void _connect() {
    try {
      // The browser's native WebSocket automatically sends cookies for the
      // same origin — no extra auth header is needed.
      _channel = WebSocketChannel.connect(
        Uri.parse(kWsBaseUrl),
      );

      // Once connected, join the letter room
      _channel!.ready.then((_) {
        if (_disposed) return;
        _channel!.sink.add(jsonEncode({
          'type': 'join_letter',
          'letterId': letterId,
        }));
      }).catchError((_) {
        // Connection failed silently — caller can retry by creating a new instance
      });

      _channel!.stream.listen(
        (raw) {
          if (_disposed) return;
          try {
            final data = jsonDecode(raw as String) as Map<String, dynamic>;
            if (data['type'] == 'new_reply') {
              final replyMap = asJsonMap(data['reply']);
              if (replyMap != null) {
                final authorMap = asJsonMap(replyMap['author']);
                final reply = Reply(
                  id: asInt(replyMap['id']),
                  message: asString(replyMap['message']),
                  createdAt: asDateTimeRequired(replyMap['createdAt']),
                  author: authorMap != null
                      ? User.fromJson(authorMap)
                      : const User(id: 0, username: 'Unknown'),
                );
                _replyController.add(reply);
              }
            }
          } catch (_) {
            // Ignore malformed messages
          }
        },
        onError: (_) {
          // Ignore connection errors silently
        },
        onDone: () {
          // Channel closed; stream ends naturally
        },
        cancelOnError: false,
      );
    } catch (_) {
      // Ignore connection setup failures
    }
  }

  void _send(Map<String, dynamic> payload) {
    try {
      _channel?.sink.add(jsonEncode(payload));
    } catch (_) {}
  }

  /// Close the WebSocket connection and release resources.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _send({'type': 'leave_letter', 'letterId': letterId});
    _channel?.sink.close();
    _replyController.close();
  }
}
