import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class BooleanRuleInputWidget extends StatefulWidget {
  final bool? initialValue;
  final bool? initialSameValue;
  const BooleanRuleInputWidget({super.key, required this.initialValue, required this.initialSameValue});

  @override
  State<BooleanRuleInputWidget> createState() => BooleanRuleInputWidgetState();
}

class BooleanRuleInputWidgetState extends BasicState<BooleanRuleInputWidget> with WidgetUtilsMixin {
  final acceptedValueSubject = BehaviorSubject<bool>();
  final sameValueSubject = BehaviorSubject<bool>();
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    var initValue = widget.initialValue;
    if (initValue != null) {
      acceptedValueSubject.add(initValue);
    }
    var initSameValue = widget.initialSameValue;
    if (initSameValue != null) {
      sameValueSubject.add(initSameValue);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: StreamBuilder<bool>(
          stream: sameValueSubject,
          initialData: sameValueSubject.valueOrNull,
          builder: (context, snapshot) {
            var sameValue = snapshot.data ?? false;
            return Column(
              children: [
                Gap(10),
                DropdownButtonFormField<bool>(
                    decoration: getDecoration(lang.sameValueOnly, true),
                    validator: (newVal) {
                      if (newVal == null) {
                        return lang.requiredField;
                      }
                      return null;
                    },
                    value: snapshot.data,
                    items: [true, false]
                        .map((e) => DropdownMenuItem<bool>(
                              child: Text(lang.getBoolName(e)),
                              value: e,
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        sameValueSubject.add(newValue);
                      }
                    }),
                Gap(10),
                if (!sameValue)
                  StreamBuilder<bool>(
                      stream: acceptedValueSubject,
                      initialData: acceptedValueSubject.valueOrNull,
                      builder: (context, snapshot) {
                        return DropdownButtonFormField<bool>(
                            validator: (newVal) {
                              if (newVal == null) {
                                return lang.requiredField;
                              }
                              return null;
                            },
                            decoration: getDecoration(lang.acceptedValue, true),
                            value: snapshot.data,
                            items: [true, false]
                                .map((e) => DropdownMenuItem<bool>(
                                      child: Text(lang.getBoolName(e)),
                                      value: e,
                                    ))
                                .toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                acceptedValueSubject.add(newValue);
                              }
                            });
                      }),
              ],
            );
          }),
    );
  }

  BooleanRuleInput? read() {
    if (formKey.currentState?.validate() ?? false) {
      return BooleanRuleInput(
          acceptedValue: acceptedValueSubject.valueOrNull ?? false, sameValue: sameValueSubject.value);
    }
    return null;
  }
}
