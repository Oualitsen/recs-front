import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view_2/infinite_scroll_list_view.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/src/utils/ui_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class ItemSelectWidget<T> extends StatefulWidget {
  final bool multiple;
  final Future<List<T>> Function(int page, String? filter) getItems;
  final Widget Function(T item) displayItem;
  final void Function(List<T> selectedItems) onSelected;
  final List<T> preselectedValues;
  final bool enableSearch;
  final String? searchLabel;
  const ItemSelectWidget({
    super.key,
    this.multiple = false,
    required this.getItems,
    required this.displayItem,
    required this.onSelected,
    this.preselectedValues = const [],
    this.enableSearch = false,
    this.searchLabel,
  });

  @override
  State<ItemSelectWidget> createState() => ItemSelectWidgetState<T>();
}

class ItemSelectWidgetState<T> extends BasicState<ItemSelectWidget<T>> with WidgetUtilsMixin {
  final client = GetIt.instance.get<GQClient>();
  final items = BehaviorSubject<List<T>>();
  final selectedItemsSubject = BehaviorSubject.seeded(<T>[]);
  final filterSubject = BehaviorSubject<String>.seeded("");
  final listKey = GlobalKey<InfiniteScrollListViewState>();

  @override
  void initState() {
    selectedItemsSubject.value.addAll(widget.preselectedValues);
    if (widget.enableSearch) {
      filterSubject.debounceTime(Duration(milliseconds: 500)).listen((event) {
        print("event .... ${event} relading state");
        listKey.currentState!.reload();
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return streamBuilder<List<T>>(
        stream: selectedItemsSubject,
        initialData: selectedItemsSubject.valueOrNull,
        onDataChanged: (selectedSet) {
          return Column(
            children: [
              if (widget.enableSearch)
                TextFormField(
                  onChanged: filterSubject.add,
                  decoration: getDecoration(
                    widget.searchLabel ?? lang.search,
                    false,
                  ),
                ),
              Expanded(
                child: InfiniteScrollListView<T>(
                    key: listKey,
                    elementBuilder: (context, T element, index, animation) {
                      if (widget.multiple) {
                        return CheckboxListTile(
                          title: widget.displayItem(element),
                          value: _isSelected(element),
                          onChanged: ((value) {
                            if (value != null) {
                              if (value) {
                                selectedSet.add(element);
                              } else {
                                selectedSet.remove(element);
                              }
                              selectedItemsSubject.add(selectedSet);
                            }
                          }),
                        );
                      } else {
                        return ListTile(
                          title: widget.displayItem(element),
                          onTap: () => widget.onSelected([element]),
                        );
                      }
                    },
                    pageLoader: pageLoader),
              ),
            ],
          );
        });
  }

  bool _isSelected(T element) {
    var set = selectedItemsSubject.value;
    return set.contains(element);
  }

  Future<List<T>> pageLoader(int pageIdex) {
    String? text = null;
    if (widget.enableSearch) {
      text = filterSubject.value.trim();
    }
    return widget.getItems(pageIdex, text);
  }

  List<T> getSelectedItems() {
    return selectedItemsSubject.value.toList();
  }
}
