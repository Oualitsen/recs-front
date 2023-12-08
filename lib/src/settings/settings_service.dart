import 'package:flutter/material.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

class SettingsService {
  static const Locale ar = Locale('ar', '');
  static const Locale en = Locale('en', '');
  static const Locale fr = Locale('fr', '');

  static const themeKey = "theme";
  static const localeKey = "locale";

  List<Locale> supportedLocales() => [en, fr, ar];

  Future<ThemeMode> themeMode() {
    return SharedPreferences.getInstance()
        .asStream()
        .map((prefs) => prefs.getString(themeKey))
        .map((event) {
          if (event == null) {
            return ThemeMode.system;
          }
          switch (event) {
            case "system":
              return ThemeMode.system;
            case "dark":
              return ThemeMode.dark;
            case "light":
              return ThemeMode.light;
          }
          return ThemeMode.system;
        })
        .onErrorReturn(ThemeMode.system)
        .first;
  }

  Future<void> updateThemeMode(ThemeMode theme) {
    return SharedPreferences.getInstance()
        .asStream()
        .asyncMap((prefs) => prefs.setString(themeKey, theme.name))
        .first;
  }

  Future<void> updateLocale(Locale locale) {
    return SharedPreferences.getInstance()
        .asStream()
        .asyncMap((prefs) => prefs.setString(localeKey, locale.serialize()))
        .first;
  }

  Future<Locale> current() {
    return SharedPreferences.getInstance()
        .asStream()
        .map((prefs) => prefs.getString(localeKey))
        .where((event) => event != null)
        .map((event) => event!)
        .map((event) => LocaleExt.parse(event))
        .switchIfEmpty(_getDefaultLocale().asStream())
        .map((event) => event!)
        .first;
  }

  Future<Locale> _getDefaultLocale() {
    return Devicelocale.currentAsLocale
        .asStream()
        .where((event) => event != null)
        .map((event) => event!)
        .map((event) => supportedLocales().firstWhere(
            (element) => element.languageCode == event.languageCode,
            orElse: () => supportedLocales().first))
        .onErrorReturn(supportedLocales().first)
        .first;
  }
}

extension LocaleExt on Locale {
  String serialize() {
    return "${languageCode}_$countryCode";
  }

  static Locale? parse(String value) {
    try {
      var split = value.split("_");
      return Locale(split[0], split.length > 1 ? split[1] : '');
    } catch (error) {
      /**
       * Ignore this
       */
    }
    return null;
  }
}
