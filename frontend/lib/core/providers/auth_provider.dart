import 'package:flutter/foundation.dart';
import '../api/auth_api.dart';
import '../models/user.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthApi _api = AuthApi();

  AuthStatus _status = AuthStatus.loading;
  User? _user;
  String? _error;

  AuthStatus get status => _status;
  User?       get user   => _user;
  String?     get error  => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> init() async {
    try {
      final u = await _api.getMe();
      _user   = u;
      _status = u != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) async {
    _error = null;
    try {
      _user   = await _api.login(identifier: identifier, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _error = null;
    try {
      _user   = await _api.register(username: username, email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void updateUser(User u) {
    _user = u;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
