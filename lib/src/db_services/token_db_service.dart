import 'package:shared_preferences/shared_preferences.dart';

class TokenDbService {
  static const String key = "token_key";

  SharedPreferences? cache;

  Future<SharedPreferences> _instance() async {
    cache ??= await SharedPreferences.getInstance();
    return cache!;
  }

  Future<bool> save(String token) async {
    return _instance()
        .asStream()
        .asyncMap((prefs) => prefs.setString(key, token))
        .first;
  }

  Future<String?> getToken() =>
      _instance().asStream().map((prefs) => prefs.getString(key)).first;

  Future<bool> remove() =>
      _instance().asStream().asyncMap((prefs) => prefs.remove(key)).first;
}
