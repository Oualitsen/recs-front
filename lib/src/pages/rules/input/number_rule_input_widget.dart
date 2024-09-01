import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:recs_front/generated/enums.gq.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/utils/ui_utils.dart';
import 'package:recs_front/src/utils/validation_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class NumberRuleInputWidget extends StatefulWidget {
  final NumberRule? initialValue;

  const NumberRuleInputWidget({
    super.key,
    required this.initialValue,
  });

  @override
  State<NumberRuleInputWidget> createState() => NumberRuleInputWidgetState();
}

class NumberRuleInputWidgetState extends BasicState<NumberRuleInputWidget> with WidgetUtilsMixin {
  final formKey = GlobalKey<FormState>();
  final sameValueSubject = BehaviorSubject.seeded(false);
  final percentageSubject = BehaviorSubject.seeded(false);
  final operatorSubject = BehaviorSubject<NumberRuleOperator>();

  final upper = TextEditingController();
  final lower = TextEditingController();

  @override
  void initState() {
    var init = widget.initialValue;
    if (init != null) {
      sameValueSubject.add(init.sameValueOnly);
      percentageSubject.add(init.percentage);
      if (init.percentage) {
        upper.text = "${init.upperBound * 100}";
        lower.text = "${init.upperBound * 100}";
      } else {
        upper.text = "${init.upperBound}";
        lower.text = "${init.upperBound}";
      }
      operatorSubject.add(init.operator);
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
                streamBuilder<bool>(
                    stream: sameValueSubject,
                    initialData: sameValueSubject.valueOrNull,
                    onDataChanged: (data) {
                      return CheckboxListTile(
                          title: Text(lang.sameValueOnly),
                          value: data,
                          onChanged: (newValue) {
                            if (newValue != null) {
                              sameValueSubject.add(newValue);
                            }
                          });
                    }),
                StreamBuilder<_ValuesRecord>(
                    stream: Rx.combineLatest2(
                        percentageSubject,
                        sameValueSubject,
                        (val1, val2) => _ValuesRecord(
                            percentage: val1, sameValue: val2, operator: NumberRuleOperator.BETWEEN)),
                    builder: (context, snapshot) {
                      var value = snapshot.data;
                      if (value == null || value.sameValue) {
                        return SizedBox.shrink();
                      }

                      return CheckboxListTile(
                          title: Text(lang.percenatge),
                          value: value.percentage,
                          onChanged: (newValue) {
                            if (newValue != null) {
                              percentageSubject.add(newValue);
                            }
                          });
                    }),
                Gap(10),
                streamBuilder(
                    stream: sameValueSubject,
                    onDataChanged: (sameValue) {
                      if (sameValue) {
                        return SizedBox.shrink();
                      }
                      return StreamBuilder<NumberRuleOperator>(
                          stream: operatorSubject,
                          builder: (context, snapshot) {
                            var value = snapshot.data;
                            return DropdownButtonFormField<NumberRuleOperator>(
                              decoration: getDecoration(lang.operator, true),
                              value: value,
                              validator: (val) {
                                if (val == null) {
                                  return lang.requiredField;
                                }
                                return null;
                              },
                              items: NumberRuleOperator.values
                                  .map((e) => DropdownMenuItem<NumberRuleOperator>(
                                        child: Text(lang.getOperatorName(e)),
                                        value: e,
                                      ))
                                  .toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  operatorSubject.add(newValue);
                                }
                              },
                            );
                          });
                    }),
                Gap(10),
                StreamBuilder<_ValuesRecord>(
                    stream: Rx.combineLatest3(sameValueSubject, percentageSubject, operatorSubject,
                        (a, b, c) => _ValuesRecord(sameValue: a, percentage: b, operator: c)),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.sameValue) {
                        return SizedBox.shrink();
                      }
                      var isPercentage = snapshot.data!.percentage;
                      var operator = snapshot.data!.operator;
                      var lowerBoundLabel = operator == NumberRuleOperator.BETWEEN
                          ? lang.lowerBoundMaxValue
                          : lang.numberRuleValue;
                      return Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              validator: (text) {
                                if (isPercentage) {
                                  return ValidationUtils.doubleValidator(text, context,
                                      minValue: 0, maxValue: 100, required: true);
                                } else {
                                  return ValidationUtils.doubleValidator(text, context,
                                      minValue: 0, required: true);
                                }
                              },
                              controller: lower,
                              decoration: getDecoration(lowerBoundLabel, true,
                                  suffixIcon: isPercentage ? Icon(Icons.percent) : null),
                            ),
                          ),
                          if (operator == NumberRuleOperator.BETWEEN) ...[
                            Gap(16),
                            Expanded(
                              child: TextFormField(
                                validator: (text) {
                                  String? validationError;
                                  if (isPercentage) {
                                    validationError = ValidationUtils.doubleValidator(text, context,
                                        minValue: 0, maxValue: 100, required: true);
                                  } else {
                                    validationError = ValidationUtils.doubleValidator(text, context,
                                        minValue: 0, required: true);
                                  }
                                  if (validationError != null) {
                                    return validationError;
                                  }

                                  var lowerValue = double.tryParse(lower.text);
                                  if (lowerValue != null) {
                                    var upperValue = double.parse(text!);
                                    if (lowerValue > upperValue) {
                                      return lang.lowUpError;
                                    }
                                  }
                                  return null;
                                },
                                controller: upper,
                                decoration: getDecoration(lang.upperBoundMaxValue, true,
                                    suffixIcon: isPercentage ? Icon(Icons.percent) : null),
                              ),
                            ),
                          ]
                        ],
                      );
                    })
              ],
            )),
      ),
    );
  }

  NumberRuleInput? read() {
    if (formKey.currentState!.validate()) {
      if (percentageSubject.value) {
        return NumberRuleInput(
          percentage: percentageSubject.value,
          lowerBound: (double.tryParse(lower.text) ?? 0) / 100,
          upperBound: (double.tryParse(upper.text) ?? 0) / 100,
          sameValueOnly: sameValueSubject.value,
          operator: operatorSubject.valueOrNull ?? NumberRuleOperator.BETWEEN,
        );
      } else {
        return NumberRuleInput(
          percentage: percentageSubject.value,
          lowerBound: double.tryParse(lower.text) ?? 0,
          upperBound: double.tryParse(upper.text) ?? 0,
          sameValueOnly: sameValueSubject.value,
          operator: operatorSubject.valueOrNull ?? NumberRuleOperator.BETWEEN,
        );
      }
    }
    return null;
  }
}

class _ValuesRecord {
  final bool sameValue;
  final bool percentage;
  final NumberRuleOperator operator;

  _ValuesRecord({required this.sameValue, required this.percentage, required this.operator});
}
