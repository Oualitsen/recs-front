import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_ymal/src/db_services/token_db_service.dart';

class HttpInterceptor extends Interceptor {
  final TokenDbService _service = GetIt.instance.get();

  @override
  Future onRequest(RequestOptions options, handler) {
    return _service
        .getToken()
        .asStream()
        .map((token) {
          if (token != null) {
            options.headers.putIfAbsent("Authorization", () => "Bearer $token");
          }
          return token;
        })
        .map((event) => handler.next(options))
        .first;
  }

  @override
  void onResponse(Response response, handler) async {
    if (response.statusCode == 403) {
      _logout();
    }

    handler.next(response);
  }

  @override
  void onError(DioError err, handler) async {
    if (err.response?.statusCode == 403) {
      _logout();
    }
    handler.next(err);
  }

  void _logout() {
    try {
      //   final _authMan = Injector.provideAuthManager();
      //    _authMan.remove();
    } catch (error) {
      //print("error $error");
    }
  }
}
