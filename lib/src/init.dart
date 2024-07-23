import 'dart:io';

import 'package:recs_ymal/generated/client.gq.dart';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_ymal/generated/types.gq.dart';

import 'package:recs_ymal/src/services/graphql_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recs_ymal/src/db_services/token_db_service.dart';
import 'package:recs_ymal/src/services/upload_service.dart';
import 'package:recs_ymal/src/utils/http_interceptor.dart';
import 'package:recs_ymal/src/managers/auth_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cookie_jar/cookie_jar.dart';

RegExp emailRegExp = RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
);

const String URL_BASE = String.fromEnvironment("URL_BASE", defaultValue: "http://localhost:8080/");

const String WS_URL_BASE = String.fromEnvironment("WS_URL_BASE", defaultValue: "ws://localhost:8080/");

Future<void> initDio() async {
  GetIt.instance.registerSingleton(TokenDbService());
  GetIt instance = GetIt.instance;
  Dio dio = Dio(BaseOptions(baseUrl: URL_BASE));
  CookieJar jar;
  if (kIsWeb) {
    jar = CookieJar();
    CookieManager manager = CookieManager(jar);
    dio.interceptors.add(manager);
  } else {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    jar = PersistCookieJar(storage: FileStorage(appDocPath));
    dio.interceptors.add(CookieManager(jar));
  }
  instance.registerSingleton(jar);
  dio.options.baseUrl = URL_BASE;
  instance.registerSingleton(dio);
  var client = GQClient(GraphqlService(dio).post);
  instance.registerSingleton(client);

  dio.interceptors
      .add(HttpInterceptor(client: client, service: GetIt.instance.get<TokenDbService>(), dio: dio));
}

void initServices() {
  Dio dio = GetIt.instance.get();

  GetIt.instance.registerSingleton(UploadService(dio));

  GetIt.instance.registerSingleton(
    AuthManager<RecsUser>(
      parser: (json) => RecsUser.fromJson(json),
      serializer: (client) => client.toJson(),
      getUserFromServer: (RecsUser? current) async {
        return null;
      },
    ),
  );
}

String getFlagUrl(String name) {
  return "${URL_BASE}flags/${name.toLowerCase()}.png";
}
