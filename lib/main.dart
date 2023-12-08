import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/utils/shims/dart_ui_real.dart';
import 'package:recs_ymal/src/init.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:recs_ymal/src/app.dart';
import 'package:url_strategy/url_strategy.dart';

final myAppKey = GlobalKey<MyAppState>();
final settingsController = SettingsController(SettingsService());

void downloadCallback(String id, int status, int progress) {
  final SendPort? send =
      IsolateNameServer.lookupPortByName('downloader_send_port');
  send!.send([id, status, progress]);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  await settingsController.loadSettings();
  await initDio();
  initServices();
  runApp(MyApp(
    settingsController: settingsController,
    key: myAppKey,
  ));
}
