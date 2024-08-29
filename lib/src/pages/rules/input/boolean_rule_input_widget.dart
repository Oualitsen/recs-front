import 'package:flutter/material.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class BooleanRuleInputWidget extends StatefulWidget {
  final bool? initialValue;
  const BooleanRuleInputWidget({super.key, this.initialValue});

  @override
  State<BooleanRuleInputWidget> createState() => BooleanRuleInputWidgetState();
}

class BooleanRuleInputWidgetState extends BasicState<BooleanRuleInputWidget> with WidgetUtilsMixin {
  final subject = BehaviorSubject<bool>();
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    var initValue = widget.initialValue;
    if (initValue != null) {
      subject.add(initValue);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: StreamBuilder<bool>(
          stream: subject,
          initialData: subject.valueOrNull,
          builder: (context, snapshot) {
            return DropdownButtonFormField<bool>(
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
                    subject.add(newValue);
                  }
                });
          }),
    );
  }

  BooleanRuleInput? read() {
    if (formKey.currentState?.validate() ?? false) {
      return BooleanRuleInput(acceptedValue: subject.value);
    }
    return null;
  }
}
