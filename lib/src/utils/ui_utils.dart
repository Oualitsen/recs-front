import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:recs_ymal/src/utils/lang.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dropdown_search/dropdown_search.dart';

Widget streamBuilder<T>({
  required Stream<T> stream,
  required Widget Function(T) onDataChanged,
  T? initialData,
  Widget noData = const SizedBox.shrink(),
  Widget loading = const Center(child: CircularProgressIndicator()),
  Widget Function(BuildContext context, dynamic error)? onError,
}) {
  return StreamBuilder<T>(
    stream: stream,
    initialData: initialData ?? (stream is ValueStream ? (stream as ValueStream).valueOrNull : null),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        if (onError != null) {
          return onError(context, snapshot.error);
        } else {
          return Center(child: Text("Error ${snapshot.error}"));
        }
      }
      switch (snapshot.connectionState) {
        case ConnectionState.none:
          return noData;
        case ConnectionState.waiting:
          return Center(child: loading);
        case ConnectionState.active:
        case ConnectionState.done:
          if (!snapshot.hasData) {
            return noData;
          }
          return onDataChanged(snapshot.data!);
      }
    },
  );
}

Widget streamBuilderDiscretLoading<T>({
  required Stream<T> stream,
  required Widget Function(T) onDataChanged,
  Widget noData = const SizedBox.shrink(),
}) {
  return streamBuilder(
    stream: stream,
    onDataChanged: onDataChanged,
    loading: SizedBox.shrink(),
    noData: noData,
  );
}

Widget text(String text, {selectable = false}) {
  if (!selectable) {
    return Text(text);
  }
  return SelectableText(text);
}

ThemeData getThemeData(BuildContext context) {
  final primaryColor = Theme.of(context).primaryColor;
  return ThemeData(
    canvasColor: Colors.grey[100]!,
    primarySwatch: MaterialColor(primaryColor.value, {
      50: primaryColor.withOpacity(0.1),
      100: primaryColor.withOpacity(0.2),
      200: primaryColor.withOpacity(0.3),
      300: primaryColor.withOpacity(0.4),
      400: primaryColor.withOpacity(0.5),
      500: primaryColor.withOpacity(0.6),
      600: primaryColor.withOpacity(0.7),
      700: primaryColor.withOpacity(0.8),
      800: primaryColor.withOpacity(0.9),
      900: primaryColor.withOpacity(1.0),
    }),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 100,
      titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(normalBorderRaduis),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(normalBorderRaduis),
      ),
    )),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(normalBorderRaduis),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(normalBorderRaduis),
      ),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(normalBorderRaduis),
          borderSide: BorderSide(width: 2, color: Colors.red)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(normalBorderRaduis),
          borderSide: BorderSide(width: 1, color: primaryColor)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(normalBorderRaduis),
          borderSide: BorderSide(width: 1, color: Colors.red)),
      contentPadding: EdgeInsets.only(top: 2.0, bottom: 2.0, left: 16, right: 16),
    ),
    textTheme: GoogleFonts.notoSansJpTextTheme(
      TextTheme(
        headlineMedium: TextStyle(
          fontSize: 32,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ),
  );
}

class SpacingValues {
  static const double meduimWidth = 150;
  static const double largeWidth = 200;
  static const double smallWidth = 125;
  static const double spacing = 30;
  static const double tableWidth = 1350;
}

class FormUiUtils {
  static const Widget labelToInputMargin = Gap(10);
  static const Widget inertInputMargin = Gap(20);

