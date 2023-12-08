import 'package:flutter/material.dart';

import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  late Locale _locale;
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _locale = await _settingsService.current();
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  List<Locale> get supportedLocales => _settingsService.supportedLocales();

  Future<void> updateLocale(Locale locale) async {
    if (locale == this.locale) {
      return;
    }
    _locale = locale;
    notifyListeners();
    _settingsService.updateLocale(locale);
  }
}
