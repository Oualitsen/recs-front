import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations getLang(BuildContext context) {
  return AppLocalizations.of(context)!;
}

mixin LangMixin<T extends StatefulWidget> on State<T> {
  AppLocalizations get lang {
    return AppLocalizations.of(context)!;
  }
}

mixin StatelessLangMixin on StatelessWidget {
  AppLocalizations getLang(BuildContext context) {
    return AppLocalizations.of(context)!;
  }
}

extension AppLocalizationsExt on AppLocalizations {
  String getLangName(String langName) {
    switch (langName) {
      case "ar":
        return "عربي";
      case "fr":
        return "Français";
      case "en":
        return "English";
    }
    return "";
  }
}
