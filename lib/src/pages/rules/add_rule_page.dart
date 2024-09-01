import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/enums.gq.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/pages/full_page_progress.dart';
import 'package:recs_front/src/pages/rules/input/boolean_rule_input_widget.dart';
import 'package:recs_front/src/pages/rules/input/number_rule_input_widget.dart';
import 'package:recs_front/src/pages/rules/input/rule_context_input.dart';
import 'package:recs_front/src/pages/rules/input/rule_field_config_input_widget.dart';
import 'package:recs_front/src/pages/rules/input/text_rule_input_widget.dart';
import 'package:recs_front/src/utils/alert_vertical_widget.dart';
import 'package:recs_front/src/utils/image_utils.dart';
import 'package:recs_front/src/utils/ui_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class AddRulePage extends StatefulWidget {
  final String? ruleId;
  const AddRulePage({super.key, this.ruleId});

  @override
  State<AddRulePage> createState() => _AddRulePageState();
}

class _AddRulePageState extends BasicState<AddRulePage> with WidgetUtilsMixin {
  final client = GetIt.instance.get<GQClient>();
  final ruleFieldKey = GlobalKey<RuleFieldConfigInputWidgtState>();
  final ruleContextKey = GlobalKey<RuleContextInputWidgetState>();
  final boolKey = GlobalKey<BooleanRuleInputWidgetState>();
  final textKey = GlobalKey<TextRuleInputWidgetState>();
  final numberKey = GlobalKey<NumberRuleInputWidgetState>();

