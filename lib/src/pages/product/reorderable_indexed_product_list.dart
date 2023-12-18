import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_ymal/generated/client.gq.dart';
import 'package:recs_ymal/generated/types.gq.dart';
import 'package:recs_ymal/src/pages/product/reorderable_list_widget.dart';
import 'package:recs_ymal/src/widgets/basic_state.dart';
import 'package:recs_ymal/src/widgets/editing_buttons.dart';
import 'package:recs_ymal/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class ReorderableIndexedProducts extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onRefresh;
  final List<IndexedProduct> indexedProducts;
  const ReorderableIndexedProducts({
    super.key,
    required this.onSave,
    required this.indexedProducts,
    required this.onRefresh,
  });

  @override
  State<ReorderableIndexedProducts> createState() => ReorderableIndexedProductsState();
}

class ReorderableIndexedProductsState extends BasicState<ReorderableIndexedProducts>
    with WidgetUtilsMixin, AutomaticKeepAliveClientMixin {
  final service = GetIt.instance.get<GQClient>();
  final undoRedoKey = GlobalKey<EditingButtonsState>();
  final indexedProductStream = BehaviorSubject.seeded(<IndexedProduct>[]);
  @override
  void initState() {
    indexedProductStream.add(widget.indexedProducts);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<List<IndexedProduct>>(
        stream: indexedProductStream,
        initialData: indexedProductStream.value,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          var data = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: EditingButtons<List<IndexedProduct>>(
                  key: undoRedoKey,
                  initValue: [...data],
                  onSave: widget.onSave,
                  onRefresh: widget.onRefresh,
                  onUpdate: (p0) {
                    data.clear();
                    data.addAll(p0);
                    indexedProductStream.add(data);
                  },
                ),
              ),
              Expanded(
                child: ReorderableListWidget(
                  queueItems: data,
                  onReorder: (int oldIndex, int newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    var old = data[oldIndex];
                    data.removeAt(oldIndex);
                    data.insert(newIndex, old);
                    undoRedoKey.currentState?.updateStack([...data]);
                    indexedProductStream.add(data);
                  },
                ),
              ),
            ],
          );
        });
  }

  List<IndexedProduct> getItems() {
    return [...indexedProductStream.value];
  }

  updateItems(List<IndexedProduct> items) {
    var data = indexedProductStream.value;
    data.clear();
    data.addAll(items);
    indexedProductStream.add(data);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
