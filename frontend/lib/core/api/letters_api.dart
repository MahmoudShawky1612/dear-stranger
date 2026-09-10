import 'api_client.dart';
import '../models/letter.dart';
import '../models/artwork.dart';
import '../models/reply.dart';
import '../models/json_parse.dart';

class LettersApi {
  final ApiClient _c;
  LettersApi() : _c = ApiClient.instance;

  List<Letter> _parseLetters(Map<String, dynamic> d) =>
      asJsonMapList(d['letters']).map(Letter.fromJson).toList();

  Letter _parseLetter(Map<String, dynamic> d) {
    final map = asJsonMap(d['letter']);
    if (map == null) {
      throw const ApiException(500, 'Invalid letter response');
    }
    return Letter.fromJson(map);
  }

  Future<List<Letter>> getFeed({int limit = 20, int? cursor}) async {
    final q = <String, String>{'limit': '$limit'};
    if (cursor != null) q['cursor'] = '$cursor';
    final d = await _c.get('/letters', query: q);
    return _parseLetters(d);
  }

  Future<List<Letter>> getMySent({int limit = 20, int? cursor}) async {
    final q = <String, String>{'limit': '$limit'};
    if (cursor != null) q['cursor'] = '$cursor';
    final d = await _c.get('/letters/mine/sent', query: q);
    return _parseLetters(d);
  }

  Future<List<Letter>> getMyClaimed({int limit = 20, int? cursor}) async {
    final q = <String, String>{'limit': '$limit'};
    if (cursor != null) q['cursor'] = '$cursor';
    final d = await _c.get('/letters/mine/claimed', query: q);
    return _parseLetters(d);
  }

  Future<Letter> getLetter(int id) async {
    final d = await _c.get('/letters/$id');
    return _parseLetter(d);
  }

  Future<Letter> sendLetter({required String title, required String message, required bool isAnonymous}) async {
    final d = await _c.post('/letters', {'title': title, 'message': message, 'isAnonymous': isAnonymous});
    return _parseLetter(d);
  }

  Future<Letter> claimLetter(int id) async {
    final d = await _c.post('/letters/$id/claim', {});
    return _parseLetter(d);
  }

  Future<Reply> sendReply(int letterId, String message) async {
    final d = await _c.post('/letters/$letterId/replies', {'message': message});
    final map = asJsonMap(d['reply']);
    if (map == null) {
      throw const ApiException(500, 'Invalid reply response');
    }
    return Reply.fromJson(map);
  }

  Future<Map<String, dynamic>> requestArtworkUploadUrl({
    required int letterId,
    required String contentType,
    required int fileSizeBytes,
  }) =>
      _c.post('/letters/$letterId/artwork/upload-url', {
        'contentType': contentType,
        'fileSizeBytes': fileSizeBytes,
      });

  Future<Artwork> uploadArtworkFile({
    required int letterId,
    required List<int> bytes,
    required String contentType,
  }) async {
    final d = await _c.postBytes('/letters/$letterId/artwork/file', bytes, contentType);
    final map = asJsonMap(d['artwork']);
    if (map == null) {
      throw const ApiException(500, 'Invalid artwork response');
    }
    return Artwork.fromJson(map);
  }

  Future<Artwork> completeArtworkDelivery({
    required int letterId,
    required String storageKey,
    required bool isAnonymous,
  }) async {
    final d = await _c.post('/letters/$letterId/artwork/complete', {
      'storageKey': storageKey,
      'isAnonymous': isAnonymous,
    });
    final map = asJsonMap(d['artwork']);
    if (map == null) {
      throw const ApiException(500, 'Invalid artwork response');
    }
    return Artwork.fromJson(map);
  }

  Future<String> getArtworkUrl(int artworkId) async {
    final d = await _c.get('/letters/artwork/$artworkId/url');
    final url = asStringOrNull(d['url']);
    if (url == null || url.isEmpty) {
      throw const ApiException(500, 'Invalid artwork URL');
    }
    return url;
  }

  Future<void> publishArtwork(int letterId) =>
      _c.post('/letters/$letterId/artwork/publish', {});
}
