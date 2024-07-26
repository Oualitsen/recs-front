import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/src/db_services/token_db_service.dart';
import 'package:recs_front/src/services/login_service.dart';

class HttpInterceptor extends Interceptor {
  final TokenDbService _service = GetIt.instance.get();
  final execuldeOperationNames = {openIdLogin, refreshTokenOpName};
  bool refreshTokenProgress = false;

  List<RequestData> requestDataList = [];
  final Dio dio;
  HttpInterceptor(this.dio);
  static const operationNameKey = '__opName';
  static const refreshTokenOpName = 'refreshToken';
  static const openIdLogin = 'adminLogin';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    String? opName = getOperationName(options);
    if (opName != null) {
      options.headers.putIfAbsent(operationNameKey, () => opName);
    }
    if (refreshTokenProgress && opName != refreshTokenOpName) {
      // save the requests for later.
      requestDataList.add(RequestData(options, handler));
      return;
    }

    if (opName == refreshTokenOpName) {
      refreshTokenProgress = true;
    }
    if (execuldeOperationNames.contains(opName)) {
      return handler.next(options);
    }
    if (isJwtForExpired()) {
      return tryLoginAndContinue(options, handler);
    } else {
      var token = _service.getToken()!;
      options.headers.putIfAbsent("Authorization", () => "Bearer $token");
      return handler.next(options);
    }
  }

  String? getOperationName(RequestOptions options) {
    if (options.data is String?) {
      String? payload = options.data;
      if (payload != null) {
        return jsonDecode(payload)['operationName'];
      }
    }
    return null;
  }

  void tryLoginAndContinue(RequestOptions options, RequestInterceptorHandler handler) async {
    bool loggedIn = await refreshToken();
    if (loggedIn) {
      return handler.resolve(await dio.fetch(options));
    } else {
      LoginService.logout();
    }
  }

  bool isJwtForExpired() {
    var token = _service.getToken();
    if (token == null) {
      return true;
    }
    var jwt = JWT.tryDecode(token);
    if (jwt == null) {
      return true;
    }
    var exp = jwt.payload['exp'] as int;
    var now = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    return exp <= now;
  }

  void tryLoginAndContinueErr(DioError error, ErrorInterceptorHandler handler) async {
    var loggedIn = await refreshToken();
    if (loggedIn) {
      return handler.resolve(await dio.fetch(error.requestOptions));
    } else {
      await LoginService.logout();
      return handler.next(error);
    }
  }

  Future<bool> refreshToken() async {
    bool loggedIn = false;
    refreshTokenProgress = true;
    try {
      loggedIn = await LoginService.refreshTokenLogin();
      if (loggedIn) {
        requestDataList.forEach(handleRequestData);
      }
    } finally {
      refreshTokenProgress = false;
    }
    return loggedIn;
  }

  void handleRequestData(RequestData data) async {
    try {
      var opName = (data.options.headers[operationNameKey]);
      if (!execuldeOperationNames.contains(opName)) {
        data.handler.resolve(await dio.fetch(data.options));
      }
    } finally {
      requestDataList.remove(data);
    }
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 403) {
      LoginService.logout();
    } else if (err.response?.statusCode == 401) {
      return tryLoginAndContinueErr(err, handler);
    }
    handler.next(err);
  }
}

class RequestData {
  final RequestInterceptorHandler handler;
  final RequestOptions options;
  RequestData(this.options, this.handler);
}
