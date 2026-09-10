import 'api_client.dart';
import '../models/user.dart';
import '../models/guestbook_entry.dart';
import '../models/json_parse.dart';

class UsersApi {
  final ApiClient _c;
  UsersApi() : _c = ApiClient.instance;

  User _parseUser(Map<String, dynamic> d) {
    final map = asJsonMap(d['user']);
    if (map == null) {
      throw const ApiException(500, 'Invalid user response');
    }
    return User.fromJson(map);
  }

  Future<User> getPublicProfile(String username) async {
    final d = await _c.get('/users/$username');
    return _parseUser(d);
  }

  Future<User> updateProfile(Map<String, dynamic> fields) async {
    final d = await _c.patch('/users/me', fields);
    return _parseUser(d);
  }

  Future<Map<String, dynamic>> requestAvatarUploadUrl({required String contentType, required int fileSizeBytes}) =>
    _c.post('/users/me/avatar/upload-url', {'contentType': contentType, 'fileSizeBytes': fileSizeBytes});

  Future<User> uploadAvatarFile({required List<int> bytes, required String contentType}) async {
    final d = await _c.postBytes('/users/me/avatar/file', bytes, contentType);
    return _parseUser(d);
  }

  Future<User> completeAvatarUpload(String storageKey) async {
    final d = await _c.post('/users/me/avatar/complete', {'storageKey': storageKey});
    return _parseUser(d);
  }

  Future<void> removeAvatar() => _c.delete('/users/me/avatar');

  Future<List<GuestbookEntry>> getGuestbook(String username, {int limit = 20, int? cursor}) async {
    final q = <String, String>{'limit': '$limit'};
    if (cursor != null) q['cursor'] = '$cursor';
    final d = await _c.get('/users/$username/guestbook', query: q);
    return asJsonMapList(d['entries']).map(GuestbookEntry.fromJson).toList();
  }

  Future<GuestbookEntry> writeGuestbookEntry(String username, String message) async {
    final d = await _c.post('/users/$username/guestbook', {'message': message});
    final map = asJsonMap(d['entry']);
    if (map == null) {
      throw const ApiException(500, 'Invalid guestbook response');
    }
    return GuestbookEntry.fromJson(map);
  }

  Future<void> deleteGuestbookEntry(int id) => _c.delete('/users/guestbook/$id');
}
