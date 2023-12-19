import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_ymal/generated/client.gq.dart';
import 'package:recs_ymal/generated/types.gq.dart';
import 'package:recs_ymal/src/pages/product/reorderable_list_widget.dart';
import 'package:recs_ymal/src/pages/product/select_products.dart';
import 'package:recs_ymal/src/widgets/basic_state.dart';
import 'package:recs_ymal/src/widgets/editing_buttons.dart';
import 'package:recs_ymal/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class IndexedProducts extends StatefulWidget {
  final ProductName product;
  final VoidCallback onSave;
  final VoidCallback onRefresh;
  final List<IndexedProduct> indexedProducts;
  const IndexedProducts({
    super.key,
    required this.product,
    required this.onSave,
    required this.indexedProducts,
    required this.onRefresh,
  });

  @override
  State<IndexedProducts> createState() => IndexedProductsState();
}

class IndexedProductsState extends BasicState<IndexedProducts>
    with WidgetUtilsMixin, AutomaticKeepAliveClientMixin {
  final service = GetIt.instance.get<GQClient>();
  final undoRedoKey = GlobalKey<EditingButtonsState>();
  final indexedProductStream = BehaviorSubject.seeded(<IndexedProduct>[]);
  final selectProductsKey = GlobalKey<SelectProductsState>();
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
                  onAdd: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(lang.selectProducts),
                        content: SizedBox(
                          height: 450,
                          width: 900,
                          child: SelectProducts(
                            key: selectProductsKey,
                            originalProduct: widget.product,
                          ),
                        ),
                        actions: [getButtons(onSave: onYamlSave, elevatedCancelButton: true)],
                      ),
                    );
                  },
                  onUpdate: (p0) {
                    data.clear();
                    data.addAll(p0);
                    indexedProductStream.add(data);
                  },
                ),
              ),
              Gap(20),
              SizedBox(
                height: 300,
                child: ReorderableListWidget(
                  originalProduct: widget.product,
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

  void onYamlSave() {
    var selected = selectProductsKey.currentState?.getYmalProducts();
    if (selected != null) {
      var data = indexedProductStream.value;
      List<String> productIds = selected.map((e) => e.id).toList();
      List<Product> toAdd =
          data.map((e) => e.product).where((element) => !productIds.contains(element.id)).toList();
      List<Product> update = [...selected, ...toAdd];
      int index = 0;
      var indexedItems = update.map((product) => IndexedProduct(product: product, index: index++)).toList();
      data.clear();
      data.addAll(indexedItems);
      indexedProductStream.add(data);
      undoRedoKey.currentState?.updateStack([...data]);

      Navigator.of(context).pop();
    }
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
