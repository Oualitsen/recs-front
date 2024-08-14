import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/selection_type.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/subjects.dart';
import 'package:infinite_scroll_list_view_2/infinite_scroll_list_view.dart'
    as list;
import 'package:recs_front/generated/inputs.gq.dart';

class SelectCategoryWidget extends StatefulWidget {
  final SelectionType selectionType;
  final List<Category> initialElements;
  final void Function(List<Category> category) selectedCategory;
  const SelectCategoryWidget({
    super.key,
    required this.selectedCategory,
    this.selectionType = SelectionType.SINGLE,
    required this.initialElements,
  });

  @override
  State<SelectCategoryWidget> createState() => SelectCategoryWidgetState();
}

class SelectCategoryWidgetState extends BasicState<SelectCategoryWidget>
    with WidgetUtilsMixin {
  final client = GetIt.instance.get<GQClient>();
  final selectedElementStream = BehaviorSubject.seeded(<Category>[]);
  final listMultipleKey = GlobalKey<list.InfiniteScrollListViewState>();
  final listSingleKey = GlobalKey<list.InfiniteScrollListViewState>();
  @override
  void initState() {
    selectedElementStream.add(widget.initialElements);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.selectionType == SelectionType.SINGLE
        ? singleSelection()
        : multipleSelection();
  }

  singleSelection() {
    return list.InfiniteScrollListView<Category>(
      key: listSingleKey,
      elementBuilder: (BuildContext context, element, int index, animation) {
        return ListTile(
          leading: CircleAvatar(child: Text("${index + 1}")),
          title: Text(element.name),
          subtitle: Text(element.id),
          onTap: () {
            widget.selectedCategory([element]);
          },
        );
      },
      pageLoader: getData,
    );
  }

  multipleSelection() {
    return StreamBuilder<List<Category>>(
      key: listMultipleKey,
      stream: selectedElementStream,
      initialData: selectedElementStream.value,
      builder: (context, snapshot) {
        return list.InfiniteScrollListView<Category>(
          elementBuilder: (BuildContext context, data, int index, animation) {
            final selectedElements = snapshot.data!;

            return CheckboxListTile(
              value: selectedElementStream.value
                  .map((e) => e.id)
                  .toList()
                  .contains(data.id),
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  if (newValue) {
                    selectedElements.add(data);
                  } else {
                    selectedElements
                        .removeWhere((element) => element.id == data.id);
                  }
                  selectedElementStream.add(selectedElements);
                  widget.selectedCategory(selectedElements);
                }
              },
              title: Text("${data.name}"),
              subtitle: Text(data.id),
            );
          },
          pageLoader: getData,
        );
      },
    );
  }

  reload() {
    if (widget.selectionType == SelectionType.SINGLE) {
      listSingleKey.currentState?.reload();
    } else {
      listMultipleKey.currentState?.reload();
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  Future<List<Category>?> getData(int index) {
    return client.queries
        .getCategories(
          pageInfo: PageInfo(page: index, size: 20),
        )
        .asStream()
        .map((event) => event.getCategories)
        .first;
  }
}
