import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
                StreamBuilder<List<bool>>(
                    stream:
                        Rx.combineLatest2(percentageSubject, sameValueSubject, (val1, val2) => [val1, val2]),
                    builder: (context, snapshot) {
                      var array = snapshot.data;
                      if (array == null || array[1]) {
                        return SizedBox.shrink();
                      }

                      return CheckboxListTile(
                          title: Text(lang.percenatge),
                          value: array.first,
                          onChanged: (newValue) {
                            if (newValue != null) {
                              percentageSubject.add(newValue);
                            }
                          });
                    }),
                StreamBuilder<List<bool>>(
                    stream: Rx.combineLatest2(sameValueSubject, percentageSubject, (a, b) => [a, b]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.first) {
                        return SizedBox.shrink();
                      }
                      var isPercentage = snapshot.data!.last;
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
                              decoration: getDecoration(lang.lowerBoundMaxValue, true,
                                  suffixIcon: isPercentage ? Icon(Icons.percent) : null),
                            ),
                          ),
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
          lowerBound: double.parse(lower.text) / 100,
          upperBound: double.parse(upper.text) / 100,
          sameValueOnly: sameValueSubject.value,
        );
      } else {
        return NumberRuleInput(
          percentage: percentageSubject.value,
          lowerBound: double.parse(lower.text),
          upperBound: double.parse(upper.text),
          sameValueOnly: sameValueSubject.value,
        );
      }
    }
    return null;
  }
}
