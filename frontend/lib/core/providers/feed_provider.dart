import 'package:flutter/foundation.dart';
import '../api/letters_api.dart';
import '../models/letter.dart';

class LettersFeedProvider extends ChangeNotifier {
  final LettersApi _api = LettersApi();

  final List<Letter> _letters = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int? _cursor;
  bool _hasMore = true;
  bool _loadedOnce = false;
  Future<void>? _inFlight;

  List<Letter> get letters => List.unmodifiable(_letters);
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get hasCachedLetters => _letters.isNotEmpty;
  bool get loadedOnce => _loadedOnce;

  Future<void> ensureLoaded() async {
    if (_loadedOnce) return;
    await refresh();
  }

  Future<void> refresh({bool silent = false}) async {
    if (_inFlight != null) return _inFlight!;
    _inFlight = _refresh(silent: silent).whenComplete(() {
      _inFlight = null;
    });
    return _inFlight!;
  }

  Future<void> _refresh({required bool silent}) async {
    final showSpinner = !silent || _letters.isEmpty;
    if (showSpinner) {
      _loading = true;
      _error = null;
      notifyListeners();
    }
    try {
      final letters = await _api.getFeed();
      _letters
        ..clear()
        ..addAll(letters);
      _hasMore = letters.length == 20;
      _cursor = _letters.isNotEmpty ? _letters.last.id : null;
      _loadedOnce = true;
      _loading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _loading = false;
      if (_letters.isEmpty) {
        _error = e.toString();
      }
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore || _loading) return;
    _loadingMore = true;
    notifyListeners();
    try {
      final more = await _api.getFeed(cursor: _cursor);
      _letters.addAll(more);
      _hasMore = more.length == 20;
      if (more.isNotEmpty) _cursor = more.last.id;
      _loadingMore = false;
      notifyListeners();
    } catch (_) {
      _loadingMore = false;
      notifyListeners();
    }
  }
}
