import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';

http.Client createHttpClient() => BrowserClient()..withCredentials = true;

/// Presigned storage PUTs must not send cookies; B2/S3 CORS rejects credentialed requests.
http.Client createStorageHttpClient() => BrowserClient()..withCredentials = false;
