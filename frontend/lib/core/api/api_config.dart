import 'package:flutter/foundation.dart';

const _apiFromEnv = String.fromEnvironment('API_BASE_URL');
const _wsFromEnv = String.fromEnvironment('WS_BASE_URL');

/// Local Flutter runs talk to the Node server on port 3000.
/// A release web build is served from that same host, so it uses relative URLs.
bool get _useHostOrigin =>
    kIsWeb && kReleaseMode && _apiFromEnv.isEmpty;

String get kBaseUrl {
  if (_apiFromEnv.isNotEmpty) return _apiFromEnv;
  if (_useHostOrigin) return '${Uri.base.origin}/api';
  return 'http://localhost:3000/api';
}

String get kWsBaseUrl {
  if (_wsFromEnv.isNotEmpty) return _wsFromEnv;
  if (_useHostOrigin) {
    final page = Uri.base;
    final scheme = page.scheme == 'https' ? 'wss' : 'ws';
    return '$scheme://${page.authority}';
  }
  return 'ws://localhost:3000';
}
