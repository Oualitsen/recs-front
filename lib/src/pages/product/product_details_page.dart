import 'package:get_it/get_it.dart';
import 'package:recs_ymal/generated/client.gq.dart';
import 'package:flutter/material.dart';
import 'package:recs_ymal/generated/inputs.gq.dart';
import 'package:recs_ymal/generated/types.gq.dart';
import 'package:recs_ymal/src/pages/product/reorderable_queue_item_widget.dart';
import 'package:recs_ymal/src/widgets/basic_state.dart';
import 'package:recs_ymal/src/widgets/editing_buttons.dart';
import 'package:recs_ymal/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends BasicState<ProductDetailsPage> with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  final productDetailStream = BehaviorSubject<ProductDetails>();
  @override
  void initState() {
    getProduct();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: StreamBuilder<ProductDetails>(
        stream: productDetailStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          ProductDetails data = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: SelectableText(
                data.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              actions: [TextButton(onPressed: saveSimilarities, child: Text("Save"))],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: SelectableText("${lang.id.toUpperCase()} : ${data.id}"),
                ),
                TabBar(
                  isScrollable: true,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2.0,
                      ),
                    ),
                    color: Color.fromARGB(20, 255, 250, 255),
                  ),
                  tabs: [
                    Tab(text: lang.similarities),
                    Tab(text: lang.complementaries),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: EditingButtons(onSave: saveSimilarities),
                          ),
                          Expanded(
                            child: ReorderableQueueList(
                              queueItems: data.similarities,
                              onReorder: (int oldIndex, int newIndex) {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                var old = data.similarities[oldIndex];
                                data.similarities.removeAt(oldIndex);
                                data.similarities.insert(newIndex, old);
                                productDetailStream.add(data);
                              },
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: EditingButtons(onSave: saveComplementaries),
                          ),
                          Expanded(
                            child: ReorderableQueueList(
                              queueItems: data.complementaries,
                              onReorder: (int oldIndex, int newIndex) {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                var old = data.complementaries[oldIndex];
                                data.complementaries.removeAt(oldIndex);
                                data.complementaries.insert(newIndex, old);
                                productDetailStream.add(data);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void saveSimilarities() async {
    int index = 0;
    var queueItems = productDetailStream.value.similarities
        .map((sim) => QueueItem(productId: sim.product.id, index: index++))
        .toList();

    try {
      var res = await service.mutations
          .updateProductSimilarities(productId: widget.productId, similarities: queueItems)
          .asStream()
          .map((event) => event.updateProductSimilarities)
          .first;
      res.similarities.sort((a, b) => a.index.compareTo(b.index));
      // res.complementaries.sort((a, b) => a.index.compareTo(b.index));
      productDetailStream.add(res);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError2(context, error: error);
    }
  }

  void saveComplementaries() async {
    int index = 0;
    var queueItems = productDetailStream.value.complementaries
        .map((sim) => QueueItem(productId: sim.product.id, index: index++))
        .toList();

    try {
      var res = await service.mutations
          .updateProductComplementaries(productId: widget.productId, complementaries: queueItems)
          .asStream()
          .map((event) => event.updateProductComplementaries)
          .first;
      res.complementaries.sort((a, b) => a.index.compareTo(b.index));
      productDetailStream.add(res);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError2(context, error: error);
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  Future getProduct() async {
    try {
      var productDetails = await service.queries
          .getProductDetails(productId: widget.productId)
          .asStream()
          .map((event) => event.getProductById)
          .first;
      productDetails.similarities.sort((a, b) => a.index.compareTo(b.index));
      productDetails.complementaries.sort((a, b) => a.index.compareTo(b.index));
      productDetailStream.add(productDetails);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError2(context, error: error);
    }
  }
}