  static Widget requiredPostFix(String text, [bool required = true]) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Gap(10),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        if (required) ...[
          const Gap(5),
          const Text(
            "*",
            style: TextStyle(color: Colors.red),
          ),
        ]
      ],
    );
  }

  static Widget errorText(String message) {
    return Text(message, style: TextStyle(color: Colors.red));
  }

  static InputDecoration defaultWithRaduis(String hint, double raduis) => InputDecoration(
        contentPadding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
        hintText: hint,
        filled: true,
        fillColor: Colors.blue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(raduis),
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(raduis),
            borderSide: BorderSide(width: 1, color: Colors.black26)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(raduis), borderSide: BorderSide(width: 2, color: Colors.red)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(raduis),
            borderSide: BorderSide(width: 1, color: Colors.blue)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(raduis), borderSide: BorderSide(width: 1, color: Colors.red)),
      );
  static Widget inputPhoneNumber({
    required String title,
    required bool required,
    required TextEditingController controller,
    required String hint,
    required Function(PhoneNumber phoneNumber) onChanged,
    PhoneNumber? initialValue,
    FormFieldValidator<String>? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(children: [
          SizedBox(
            width: 150,
            child: requiredPostFix(title, required),
          ),
          Expanded(
            child: InternationalPhoneNumberInput(
              textFieldController: controller,
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                height: 2,
                fontSize: 16,
              ),
              keyboardType: TextInputType.phone,
              validator: validator,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              selectorConfig: SelectorConfig(
                setSelectorButtonAsPrefixIcon: true,
                showFlags: true,
                trailingSpace: false,
              ),
              inputDecoration: defaultWithRaduis(hint, ovalBorderRaduis),
              onInputChanged: onChanged,
              initialValue: initialValue,
            ),
          )
        ]),
      ),
    );
  }

  static Widget inputNoTitle(
    bool required,
    TextEditingController controller,
    String hint, {
    bool enabled = true,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: TextFormField(
          enabled: enabled,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(height: 2, fontSize: 16),
          controller: controller,
          textAlign: TextAlign.center,
          decoration: defaultWithRaduis(hint, ovalBorderRaduis),
          onChanged: onChanged,
        ),
      ),
    );
  }

  static Widget input(
    String title,
    bool required,
    TextEditingController controller,
    String hint, {
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(children: [
          SizedBox(
            width: 150,
            child: requiredPostFix(title, required),
          ),
          Expanded(
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: keyboardType,
              validator: validator,
              style: TextStyle(height: 2, fontSize: 16),
              controller: controller,
              textAlign: TextAlign.center,
              decoration: defaultWithRaduis(hint, ovalBorderRaduis),
              onChanged: onChanged,
            ),
          )
        ]),
      ),
    );
  }

  static Widget disabledInput({
    required String title,
    required String hint,
    required String content,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(children: [
          SizedBox(
            width: 150,
            child: requiredPostFix(title, false),
          ),
          Expanded(
            child: TextFormField(
              initialValue: content,
              enabled: false,
              style: TextStyle(height: 2, fontSize: 16),
              textAlign: TextAlign.center,
              decoration: defaultWithRaduis(hint, ovalBorderRaduis),
            ),
          )
        ]),
      ),
    );
  }

  static Widget inputVertical(
    String title,
    bool required,
    TextEditingController controller,
    String hint, {
    FormFieldValidator<String>? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            requiredPostFix(title, required),
            labelToInputMargin,
            TextFormField(
                validator: validator,
                minLines: 3,
                maxLines: 5,
                style: TextStyle(height: 2, fontSize: 16),
                controller: controller,
                decoration: defaultWithRaduis(hint, normalBorderRaduis))
          ],
        ),
      ),
    );
  }

  static Widget inputDropDownButton<T>(
      {required String title,
      required bool required,
      required List<T> items,
      required Widget Function(T) mapper,
      required ValueChanged<T?>? onChanged,
      required T? value,
      required String hint,
      FormFieldValidator<T>? validator,
      Widget? trailing,
      double labelWidth = 150}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(children: [
          SizedBox(
            width: labelWidth,
            child: requiredPostFix(title, required),
          ),
          Expanded(
            child: DropdownButtonFormField<T>(
              decoration: defaultWithRaduis(hint, ovalBorderRaduis),
              value: value,
              items: items
                  .map((p) => DropdownMenuItem(
                        child: mapper(p),
                        value: p,
                      ))
                  .toList(),
              onChanged: onChanged,
              validator: validator,
            ),
          ),
          if (trailing != null) trailing
        ]),
      ),
    );
  }

  static Widget inputDropDownButton2<T>(
      {required String title,
      required bool required,
      required List<T> items,
      required Widget Function(BuildContext, T, bool) mapper,
      required ValueChanged<T?>? onChanged,
      required T? value,
      required String hint,
      FormFieldValidator<T>? validator,
      Widget? trailing,
      Widget? trailing2,
      double labelWidth = 150,
      bool Function(T)? disabledItemFn,
      Widget? postTile}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(children: [
          SizedBox(
            width: labelWidth,
            child: Row(
              children: [requiredPostFix(title, required), if (postTile != null) postTile],
            ),
          ),
          Expanded(
            child: DropdownSearch<T>(
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: defaultWithRaduis(hint, ovalBorderRaduis),
              ),
              // value: value,
              items: items,
              onChanged: onChanged,
              validator: validator,
              selectedItem: value,

              compareFn: (a, b) => a == b,
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchDelay: Duration(milliseconds: 10),
                showSelectedItems: true,
                itemBuilder: mapper,
                searchFieldProps: TextFieldProps(
                  decoration: defaultWithRaduis(hint, ovalBorderRaduis),
                  autofocus: true,
                ),
                disabledItemFn: disabledItemFn,
                menuProps: MenuProps(
                  borderRadius: BorderRadius.all(Radius.circular(normalBorderRaduis)),
                ),
              ),
            ),
          ),
          Gap(50),
          if (trailing != null) trailing,
          if (trailing2 != null) trailing2,
        ]),
      ),
    );
  }

  static Widget customLayoutBuilder({
    required Widget child,
    required double maxWidth,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isOverflowed = constraints.maxWidth < maxWidth;
        if (isOverflowed) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: maxWidth,
              child: child,
            ),
          );
        }
        return child;
      },
    );
  }

  static Widget CustomDropDownButton<T>({
    required List<T> items,
    required Widget Function(T) mapper,
    required ValueChanged<T?>? onChanged,
    required T? value,
    final Color? color,
    final Color? borderColor,
    required double width,
  }) {
    return Container(
      height: 40,
      width: width,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(width: 1, color: borderColor ?? Colors.black),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<T>(
              icon: SizedBox.shrink(),
              decoration: defaultWithRaduis("", ovalBorderRaduis),
              value: value,
              items: items
                  .map((p) => DropdownMenuItem(
                        child: mapper(p),
                        value: p,
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  static Widget uploadButton(
    String? title,
    bool required,
    BuildContext context, {
    Function()? onPressed,
    bool noBorder = false,
    double boxWidth = 230,
    double? boxHeight,
  }) {
    var lang = getLang(context);
    return Container(
      height: boxHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: noBorder
            ? null
            : Border.all(
                width: 1.0,
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(children: [
          if (title != null)
            SizedBox(
              width: 150,
              child: requiredPostFix(title, required),
            ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(normalBorderRaduis),
              color: Color(0xFFedfaf3),
            ),
            child: DottedBorder(
              borderPadding: EdgeInsets.all(0),
              color: Theme.of(context).primaryColor,
              radius: Radius.circular(normalBorderRaduis),
              borderType: BorderType.RRect,
              padding: EdgeInsets.all(0),
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(normalBorderRaduis),
                  ),
                ),
                onPressed: onPressed,
                child: SizedBox(
                  height: boxHeight,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.upload),
                          Gap(10),
                          SizedBox(
                            width: boxWidth,
                            child: RichText(
                              overflow: TextOverflow.clip,
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan>[
                                  TextSpan(
                                    text: lang.clickToUpload,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: lang.dragAndDropToUpload,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  static Widget deleteIconButton(
      {required Function() onTap,
      double radius = 10,
      Color backgroundColor = Colors.pink,
      double size = 10}) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: Icon(
          FontAwesomeIcons.xmark,
          color: Colors.white,
          size: size,
        ),
      ),
    );
  }

  static Widget wrapInOvalPrimaryContainer(Widget child,
      {double raduis = ovalBorderRaduis, BoxBorder? border}) {
    return Container(
      child: child,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(raduis),
        color: Color(0xFFedfaf3),
        border: border,
      ),
    );
  }

  static Widget wrapInNormalRaduisPrimaryContainer(Widget child) {
    return Container(
      child: child,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(normalBorderRaduis),
        color: Color(0xFFedfaf3),
      ),
    );
  }

  static Widget wrapInBottonDevider(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(25)),
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                width: 7,
              ),
            ),
          ),
          child: child),
    );
  }

  static Widget wrapInRectRoundContainer({
    required Widget child,
    double borderRaduis = 15,
    double width = 350,
    EdgeInsets padding = const EdgeInsets.symmetric(
      vertical: 5,
      horizontal: 10,
    ),
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          width: 1.0,
        ),
      ),
      child: child,
    );
  }

  static Widget customDropDownButtonWithoutBorders<T>({
    required List<T> items,
    required Widget Function(T) mapper,
    required ValueChanged<T?>? onChanged,
    required T? value,
    final String? hint,
    final Color? color,
    final double radius = 20,
    final double width = SpacingValues.meduimWidth,
    final BoxBorder? border,
  }) {
    return Container(
      height: 40,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ovalBorderRaduis),
        border: border,
      ),
      child: DropdownButtonFormField<T>(
        style: TextStyle(color: Colors.white),
        dropdownColor: Color.fromARGB(255, 60, 60, 70),
        icon: SizedBox.shrink(),
        decoration: InputDecoration(
          hintText: hint,
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(width: 1, color: Colors.transparent)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(width: 2, color: Colors.transparent)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(width: 1, color: Colors.transparent)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(width: 1, color: Colors.transparent)),
        ),
        value: value,
        items: items
            .map((p) => DropdownMenuItem(
                  child: mapper(p),
                  value: p,
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

const ovalBorderRaduis = 50.0;
const normalBorderRaduis = 13.0;
