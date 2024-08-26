import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class RuleFieldConfigInputWidgt extends StatefulWidget {
  final RuleFieldConfig? config;
  const RuleFieldConfigInputWidgt({super.key, required this.config});

  @override
  State<RuleFieldConfigInputWidgt> createState() => RuleFieldConfigInputWidgtState();
}

class RuleFieldConfigInputWidgtState extends BasicState<RuleFieldConfigInputWidgt> with WidgetUtilsMixin {
  final client = GetIt.instance.get<GQClient>();
  final selectedRuleConfigSubject = BehaviorSubject<RuleFieldConfig>();
  final ruleConfigListSubject = BehaviorSubject<List<RuleFieldConfig>>();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    client.queries
        .getRuleFieldConfigList()
        .asStream()
        .map((event) => event.ruleFieldConfigList)
        .listen((list) {
      ruleConfigListSubject.add(list);
      var conf = widget.config;
      if (conf != null) {
        var filtered =
            list.where((element) => element.ruleType == conf.ruleType && element.path == conf.path).toList();
        if (filtered.isNotEmpty) {
          selectedRuleConfigSubject.add(filtered.first);
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: StreamBuilder<List<RuleFieldConfig>>(
          stream: ruleConfigListSubject,
          initialData: ruleConfigListSubject.valueOrNull,
          builder: (context, snapshot) {
            var data = snapshot.data ?? [];

            return StreamBuilder<RuleFieldConfig>(
                stream: selectedRuleConfigSubject,
                initialData: selectedRuleConfigSubject.valueOrNull,
                builder: (context, snapshot) {
                  return DropdownButtonFormField<RuleFieldConfig>(
                    decoration: getDecoration(lang.ruleField, true),
                    validator: (value) {
                      if (value == null) {
                        return lang.requiredField;
                      }
                      return null;
                    },
                    value: snapshot.data,
                    items: data
                        .map((e) => DropdownMenuItem<RuleFieldConfig>(
                              child: Text(e.label),
                              value: e,
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        selectedRuleConfigSubject.add(newValue);
                      }
                    },
                  );
                });
          }),
    );
  }

  RuleFieldConfig? read() {
    if (formKey.currentState!.validate()) {
      return selectedRuleConfigSubject.value;
    }
    return null;
  }
}
