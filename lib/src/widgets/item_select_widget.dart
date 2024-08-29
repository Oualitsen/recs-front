import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view_2/infinite_scroll_list_view.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils.dart';
import 'package:rxdart/rxdart.dart';

class ItemSelectWidget<T> extends StatefulWidget {
  final bool multiple;
  final Future<List<T>> Function(int page, String? filter) getItems;
  final Widget Function(T item) displayItem;
  final void Function(List<T> selectedItems) onSelected;
  final List<T> preselectedValues;
  const ItemSelectWidget({
    super.key,
    this.multiple = false,
    required this.getItems,
    required this.displayItem,
    required this.onSelected,
    this.preselectedValues = const [],
  });

  @override
  State<ItemSelectWidget> createState() => ItemSelectWidgetState<T>();
}

class ItemSelectWidgetState<T> extends BasicState<ItemSelectWidget<T>> {
  final client = GetIt.instance.get<GQClient>();
  final items = BehaviorSubject<List<T>>();
  final selectedItemsSubject = BehaviorSubject.seeded(<T>[]);

  @override
  void initState() {
    selectedItemsSubject.value.addAll(widget.preselectedValues);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
        stream: selectedItemsSubject,
        initialData: selectedItemsSubject.valueOrNull,
        builder: (context, snapshot) {
          var selectedSet = snapshot.data;
          if (selectedSet == null) {
            return SizedBox.shrink();
          }
          return InfiniteScrollListView<T>(
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
              pageLoader: pageLoader);
        });
  }

  bool _isSelected(T element) {
    var set = selectedItemsSubject.value;
    return set.contains(element);
  }

  Future<List<T>> pageLoader(int pageIdex) {
    return widget.getItems(pageIdex, null);
  }

  List<T> getSelectedItems() {
    return selectedItemsSubject.value.toList();
  }
}
