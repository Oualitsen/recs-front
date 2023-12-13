import 'package:flutter/material.dart';
import 'package:recs_ymal/src/widgets/basic_state.dart';
import 'package:recs_ymal/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class MultiSelectWidget<T> extends StatefulWidget {
  final List<T> items;
  final List<T> initialData;
  final String Function(T type) mapper;
  final bool Function(T a, T b) comparator;
  final void Function(List<T>) onSelectionChanged;
  const MultiSelectWidget(
      {super.key,
      required this.items,
      required this.onSelectionChanged,
      required this.initialData,
      required this.comparator,
      required this.mapper});

  @override
  State<MultiSelectWidget<T>> createState() => MultiSelectWidgetState<T>();
}

class MultiSelectWidgetState<T> extends BasicState<MultiSelectWidget<T>> with WidgetUtilsMixin {
  final selectedItems = BehaviorSubject.seeded(<T>{});

  @override
  void initState() {
    selectedItems.add(widget.initialData.toSet());
    super.initState();
  }

  void init(List<T> preSelected) {
    var list = selectedItems.value;
    list.addAll(preSelected);
    selectedItems.add(list);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Set<T>>(
        stream: selectedItems,
        initialData: selectedItems.value,
        builder: (context, snapshot) {
          var selected = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(widget.mapper(widget.items[index])),
                      value: selected
                          .where((element) => widget.comparator(element, widget.items[index]))
                          .isNotEmpty,
                      onChanged: (value) {
                        print("on changed bvalue is $value");
                        if (value != null) {
                          if (value) {
                            selected.add(widget.items[index]);
                          } else {
                            selected
                                .removeWhere((element) => widget.comparator(element, widget.items[index]));
                          }
                          selectedItems.add(selected);
                        }
                      },
                    );
                  },
                ),
              ),
              getButtons(
                onSave: () {
                  widget.onSelectionChanged(selectedItems.value.toList());
                },
              )
            ],
          );
        });
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
