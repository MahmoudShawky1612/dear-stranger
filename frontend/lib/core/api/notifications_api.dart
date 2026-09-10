import 'api_client.dart';
import '../models/notification_item.dart';
import '../models/json_parse.dart';

class NotificationsApi {
  final ApiClient _c;
  NotificationsApi() : _c = ApiClient.instance;

  Future<({List<NotificationItem> notifications, int unreadCount})> getNotifications() async {
    final d = await _c.get('/notifications');
    final list = asJsonMapList(d['notifications']);
    final notifications = list.map(NotificationItem.fromJson).toList();
    final unreadCount = asInt(d['unreadCount']);
    return (notifications: notifications, unreadCount: unreadCount);
  }

  Future<int> markAsRead(int id) async {
    final d = await _c.patch('/notifications/$id/read', {});
    return asInt(d['unreadCount']);
  }

  Future<int> markLetterAsRead(int letterId) async {
    final d = await _c.patch('/notifications/letters/$letterId/read', {});
    return asInt(d['unreadCount']);
  }
}
