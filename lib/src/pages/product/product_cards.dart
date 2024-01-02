import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view_2/infinite_scroll_list_view.dart';
import 'package:recs_ymal/generated/client.gq.dart';
import 'package:recs_ymal/generated/inputs.gq.dart';
import 'package:recs_ymal/generated/types.gq.dart';
import 'package:recs_ymal/src/widgets/basic_state.dart';
import 'package:recs_ymal/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class ProductCards extends StatefulWidget {
  final ProductName originalProduct;
  const ProductCards({
    super.key,
    required this.originalProduct,
  });

  @override
  State<ProductCards> createState() => ProductCardsState();
}

class ProductCardsState extends BasicState<ProductCards> with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  final selectedStream = BehaviorSubject.seeded(<Product>[]);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: selectedStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        var selectedProducts = snapshot.data!;
        return InfiniteScrollListView<Product>(
          scrollDirection: Axis.horizontal,
          elementBuilder: (context, product, index, animation) {
            return InkWell(
              onTap: () {
                var checked = selectedProducts.where((element) => element.id == product.id).isEmpty;
                updateCheckBox(checked, product);
              },
              child: SizedBox(
                height: 300,
                width: 200,
                child: Card(
                  shape: selectedProducts.where((element) => element.id == product.id).isEmpty
                      ? null
                      : RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            width: 2,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                  color: Colors.blueGrey[50],
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SelectableText(product.name),
                            Spacer(),
                            Checkbox(
                              onChanged: (value) {
                                if (value != null) {
                                  updateCheckBox(value, product);
                                }
                              },
                              value: selectedProducts
                                  .where((element) => element.id == product.id)
                                  .toList()
                                  .isNotEmpty,
                            ),
                          ],
                        ),
                        product.imageUrl != null
                            ? Image.network(
                                product.imageUrl!,
                                height: 250,
                                width: 175,
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text("${lang.errors} : ${product.imageUrl}");
                                },
                              )
                            : Text("${lang.errors} : ${product.imageUrl}"),
                        SelectableText("${lang.id} : ${product.id}"),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          pageLoader: getData,
        );
      },
    );
  }

  Future<List<Product>> getData(index) {
    return service.queries
        .getProducts(pageInfo: PageInfo(page: index, size: 15))
        .asStream()
        .map((event) => event.getProducts)
        .map((event) => event.where((element) => element.id != widget.originalProduct.id).toList())
        .first;
  }

  List<Product> selectedProducts() {
    return [...selectedStream.value];
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
  void updateCheckBox(bool selected, Product product) {
    var selectedProducts = selectedStream.value;
    selected
        ? selectedProducts.add(product)
        : selectedProducts.removeWhere((element) => element.id == product.id);
    selectedStream.add(selectedProducts);
  }
}
