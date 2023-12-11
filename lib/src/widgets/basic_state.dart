import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recs_ymal/generated/enums.gq.dart';
import 'package:recs_ymal/main.dart';
import 'package:recs_ymal/src/utils/lang.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class BasicState<T extends StatefulWidget> extends State<T> with LangMixin {
  @override
  void dispose() {
    for (var element in subjects) {
      element.close();
    }
    for (var element in notifiers) {
      element.dispose();
    }

    super.dispose();
  }

  List<Subject> get subjects;

  List<ChangeNotifier> get notifiers;
}

extension AppLocalizationsExt on AppLocalizations {
  static final DateFormat _dateFormat = DateFormat("yyyy-MM-dd");

  static final DateFormat _timeFormat = DateFormat("HH:mm");

  static final DateFormat _dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
  static final DateFormat _dayFormat = DateFormat("E dd");
  static final DateFormat _fullDateFormat =
      DateFormat('EEEE, MMMM d, y', settingsController.locale.languageCode);

  static final DateFormat _dateFormat2 = DateFormat("MMMM dd, yyyy", settingsController.locale.languageCode);
  String formatFullDate(DateTime dateTime) {
    return _fullDateFormat.format(dateTime);
  }

  String formatDateDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  String formatDateMillis(int date) {
    return formatDateDate(DateTime.fromMillisecondsSinceEpoch(date));
  }

  String formatDate(int date) {
    return _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  String formatDate2(int date) {
    return _dateFormat2.format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  String formatTime(int date) {
    return _timeFormat.format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    return formatTime(DateTime(0, 1, 1, timeOfDay.hour, timeOfDay.minute).millisecondsSinceEpoch);
  }

  String formatDateTime(int date) {
    return _dateTimeFormat.format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  int timeOfDayToInt(TimeOfDay timeOfDay) {
    return DateTime(0, 1, 1, timeOfDay.hour, timeOfDay.minute).millisecondsSinceEpoch;
  }

  String formatDay(int date) {
    return _dayFormat.format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  String formatTimeOfTheDay(TimeOfDay timeOfDay) {
    return "${addZero(timeOfDay.hour)}:${addZero(timeOfDay.minute)}";
  }

  DateTime findFirstDateOfTheWeek(DateTime dateTime) {
    return (dateTime.subtract(
      Duration(
        days: dateTime.weekday - 1,
      ),
    ));
  }

  DateTime findLastDateOfTheWeek(DateTime dateTime) {
    return dateTime.add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
  }

  String addZero(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  String monthName(int date) {
    return DateFormat('MMMM').format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  String getName(String firstName, String lastName) {
    return "${firstName} ${lastName}";
  }
}
