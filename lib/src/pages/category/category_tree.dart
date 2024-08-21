import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class CategoriesTree extends StatefulWidget {
  const CategoriesTree({super.key});

  @override
  State<CategoriesTree> createState() => _CategoriesTreeState();
}

class _CategoriesTreeState extends BasicState<CategoriesTree>
    with WidgetUtilsMixin {
  TreeViewController? treeCtrl;
  final categoriesTreeStream = BehaviorSubject.seeded(<CategoryTreeItem>[]);
  final client = GetIt.instance.get<GQClient>();
  late TreeNode<Category> sampleTree = TreeNode<Category>(
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lang.categoriesTree)),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: TreeView.simple(
          tree: sampleTree,
          showRootNode: true,
          expansionIndicatorBuilder: (context, node) =>
              ChevronIndicator.rightDown(
            tree: node,
            padding: const EdgeInsets.all(10),
          ),
          indentation: const Indentation(style: IndentStyle.squareJoint),
          onItemTap: (item) {
            print("Item tapped: ${item.key}");
          },
          onTreeReady: (controller) {
            treeCtrl = controller;
            controller.expandAllChildren(sampleTree, recursive: true);
          },
          builder: (context, node) => Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: node.key == "/"
                ? SizedBox(
                    width: 500,
                    child: Text(
                      "${node.key}${node.data?.name}",
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 500,
                        child: Text(
                          "${node.key} : ${node.data?.name}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ),
                      Gap(10),
                      if (node.level <= 1)
                        SizedBox(
                          width: 500,
                          child: Text(
                            "${lang.childCategories} : ${node.data?.childCategoryCount}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future getCategoryTree() async {
    var res = await client.queries
        .getCategoryTree()
        .asStream()
        .map((event) => event.getCategoryTree)
        .first;
    categoriesTreeStream.add(res);
  }

  void updateSampleTree(List<CategoryTreeItem> items) {
    sampleTree
      ..addAll(items
          .map((item) => TreeNode(key: item.root.id, data: item.root)
            ..addAll(item.childCatgories
                .map((child) => TreeNode(
                    data: child,
                    key: child.id,
                    parent: Node(key: item.root.id)))
                .toList()))
          .toList());
  }
}
