import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class LocalStore {
  const LocalStore();
  static const _secure = FlutterSecureStorage();
  Future<String?> readToken() => _secure.read(key: 'studyflow_token');
  Future<void> writeToken(String token) => _secure.write(key: 'studyflow_token', value: token);
  Future<void> clearToken() => _secure.delete(key: 'studyflow_token');
  Box<String> get _favorites => Hive.box<String>('studyflow_favorites');
  Set<String> favoriteIds() => _favorites.values.toSet();
  Future<void> toggleFavorite(String id) async {
    dynamic found;
    for (final key in _favorites.keys) {
      if (_favorites.get(key) == id) found = key;
    }
    if (found == null) { await _favorites.add(id); } else { await _favorites.delete(found); }
  }
}
