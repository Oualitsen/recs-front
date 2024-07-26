import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:flutter/material.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/pages/product/indexed_product_list.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
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
  final complementariesQueueKey = GlobalKey<IndexedProductsState>();
  final similaritiesQueueListKey = GlobalKey<IndexedProductsState>();
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
                      IndexedProducts(
                        key: similaritiesQueueListKey,
                        product: ProductName.fromJson(data.toJson()),
                        onSave: saveSimilarities,
                        indexedProducts: [...data.similarities],
                        onRefresh: () async {
                          var productDetails = await getProduct();
                          similaritiesQueueListKey.currentState
                              ?.updateItems(productDetails?.similarities ?? []);
                        },
                      ),
                      IndexedProducts(
                        key: complementariesQueueKey,
                        product: ProductName.fromJson(data.toJson()),
                        onSave: saveComplementaries,
                        indexedProducts: [...data.complementaries],
                        onRefresh: () async {
                          var productDetails = await getProduct();
                          complementariesQueueKey.currentState
                              ?.updateItems(productDetails?.complementaries ?? []);
                        },
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
    var res = similaritiesQueueListKey.currentState?.getItems();
    if (res != null) {
      var queueItems = res.map((sim) => QueueItem(productId: sim.product.id, rank: index++)).toList();
      try {
        var res = await service.mutations
            .updateProductSimilarities(productId: widget.productId, similarities: queueItems)
            .asStream()
            .map((event) => event.updateProductSimilarities)
            .first;
        res.similarities.sort((a, b) => a.index.compareTo(b.index));
        similaritiesQueueListKey.currentState?.updateItems(res.similarities);
        productDetailStream.add(res);
      } catch (error, stacktrace) {
        print(stacktrace);
        showServerError2(context, error: error);
      }
    }
  }

  void saveComplementaries() async {
    int index = 0;
    var res = complementariesQueueKey.currentState?.getItems();
    if (res != null) {
      var queueItems = res.map((sim) => QueueItem(productId: sim.product.id, rank: index++)).toList();
      try {
        var res = await service.mutations
            .updateProductComplementaries(productId: widget.productId, complementaries: queueItems)
            .asStream()
            .map((event) => event.updateProductComplementaries)
            .first;
        res.complementaries.sort((a, b) => a.index.compareTo(b.index));
        complementariesQueueKey.currentState?.updateItems(res.complementaries);
        productDetailStream.add(res);
      } catch (error, stacktrace) {
        print(stacktrace);
        showServerError2(context, error: error);
      }
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  Future<ProductDetails?> getProduct() async {
    try {
      var productDetails = await service.queries
          .getProductDetails(productId: widget.productId)
          .asStream()
          .map((event) => event.getProductById)
          .first;
      productDetails.similarities.sort((a, b) => a.index.compareTo(b.index));
      productDetails.complementaries.sort((a, b) => a.index.compareTo(b.index));
      productDetailStream.add(productDetails);
      return productDetails;
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError2(context, error: error);
      return null;
    }
  }
}
