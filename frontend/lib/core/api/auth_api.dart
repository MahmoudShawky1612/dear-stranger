import 'api_client.dart';
import '../models/user.dart';
import '../models/json_parse.dart';

class AuthApi {
  final ApiClient _c;
  AuthApi() : _c = ApiClient.instance;

  User _parseUser(Map<String, dynamic> d) {
    final map = asJsonMap(d['user']);
    if (map == null) {
      throw const ApiException(500, 'Invalid user response');
    }
    return User.fromJson(map);
  }

  Future<User> register({required String username, required String email, required String password}) async {
    final d = await _c.post('/auth/register', {'username': username, 'email': email, 'password': password});
    return _parseUser(d);
  }

  Future<User> login({required String identifier, required String password}) async {
    final d = await _c.post('/auth/login', {'identifier': identifier, 'password': password});
    return _parseUser(d);
  }

  Future<User?> getMe() async {
    try {
      final d = await _c.get('/auth/me');
      return _parseUser(d);
    } on ApiException catch (e) {
      if (e.statusCode == 401) return null;
      rethrow;
    }
  }

  Future<void> logout() => _c.post('/auth/logout', {});
}
