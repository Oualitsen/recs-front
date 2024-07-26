import 'package:flutter/material.dart';
import 'package:recs_front/src/utils/lang.dart';

class ValidationUtils {
  static final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
  );
  static final RegExp _usernameRegExp = RegExp(r'^[a-zA-Z0-9-_]+$');

  static String? requiredField(String? text, BuildContext context) {
    return (text?.isEmpty ?? true) ? getLang(context).requiredField : null;
  }

  static String? requiredobject(Object? text, BuildContext context) {
    return (text != null) ? getLang(context).requiredField : null;
  }

  static String? email(String? text, BuildContext context, [required = false]) {
    if (text != null && text.isNotEmpty) {
      return _emailRegExp.hasMatch(text) ? null : getLang(context).invalidEmail;
    }
    return required ? requiredField(text, context) : null;
  }

  static String? username(String? text, BuildContext context, [required = false]) {
    if (text != null) {
      return _usernameRegExp.hasMatch(text) ? null : getLang(context).invalidUsername;
    }
    return required ? requiredField(text, context) : null;
  }

  static String? intValidator(
    String? text,
    BuildContext context, {
    required = false,
    int? minValue,
    int? maxValue,
  }) {
    if (text != null) {
      try {
        int i = int.parse(text);

        if (minValue != null && i < minValue) {
          return getLang(context).minValue(minValue);
        }
        if (maxValue != null && i > maxValue) {
          return getLang(context).maxValue(maxValue);
        }
      } catch (error) {
        return getLang(context).invalidValue;
      }
    }
    return required ? requiredField(text, context) : null;
  }

  static String? doubleValidator(
    String? text,
    BuildContext context, {
    required = false,
    double? minValue,
    double? maxValue,
  }) {
    if (text != null) {
      try {
        double i = double.parse(text);

        if (minValue != null && i < minValue) {
          return getLang(context).minValue(minValue);
        }
        if (maxValue != null && i > maxValue) {
          return getLang(context).maxValue(maxValue);
        }
      } catch (error) {
        return getLang(context).invalidValue;
      }
    }
    return required ? requiredField(text, context) : null;
  }

  static String? phoneValidator(String? text, int regionCode, BuildContext context, [required = false]) {
    return required ? requiredField(text, context) : null;
  }
}
