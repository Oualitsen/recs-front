import 'package:shared_preferences/shared_preferences.dart';

class TokenDbService {
  static const String key = "token_key";
  static const String refreshTokenKey = "refresh_token";

  Future<bool> save(String token) async {
    return SharedPreferences.getInstance()
        .asStream()
        .asyncMap((prefs) => prefs.setString(key, token))
        .first;
  }

  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {
    await save(accessToken);
    await saveRefreshToken(refreshToken);
  }

  Future<bool> saveRefreshToken(String token) async {
    return SharedPreferences.getInstance()
        .asStream()
        .asyncMap((prefs) => prefs.setString(refreshTokenKey, token))
        .first;
  }

  Future<String?> getToken() {
    return SharedPreferences.getInstance()
        .asStream()
        .map((prefs) => prefs.getString(key))
        .first;
  }

  Future<String?> getRefreshToken() {
    return SharedPreferences.getInstance()
        .asStream()
        .map((prefs) => prefs.getString(refreshTokenKey))
        .first;
  }

  Future<bool> remove() async {
    var prefs = await SharedPreferences.getInstance();
    var keyRemoved = await prefs.remove(key);
    var refreshKeyRemoved = await prefs.remove(refreshTokenKey);
    return keyRemoved && refreshKeyRemoved;
  }
}
