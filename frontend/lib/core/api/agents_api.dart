import 'api_client.dart';
import '../models/muse_inspiration.dart';
import '../models/scribe_result.dart';
import '../models/json_parse.dart';

class AgentsApi {
  final ApiClient _c;
  AgentsApi() : _c = ApiClient.instance;

  Future<MuseInspiration> getMuseInspiration(int letterId) async {
    final d = await _c.post('/agents/muse/inspire/$letterId', {});
    final inspirationMap = asJsonMap(d['inspiration']);
    if (inspirationMap == null) {
      throw const ApiException(500, 'Invalid muse inspiration response');
    }
    return MuseInspiration.fromJson(inspirationMap);
  }

  Future<ScribePolishResult> polishWithScribe(String draft) async {
    final d = await _c.post('/agents/scribe/polish', {'draft': draft});
    final stylesMap = asJsonMap(d['styles']);
    if (stylesMap == null) {
      throw const ApiException(500, 'Invalid scribe response');
    }
    return ScribePolishResult.fromJson(stylesMap);
  }

  Future<Map<String, dynamic>> checkGuardian(String text) async {
    final d = await _c.post('/agents/guardian/check', {'text': text});
    return asJsonMap(d['result']) ?? {};
  }

  Future<void> unclaimLetter(int letterId) async {
    await _c.post('/letters/$letterId/unclaim', {});
  }
}
