import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../api/notifications_api.dart';
import '../models/notification_item.dart';
import '../models/json_parse.dart';

const String kWsBaseUrl = 'ws://localhost:3000';

class NotificationProvider extends ChangeNotifier {
  final NotificationsApi _api = NotificationsApi();

  List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  bool _loading = false;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  bool _disposed = false;
  bool _connected = false;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;
  bool get loading => _loading;

  Future<void> init() async {
    if (_disposed) return;
    _loading = true;
    notifyListeners();

    try {
      final res = await _api.getNotifications();
      _notifications = res.notifications;
      _unreadCount = res.unreadCount;
    } catch (_) {
      // Ignore network errors on init
    } finally {
      _loading = false;
      notifyListeners();
    }

    _connectWebSocket();
  }

  void _connectWebSocket() {
    if (_connected || _disposed) return;
    try {
      _channel = WebSocketChannel.connect(Uri.parse(kWsBaseUrl));
      _connected = true;

      _sub = _channel!.stream.listen(
        (raw) {
          if (_disposed) return;
          try {
            final data = jsonDecode(raw as String) as Map<String, dynamic>;
            final type = asString(data['type']);

            if (type == 'unread_count') {
              _unreadCount = asInt(data['unreadCount']);
              notifyListeners();
            } else if (type == 'notification') {
              final notifMap = asJsonMap(data['notification']);
              if (notifMap != null) {
                final item = NotificationItem.fromJson(notifMap);
                _notifications = [item, ..._notifications.where((n) => n.id != item.id)];
              }
              if (data.containsKey('unreadCount')) {
                _unreadCount = asInt(data['unreadCount']);
              } else {
                _unreadCount++;
              }
              notifyListeners();
            }
          } catch (_) {}
        },
        onError: (_) {
          _connected = false;
        },
        onDone: () {
          _connected = false;
        },
        cancelOnError: false,
      );
    } catch (_) {
      _connected = false;
    }
  }

  Future<void> markAsRead(int id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      final updatedList = List<NotificationItem>.from(_notifications);
      updatedList[idx] = updatedList[idx].copyWith(isRead: true);
      _notifications = updatedList;
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
    }

    try {
      final newCount = await _api.markAsRead(id);
      _unreadCount = newCount;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markLetterAsRead(int letterId) async {
    bool changed = false;
    final updatedList = _notifications.map((n) {
      if (n.letterId == letterId && !n.isRead) {
        changed = true;
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    if (changed) {
      _notifications = updatedList;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }

    try {
      final newCount = await _api.markLetterAsRead(letterId);
      _unreadCount = newCount;
      notifyListeners();
    } catch (_) {}
  }

  void disconnect() {
    _connected = false;
    _sub?.cancel();
    _sub = null;
    _channel?.sink.close();
    _channel = null;
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    disconnect();
    super.dispose();
  }
}