  final selectedRuleConfigSubject = BehaviorSubject<RuleFieldConfig>();
  final stepIndex = BehaviorSubject.seeded(0);
  RuleContextInput? ruleContextInput;
  Rule? editingRule;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lang.addRule)),
      body: FutureBuilder<Rule?>(
          future: loadRule(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: AlertVerticalWidget.createWarning(lang.couldNotLoadData),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return createBody(snapshot.data);
            } else {
              return FullPageProgress(noAppBar: true);
            }
          }),
    );
  }

  Future<Rule?> loadRule() async {
    if (widget.ruleId == null) {
      return null;
    }
    if (editingRule != null && editingRule!.id == widget.ruleId) {
      return editingRule;
    }
    return client.queries
        .getRuleById(id: widget.ruleId!)
        .asStream()
        .map((event) => event.getRuleById)
        .map((event) {
      editingRule = event;
      return event;
    }).first;
  }

  Widget createBody(Rule? rule) {
    return streamBuilder<int>(
        stream: stepIndex,
        initialData: stepIndex.valueOrNull,
        onDataChanged: (currentStep) {
          return Stepper(
            controlsBuilder: (_, __) => SizedBox.shrink(),
            currentStep: currentStep,
            steps: [
              Step(
                isActive: currentStep == 0,
                title: Text(lang.ruleField),
                content: Column(
                  children: [
                    Gap(10),
                    RuleFieldConfigInputWidgt(key: ruleFieldKey, config: rule?.config),
                    Gap(10),
                    getButtons(
                      onSave: () {
                        var selected = ruleFieldKey.currentState!.read();
                        if (selected != null) {
                          selectedRuleConfigSubject.add(selected);
                          nextStep();
                        }
                      },
                      skipCancel: true,
                      saveLabel: lang.next,
                    ),
                  ],
                ),
              ),
              Step(
                isActive: currentStep == 1,
                title: Text(lang.ruleContextTitle),
                content: streamBuilder<RuleFieldConfig>(
                    stream: selectedRuleConfigSubject,
                    initialData: selectedRuleConfigSubject.valueOrNull,
                    onDataChanged: (ruleConfig) {
                      return Column(
                        children: [
                          RuleContextInputWidget(
                            key: ruleContextKey,
                            ruleContext: rule?.context,
                          ),
                          Gap(10),
                          getButtons(
                            onSave: () {
                              var selected = ruleContextKey.currentState!.read();
                              if (selected != null) {
                                ruleContextInput = selected;
                                nextStep();
                              }
                            },
                            saveLabel: lang.next,
                            onCancel: previousStep,
                            cancelLabel: lang.previous,
                          ),
                        ],
                      );
                    }),
              ),
              Step(
                isActive: currentStep == 2,
                title: Text(lang.macthingType),
                content: Column(
                  children: [
                    _createRuleInputWidget(rule),
                    Gap(10),
                    getButtons(
                      onSave: saveRule,
                      onCancel: previousStep,
                      cancelLabel: lang.previous,
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }

  void nextStep() {
    var current = stepIndex.value;
    if (current < 2) {
      stepIndex.add(current + 1);
    }
  }

  void previousStep() {
    var current = stepIndex.value;
    if (current > 0) {
      stepIndex.add(current - 1);
    }
  }

  Widget _createRuleInputWidget(Rule? rule) {
    return streamBuilder<RuleFieldConfig>(
        stream: selectedRuleConfigSubject,
        initialData: selectedRuleConfigSubject.valueOrNull,
        onDataChanged: (ruleConfig) {
          switch (ruleConfig.ruleType) {
            case RuleType.NUMBER_RULE:
              return NumberRuleInputWidget(
                key: numberKey,
                initialValue: rule?.numberRule,
              );
            case RuleType.TEXT_RULE:
              {
                switch (ruleConfig.path) {
                  case "inventories.sizeLabel":
                    break;
                  case "inventories.seasons":
                    {
                      return TextRuleInputWidget<Season>(
                        entityType: TextRuleEntityType.SEASON,
                        key: textKey,
                        initialMatchType: rule?.textRule?.matchType,
                        initialSelcetedValue: rule?.textRuleSeason?.acceptedValues,
                        selectValues: (preselected) async {
                          var result = await openSelectMultiSeason(context, preselected);
                          return result;
                        },
                        displayItem: (s) => Text(s.code),
                        getItemId: (s) => s.code,
                      );
                    }
                  case "colorLabel":
                    {
                      return TextRuleInputWidget<String>(
                        entityType: TextRuleEntityType.STRING,
                        key: textKey,
                        initialMatchType: rule?.textRule?.matchType,
                        initialSelcetedValue: rule?.textRule?.acceptedValues,
                        selectValues: (preselected) async {
                          var result = await openSelectColorLabels(context, preselected);
                          return result;
                        },
                        displayItem: (s) => Text(s),
                        getItemId: (e) => e,
                      );
                    }
                  case "categoryId":
                    {
                      return TextRuleInputWidget<Category>(
                        entityType: TextRuleEntityType.CATEGORY,
                        key: textKey,
                        initialMatchType: rule?.textRule?.matchType,
                        initialSelcetedValue: rule?.textRuleCategory?.acceptedValues,
                        selectValues: (preselected) async {
                          var result =
                              await openSelectCategyTree(context, preselected.map((e) => e.id).toList());
                          return result;
                        },
                        displayItem: (s) => Text(s.name),
                        getItemId: (e) => e.id,
                      );
                    }
                  case "brand":
                    {
                      return TextRuleInputWidget<String>(
                        entityType: TextRuleEntityType.STRING,
                        key: textKey,
                        initialMatchType: rule?.textRule?.matchType,
                        initialSelcetedValue: rule?.textRule?.acceptedValues,
                        selectValues: (preselected) async {
                          var result = await openSelectBrands(context, preselected);
                          return result;
                        },
                        displayItem: (s) => Text(s),
                        getItemId: (e) => e,
                      );
                    }

                  case "designer":
                    {
                      {
                        return TextRuleInputWidget<String>(
                          entityType: TextRuleEntityType.STRING,
                          key: textKey,
                          initialMatchType: rule?.textRule?.matchType,
                          initialSelcetedValue: rule?.textRule?.acceptedValues,
                          selectValues: (preselected) async {
                            var result = await openSelectDesigners(context, preselected);
                            return result;
                          },
                          displayItem: (s) => Text(s),
                          getItemId: (e) => e,
                        );
                      }
                    }

                  case "gender":
                    {
                      return TextRuleInputWidget<String>(
                        entityType: TextRuleEntityType.STRING,
                        key: textKey,
                        initialMatchType: rule?.textRule?.matchType,
                        initialSelcetedValue: rule?.textRule?.acceptedValues,
                        selectValues: (preselected) async {
                          var result = await openSelectGenders(context, preselected);
                          return result;
                        },
                        displayItem: (s) => Text(s),
                        getItemId: (e) => e,
                      );
                    }

                  case "productId":
                    {
                      return TextRuleInputWidget<Product>(
                        entityType: TextRuleEntityType.PRODUCT,
                        key: textKey,
                        initialMatchType: rule?.textRule?.matchType,
                        initialSelcetedValue: rule?.textRuleProduct?.acceptedValues,
                        selectValues: (preselected) async {
                          var result = await openSelectMultiProducts(context, preselected);
                          return result;
                        },
                        displayItem: (s) => ListTile(
                          leading: ImageUtils.fromNetwork(s.firstImageUrl),
                          title: Text(s.name),
                          subtitle: Text(s.id),
                        ),
                        getItemId: (e) => e.id,
                      );
                    }
                  case "gtin":
                    {
                      return TextRuleInputWidget<Sku>(
                        entityType: TextRuleEntityType.SKU,
                        key: textKey,
                        initialMatchType: rule?.textRule?.matchType,
                        initialSelcetedValue: rule?.textRuleSku?.acceptedValues,
                        selectValues: (preselected) async {
                          var result = await openSelectMultiSkus(context, preselected);
                          return result;
                        },
                        displayItem: (s) => ListTile(
                          leading: ImageUtils.fromNetwork(s.imageUrl),
                          title: Text(s.name),
                          subtitle: Text(s.id),
                        ),
                        getItemId: (e) => e.id,
                      );
                    }
                  default:
                    throw Exception("${ruleConfig.path} is not supported yet");
                }
                return SizedBox.shrink();
              }
            case RuleType.BOOLEAN_RULE:
              return BooleanRuleInputWidget(
                key: boolKey,
              );
          }
        });
  }

  void saveRule() async {
    if (selectedRuleConfigSubject.hasValue &&
        this.ruleContextInput != null &&
        selectedRuleConfigSubject.hasValue) {
      var ruleConfig = selectedRuleConfigSubject.value;
      var ruleContextInput = this.ruleContextInput!;
      NumberRuleInput? numberRuleInput;
      BooleanRuleInput? booleanRuleInput;
      TextRuleInput? textRuleInput;
      switch (ruleConfig.ruleType) {
        case RuleType.NUMBER_RULE:
          {
            numberRuleInput = numberKey.currentState!.read();
          }
          break;
        case RuleType.TEXT_RULE:
          {
            textRuleInput = textKey.currentState!.read();
          }
          break;
        case RuleType.BOOLEAN_RULE:
          {
            booleanRuleInput = boolKey.currentState!.read();
          }
      }
      if (numberRuleInput == null && textRuleInput == null && booleanRuleInput == null) {
        return;
      }
      var ruleInput = RuleInput(
          id: widget.ruleId,
          contextInput: ruleContextInput,
          ruleType: ruleConfig.ruleType,
          booleanRuleInput: booleanRuleInput,
          textRuleInput: textRuleInput,
          numberRuleInput: numberRuleInput,
          ruleFieldConfigInput: RuleFieldConfigInput(
            label: ruleConfig.label,
            path: ruleConfig.path,
            ruleType: ruleConfig.ruleType,
          ));
      try {
        progressSubject.add(true);
        var rule = await client.mutations.createRule(input: ruleInput);
        await showSnackBar2(context, lang.ruleCreated);
        Navigator.of(context).pop(rule);
      } catch (err, ex) {
        print(ex);
        showServerError2(context, error: err);
      } finally {
        progressSubject.add(false);
      }
    }
  }
}
