import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/selection_type.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/subjects.dart';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:rxdart/rxdart.dart';

class SelectCategoryTreeWidget extends StatefulWidget {
  final SelectionType selectionType;
  final List<String> preselectedValues;
  const SelectCategoryTreeWidget({
    super.key,
    this.selectionType = SelectionType.SINGLE,
    required this.preselectedValues,
  });

  @override
  State<SelectCategoryTreeWidget> createState() => SelectCategoryTreeWidgetState();
}

class SelectCategoryTreeWidgetState extends BasicState<SelectCategoryTreeWidget> with WidgetUtilsMixin {
  final client = GetIt.instance.get<GQClient>();
  TreeViewController? treeCtrl;
  final categoriesTreeStream = BehaviorSubject.seeded(<CategoryTreeItem>[]);
  final selectedCategoryIds = BehaviorSubject.seeded(<String>{});
  late TreeNode<Category> root = TreeNode<Category>(
    key: "/",
    data: Category(
      id: "",
      name: lang.categories,
      childCategoryCount: 0,
      creationDate: 0,
      lastUpdate: 0,
      parent: null,
      score: 0.0,
    ),
  );
  @override
  void initState() {
    getCategoryTree();
    categoriesTreeStream.listen((value) {
      updateSampleTree(value);
    });
    selectedCategoryIds.value.addAll(widget.preselectedValues);
    selectedCategoryIds.add(selectedCategoryIds.value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TreeView.simpleTyped<Category, TreeNode<Category>>(
        tree: root,
        showRootNode: true,
        expansionIndicatorBuilder: (context, node) => ChevronIndicator.rightDown(
              tree: node,
              padding: const EdgeInsets.all(10),
            ),
        indentation: const Indentation(style: IndentStyle.none),
        onTreeReady: (controller) {
          treeCtrl = controller;
          controller.expandAllChildren(root, recursive: false);
        },
        builder: (context, node) => diplayNode(context, node));
  }

  Widget diplayNode(BuildContext context, TreeNode<Category> node) {
    if (node.key == "/") {
      return ListTile(
        title: Text(lang.all),
      );
    }
    var data = node.data;
    if (data == null) {
      return SizedBox.shrink();
    }
    return ListTile(
      leading: StreamBuilder<Set<String>>(
          stream: selectedCategoryIds,
          initialData: selectedCategoryIds.value,
          builder: (context, snapshot) {
            var set = snapshot.data;
            if (set == null) {
              return SizedBox.shrink();
            }
            return Checkbox(
              onChanged: (checked) {
                if (checked != null) {
                  if (checked) {
                    select(node);
                  } else {
                    unselect(node);
                  }
                }
              },
              value: set.contains(node.data?.id),
            );
          }),
      title: Text(data.name),
      onTap: node.children.length == 0
          ? null
          : () {
              if (node.isExpanded) {
                treeCtrl?.collapseNode(node);
              } else {
                treeCtrl?.expandNode(node);
              }
            },
    );
  }

  void select(TreeNode<Category> node) {
    selectedCategoryIds.value.add(node.key);
    node.childrenAsList.forEach((element) {
      selectedCategoryIds.value.add(element.key);
    });
    var parent = node.parent;
    if (parent != null) {
      //check if every child of this parent is selected
      bool allSelected = true;
      parent.children.forEach((key, value) {
        if (!isSelected(value.key)) {
          allSelected = false;
        }
      });
      if (allSelected) {
        selectedCategoryIds.value.add(parent.key);
      }
    }
    selectedCategoryIds.add(selectedCategoryIds.value);
  }

  bool isSelected(String categoryId) {
    return selectedCategoryIds.value.contains(categoryId);
  }

  void unselect(TreeNode<Category> node) {
    selectedCategoryIds.value.remove(node.key);
    if (node.parent != null) {
      selectedCategoryIds.value.remove(node.parent!.key);
    }
    selectedCategoryIds.add(selectedCategoryIds.value);
  }

  Future getCategoryTree() async {
    var res = await client.queries.getCategoryTree().asStream().map((event) => event.getCategoryTree).first;
    categoriesTreeStream.add(res);
  }

  void updateSampleTree(List<CategoryTreeItem> items) {
    root
      ..addAll(items
          .map((item) => TreeNode(key: item.root.id, data: item.root)
            ..addAll(item.childCatgories
                .map((child) => TreeNode(data: child, key: child.id, parent: Node(key: item.root.id)))
                .toList()))
          .toList());
  }

  List<Category> getSelectedItems() {
    var ids = selectedCategoryIds.value;
    var allCategories = getAllCategories(root);
    return allCategories.where((element) => ids.contains(element.id)).toList();
  }

  List<Category> getAllCategories(TreeNode<Category> node) {
    var result = <Category>[];
    if (node.data != null && node.data!.id != "") {
      result.add(node.data!);
    }
    node.children.forEach((key, node) {
      if (node is TreeNode<Category>) {
        result.addAll(getAllCategories(node));
      }
    });
    return result;
  }
}
