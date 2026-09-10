import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'http_client_factory.dart';
import '../models/json_parse.dart';

const String kBaseUrl = 'http://localhost:3000/api';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

class ApiClient {
  static ApiClient? _instance;
  final http.Client _client;
  final http.Client _storageClient;

  ApiClient._internal(this._client, this._storageClient);

  static ApiClient get instance {
    _instance ??= ApiClient._internal(createHttpClient(), createStorageHttpClient());
    return _instance!;
  }

  static const _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Uri _uri(String path, [Map<String, String>? q]) {
    final base = Uri.parse('$kBaseUrl$path');
    return q != null ? base.replace(queryParameters: q) : base;
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) async {
    final res = await _client.get(_uri(path, query), headers: _headers);
    return _parse(res);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await _client.post(_uri(path), headers: _headers, body: jsonEncode(body));
    return _parse(res);
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    final res = await _client.patch(_uri(path), headers: _headers, body: jsonEncode(body));
    return _parse(res);
  }

  Future<void> delete(String path) async {
    final res = await _client.delete(_uri(path), headers: _headers);
    if (res.statusCode >= 400) {
      final b = asJsonMap(jsonDecode(res.body)) ?? {};
      throw ApiException(res.statusCode, asString(b['error'], 'Request failed'));
    }
  }

  Future<Map<String, dynamic>> postBytes(String path, List<int> bytes, String contentType) async {
    final body = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    final res = await _client.post(
      _uri(path),
      headers: {
        'Content-Type': contentType,
        'Accept': 'application/json',
      },
      body: body,
    );
    return _parse(res);
  }

  Future<void> putBytes(String url, List<int> bytes, String contentType) async {
    final body = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    final res = await _storageClient.put(
      Uri.parse(url),
      headers: {'Content-Type': contentType},
      body: body,
    );
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, 'Upload to storage failed');
    }
  }

  Map<String, dynamic> _parse(http.Response res) {
    if (res.statusCode == 204) return {};
    final decoded = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      final b = asJsonMap(decoded) ?? {};
      throw ApiException(res.statusCode, asString(b['error'], 'Request failed'));
    }
    return asJsonMap(decoded) ?? {};
  }
}
