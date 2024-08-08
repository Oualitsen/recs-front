import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/pages/product/product_cards.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class SelectProducts extends StatefulWidget {
  final Sku originalProduct;
  const SelectProducts({super.key, required this.originalProduct});

  @override
  State<SelectProducts> createState() => SelectProductsState();
}

class SelectProductsState extends BasicState<SelectProducts> with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  final ymalProductsKey = GlobalKey<ProductCardsState>();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              Tab(text: "ymal"),
              Tab(text: "rule based"),
              Tab(text: "color similar"),
            ],
          ),
          Expanded(
            child: TabBarView(children: [
              ProductCards(
                sku: widget.originalProduct,
                key: ymalProductsKey,
              ),
              Text("rule based"),
              Text("color similar"),
            ]),
          )
        ],
      ),
    );
  }

  List<Sku> getYmalProducts() {
    return ymalProductsKey.currentState?.selectedProducts() ?? [];
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
