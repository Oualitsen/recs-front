import 'package:dio/dio.dart';
import 'package:recs_ymal/generated/client.gq.dart';
import 'package:recs_ymal/src/db_services/token_db_service.dart';
import 'package:recs_ymal/src/utils/injector.dart';

class HttpInterceptor extends Interceptor {
  final TokenDbService service;
  final GQClient client;
  final Dio dio;

  static const athuHeader = "Authorization";

  bool refreshingToken = false;

  HttpInterceptor(
      {required this.service, required this.client, required this.dio});

  @override
  Future onRequest(RequestOptions options, handler) async {
    var token = await service.getToken();
    if (token != null) {
      options.headers[athuHeader] = "Bearer $token";
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, handler) {
    handler.next(response);
  }

  @override
  void onError(DioError err, handler) async {
    if (err.response?.statusCode == 401 &&
        err.requestOptions.headers[athuHeader] != null &&
        !refreshingToken) {
      // refresh token and resend the request!
      var refreshToken = await service.getRefreshToken();
      if (refreshToken != null) {
        try {
          refreshingToken = true;
          var refreshTokenResponse =
              await client.mutations.refreshToken(token: refreshToken);
          service.saveTokens(
              accessToken: refreshTokenResponse.data.token.accessToken,
              refreshToken: refreshTokenResponse.data.token.refreshToken);
          dio.fetch(err.requestOptions).then((value) => handler.resolve(value));
        } catch (error) {
          handler.next(err);
        } finally {
          refreshingToken = false;
        }
      }
    } else {
      handler.next(err);
    }
  }

  void _logout() {
    final _authMan = Injector.provideAuthManager();
    _authMan.remove();
  }
}
