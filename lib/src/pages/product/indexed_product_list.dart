import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/pages/product/reorderable_list_widget.dart';
import 'package:recs_front/src/pages/product/select_products.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/editing_buttons.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class IndexedProductsWidget extends StatefulWidget {
  final Sku sku;
  final VoidCallback onSave;
  final VoidCallback onRefresh;
  final List<Sku> indexedSkuList;
  const IndexedProductsWidget({
    super.key,
    required this.sku,
    required this.onSave,
    required this.indexedSkuList,
    required this.onRefresh,
  });

  @override
  State<IndexedProductsWidget> createState() => IndexedProductsWidgetState();
}

class IndexedProductsWidgetState extends BasicState<IndexedProductsWidget>
    with WidgetUtilsMixin, AutomaticKeepAliveClientMixin {
  final service = GetIt.instance.get<GQClient>();
  final undoRedoKey = GlobalKey<EditingButtonsState>();
  final indexedProductStream = BehaviorSubject.seeded(<Sku>[]);
  final selectProductsKey = GlobalKey<SelectProductsState>();
  @override
  void initState() {
    indexedProductStream.add(widget.indexedSkuList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<List<Sku>>(
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
                child: EditingButtons<List<Sku>>(
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
                            originalProduct: widget.sku,
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
                  originalProduct: widget.sku,
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
    List<Sku>? selected = selectProductsKey.currentState?.getYmalProducts();
    if (selected != null) {
      List<Sku> data = indexedProductStream.value;
      Set<String> productIds = selected.map((e) => e.id).toSet();
      List<Sku> toAdd = data.where((sku) => !productIds.contains(sku.id)).toList();

      Navigator.of(context).pop();
    }
  }

  List<Sku> getItems() {
    return [...indexedProductStream.value];
  }

  updateItems(List<Sku> items) {
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
