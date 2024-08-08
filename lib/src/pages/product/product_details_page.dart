import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:flutter/material.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/pages/product/indexed_product_list.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class ProductDetailsPage extends StatefulWidget {
  final String skuId;
  const ProductDetailsPage({super.key, required this.skuId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends BasicState<ProductDetailsPage> with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  final skuDetailStream = BehaviorSubject<Sku>();
  final complementariesQueueKey = GlobalKey<IndexedProductsWidgetState>();
  final similaritiesQueueListKey = GlobalKey<IndexedProductsWidgetState>();
  @override
  void initState() {
    getProduct();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: StreamBuilder<Sku>(
        stream: skuDetailStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          Sku data = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: SelectableText(
                data.product.name,
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
                      IndexedProductsWidget(
                        key: similaritiesQueueListKey,
                        sku: data,
                        onSave: saveSimilarities,
                        indexedSkuList: [],
                        onRefresh: () async {
                          var productDetails = await getProduct();
                          similaritiesQueueListKey.currentState?.updateItems([]);
                        },
                      ),
                      IndexedProductsWidget(
                        key: complementariesQueueKey,
                        sku: data,
                        onSave: saveComplementaries,
                        indexedSkuList: [],
                        onRefresh: () async {
                          var productDetails = await getProduct();
                          complementariesQueueKey.currentState?.updateItems([]);
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
    // @TODO
  }

  void saveComplementaries() async {
    // @TODO
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  Future<Sku?> getProduct() async {
    // @TODO
  }
}
