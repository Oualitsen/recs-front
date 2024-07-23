import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_ymal/generated/client.gq.dart';
import 'package:recs_ymal/generated/types.gq.dart';
import 'package:recs_ymal/src/db_services/token_db_service.dart';
import 'package:recs_ymal/src/managers/auth_status.dart';
import 'package:recs_ymal/src/utils/injector.dart';

class LoginService {
  static Future<bool> refreshTokenLogin() async {
    var client = GetIt.instance.get<GQClient>();
    var service = GetIt.instance.get<TokenDbService>();
    var refreshToken = service.getRefreshToken();
    if (refreshToken == null) {
      return false;
    }
    if (JWT.tryDecode(refreshToken) == null) {
      print("JWT token expired");
      return false;
    }
    try {
      var result = await client.mutations.refreshToken(token: refreshToken);
      await handleLogin(result.refreshToken.token, result.refreshToken.user);
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<void> logout() async {
    var service = GetIt.instance.get<TokenDbService>();
    service.remove();
    Injector.provideAuthManager().remove();
  }

  static Future<void> handleLogin(ResponseToken token, FeUser user) async {
    var service = GetIt.instance.get<TokenDbService>();
    var authMan = Injector.provideAuthManager();
    await service.save(token.accessToken, token.refreshToken);
    await authMan.save(user);
    authMan.add(AuthStatus.logged_in);
    authMan.rolesStream.add(user.roles.toSet());
  }
}
