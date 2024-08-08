import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/pages/full_page_progress.dart';
import 'package:recs_front/src/pages/sku/sku_list_widget.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:rxdart/rxdart.dart';

class SkuListPage extends StatefulWidget {
  final String productId;
  const SkuListPage({super.key, required this.productId});

  @override
  State<SkuListPage> createState() => _SkuListPageState();
}

class _SkuListPageState extends BasicState<SkuListPage> {
  final client = GetIt.instance.get<GQClient>();

  final productSubject = BehaviorSubject<ProductWithSKU>();

  @override
  void initState() {
    client.queries
        .getProductById(productId: widget.productId)
        .then((value) => productSubject.add(value.getProductById));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProductWithSKU>(
        stream: productSubject,
        initialData: productSubject.valueOrNull,
        builder: (context, snapshot) {
          var product = snapshot.data;
          if (product == null) {
            return FullPageProgress();
          }
          return Scaffold(
            appBar: AppBar(
              title: Text("${product.name} ${product.skuList.length}"),
            ),
            body: SkuListWidget(skus: product.skuList),
          );
        });
  }
}
