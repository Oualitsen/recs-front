import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:recs_front/generated/enums.gq.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/utils/alert_vertical_widget.dart';
import 'package:recs_front/src/utils/ui_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class TextRuleInputWidget<T> extends StatefulWidget {
  final Future<List<T>?> Function(List<T> values) selectValues;
  final Widget Function(T item) displayItem;
  final String Function(T item) getItemId;
  final TextRuleMatchType? initialMatchType;
  final List<T>? initialSelcetedValue;
  final TextRuleEntityType entityType;
  const TextRuleInputWidget({
    super.key,
    required this.selectValues,
    required this.displayItem,
    required this.getItemId,
    required this.initialMatchType,
    required this.initialSelcetedValue,
    required this.entityType,
  });

  @override
  State<TextRuleInputWidget> createState() => TextRuleInputWidgetState<T>();
}

class TextRuleInputWidgetState<T> extends BasicState<TextRuleInputWidget<T>> with WidgetUtilsMixin {
  final formKey = GlobalKey<FormState>();
  final matchTypeSubject = BehaviorSubject<TextRuleMatchType>();
  final selectedValues = BehaviorSubject.seeded(<T>[]);
  final acceptedValuesError = BehaviorSubject<bool>();
  @override
  void initState() {
    var init = widget.initialMatchType;
    var initSelected = widget.initialSelcetedValue;
    print("initSelected = ${initSelected}");
    if (init != null) {
      matchTypeSubject.add(init);
    }
    if (initSelected != null) {
      selectedValues.add(initSelected);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              streamBuilder<TextRuleMatchType>(
                  stream: matchTypeSubject,
                  initialData: matchTypeSubject.valueOrNull,
                  onDataChanged: (data) {
                    return DropdownButtonFormField<TextRuleMatchType>(
                        value: data,
                        validator: (value) {
                          if (value == null) {
                            return lang.requiredField;
                          }
                          return null;
                        },
                        decoration: getDecoration(lang.textRuleMatchType, true),
                        items: TextRuleMatchType.values
                            .map(
                              (e) => DropdownMenuItem(
                                child: Text(lang.textRuleMatchTypeName(e)),
                                value: e,
                              ),
                            )
                            .toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            matchTypeSubject.add(newValue);
                          }
                        });
                  }),
              StreamBuilder<bool>(
                  stream: this.acceptedValuesError,
                  initialData: acceptedValuesError.valueOrNull,
                  builder: (context, snapshot) {
                    if (snapshot.data ?? false) {
                      return AlertVerticalWidget.createDanger(lang.requiredField);
                    }
                    return SizedBox.shrink();
                  }),
              StreamBuilder<List<T>>(
                  stream: selectedValues,
                  initialData: selectedValues.valueOrNull,
                  builder: (context, snapshot) {
                    var values = snapshot.data ?? <T>[];
                    return Column(
                      children: values
                          .map((e) => ListTile(
                                title: widget.displayItem(e),
                                trailing: TextButton.icon(
                                  onPressed: () => delete(e),
                                  icon: Icon(Icons.delete),
                                  label: Text(lang.delete),
                                ),
                              ))
                          .toList(),
                    );
                  }),
              Gap(16),
              StreamBuilder<TextRuleMatchType>(
                  stream: matchTypeSubject,
                  initialData: matchTypeSubject.valueOrNull,
                  builder: (context, snapshot) {
                    if (snapshot.data == TextRuleMatchType.ACCEPTED_VALUES) {
                      return FilledButton(
                          onPressed: () async {
                            var selectedValues =
                                await widget.selectValues(this.selectedValues.valueOrNull ?? []);
                            if (selectedValues != null && selectedValues.isNotEmpty) {
                              setSelectedValues(selectedValues);
                            }
                          },
                          child: Text(lang.addAcceptedValues));
                    }
                    return SizedBox.shrink();
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void setSelectedValues(List<T> values) {
    selectedValues.add(values);
    if (this.acceptedValuesError.valueOrNull ?? false) {
      this.acceptedValuesError.add(false);
    }
  }

  void delete(T element) {
    selectedValues.value.remove(element);
    selectedValues.add(selectedValues.value);
  }

  TextRuleInput? read() {
    if (!formKey.currentState!.validate()) {
      return null;
    }
    if (matchTypeSubject.value == TextRuleMatchType.ACCEPTED_VALUES &&
        (selectedValues.valueOrNull ?? []).isEmpty) {
      acceptedValuesError.add(true);
      return null;
    } else {
      acceptedValuesError.add(false);
      //create input here
      return TextRuleInput(
          acceptedValues: (selectedValues.valueOrNull ?? []).map((e) => widget.getItemId(e)).toList(),
          matchType: matchTypeSubject.value,
          entityType: widget.entityType);
    }
  }
}
