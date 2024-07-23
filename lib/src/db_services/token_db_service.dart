import 'package:shared_preferences/shared_preferences.dart';

class TokenDbService {
  static const String key = "token_key";
  static const String refresh_key = "refresh_token";

  SharedPreferences sharedPreferences;

  TokenDbService(this.sharedPreferences);

  Future<bool> save(String token, String refreshToken) async {
    var r1 = await sharedPreferences.setString(key, token);
    var r2 = await sharedPreferences.setString(refresh_key, refreshToken);
    return r1 && r2;
  }

  String? getToken() => sharedPreferences.getString(key);

  String? getRefreshToken() => sharedPreferences.getString(refresh_key);

  Future<bool> remove() async {
    sharedPreferences.remove(key);
    return sharedPreferences.remove(refresh_key);
  }
}
