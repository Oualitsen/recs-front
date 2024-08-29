import 'package:flutter/material.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/utils/alert_vertical_widget.dart';
import 'package:recs_front/src/utils/utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class RuleContextInputWidget extends StatefulWidget {
  final RuleContext? ruleContext;
  RuleContextInputWidget({
    super.key,
    required this.ruleContext,
  });

  @override
  State<RuleContextInputWidget> createState() => RuleContextInputWidgetState();
}

class RuleContextInputWidgetState extends BasicState<RuleContextInputWidget> with WidgetUtilsMixin {
  final applyOnAllSubject = BehaviorSubject.seeded(false);
  final selectedBrands = BehaviorSubject.seeded(<String>[]);
  final selectedDesigners = BehaviorSubject.seeded(<String>[]);
  final selectedColors = BehaviorSubject.seeded(<String>[]);
  final selectedCategories = BehaviorSubject.seeded(<Category>[]);

  @override
  void initState() {
    var context = widget.ruleContext;
    if (context != null) {
      applyOnAllSubject.add(context.appliesOnAllProducts);
      selectedBrands.add(context.brands);
      selectedDesigners.add(context.designers);
      selectedColors.add(context.colorLabels);
      selectedCategories.add(context.categories);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            StreamBuilder<bool>(
                stream: applyOnAllSubject,
                initialData: applyOnAllSubject.valueOrNull,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox.shrink();
                  }
                  var data = snapshot.data!;
                  return CheckboxListTile(
                      title: Text(lang.applyOnAllProducts),
                      value: data,
                      onChanged: (newValue) {
                        if (newValue != null) {
                          applyOnAllSubject.add(newValue);
                        }
                      });
                }),
            StreamBuilder<bool>(
                stream: applyOnAllSubject,
                initialData: applyOnAllSubject.valueOrNull,
                builder: (context, snapshot) {
                  var applyOnAll = snapshot.data ?? false;
                  if (applyOnAll) {
                    return SizedBox.shrink();
                  }
                  return SizedBox(
                    height: 400,
                    child: DefaultTabController(
                        length: 4,
                        child: Column(
                          children: [
                            TabBar(tabs: [
                              Tab(child: createTabLabel(selectedCategories, lang.categories)),
                              Tab(child: createTabLabel(selectedBrands, lang.brands)),
                              Tab(child: createTabLabel(selectedDesigners, lang.designers)),
                              Tab(child: createTabLabel(selectedColors, lang.colorLabels)),
                            ]),
                            Expanded(
                              child: TabBarView(children: [
                                createDataList<Category>(
                                  selectedCategories,
                                  (item) => Text(item.name),
                                  (sv) => openSelectCategyTree(context, sv.map((e) => e.id).toList()),
                                ),
                                createDataList<String>(
                                  selectedBrands,
                                  (item) => Text(item),
                                  (sv) => openSelectBrands(context, sv),
                                ),
                                createDataList<String>(
                                  selectedDesigners,
                                  (item) => Text(item),
                                  (sv) => openSelectDesigners(context, sv),
                                ),
                                createDataList<String>(
                                  selectedColors,
                                  (item) => Text(item),
                                  (sv) => openSelectColorLabels(context, sv),
                                ),
                              ]),
                            )
                          ],
                        )),
                  );
                })
          ],
        ),
      ),
    );
  }

  Widget createTabLabel(BehaviorSubject<List> subject, String text) {
    return StreamBuilder<List>(
        stream: subject,
        initialData: subject.valueOrNull,
        builder: (context, snapshot) {
          var count = (snapshot.data ?? []).length;
          return Text("${text} $count");
        });
  }

  Widget createDataList<T>(
    BehaviorSubject<List<T>> subject,
    Widget Function(T item) display,
    final Future<List<T>?> Function(List<T> values) selectValues,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FilledButton(
                  onPressed: () async {
                    var selectedValues = await selectValues(subject.valueOrNull ?? []);
                    if (selectedValues != null) {
                      subject.add(selectedValues);
                    }
                  },
                  child: Text(lang.add)),
            ),
          ],
        ),
        Expanded(
          child: StreamBuilder<List<T>>(
              stream: subject,
              initialData: subject.valueOrNull,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox.shrink();
                }
                var data = snapshot.data!;
                if (data.length == 0) {
                  return Center(
                    child: AlertVerticalWidget.createInfo(lang.noData),
                  );
                }
                return ListView(
                  children: data
                      .map((e) => ListTile(
                            title: display(e),
                            trailing: TextButton.icon(
                              onPressed: () {
                                data.remove(e);
                                subject.add(data);
                              },
                              icon: Icon(Icons.delete),
                              label: Text(lang.delete),
                            ),
                          ))
                      .toList(),
                );
              }),
        ),
      ],
    );
  }

  RuleContextInput? read() {
    if (applyOnAllSubject.value || !noSelecteValue()) {
      return _createInput();
    } else {
      showAlertDialog(
          context: context,
          title: lang.warning,
          message: lang.invalidRuleContextInput(lang.applyOnAllProducts));
      return null;
    }
  }

  RuleContextInput _createInput() {
    return RuleContextInput(
      brands: selectedBrands.value,
      designers: selectedDesigners.value,
      categoryIds: selectedCategories.value.map((e) => e.id).toList(),
      productIds: [],
      skuIds: [],
      appliesOnAllProducts: applyOnAllSubject.value,
      colorLabels: selectedColors.value,
    );
  }

  bool noSelecteValue() {
    return selectedBrands.value.isEmpty &&
        selectedDesigners.value.isEmpty &&
        selectedCategories.value.isEmpty &&
        selectedColors.value.isEmpty;
  }
}
