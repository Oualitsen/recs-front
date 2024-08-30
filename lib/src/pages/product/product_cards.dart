import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view_2/infinite_scroll_list_view.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class ProductCards extends StatefulWidget {
  final Sku sku;
  const ProductCards({
    super.key,
    required this.sku,
  });

  @override
  State<ProductCards> createState() => ProductCardsState();
}

class ProductCardsState extends BasicState<ProductCards> with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  final selectedStream = BehaviorSubject.seeded(<Sku>[]);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Sku>>(
      stream: selectedStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        var selectedProducts = snapshot.data!;
        return InfiniteScrollListView<Sku>(
          scrollDirection: Axis.horizontal,
          elementBuilder: (context, sku, index, animation) {
            return InkWell(
              onTap: () {
                var checked = selectedProducts.where((element) => element.id == sku.id).isEmpty;
                updateCheckBox(checked, sku);
              },
              child: SizedBox(
                height: 300,
                width: 200,
                child: Card(
                  shape: selectedProducts.where((element) => element.id == sku.id).isEmpty
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
                            SelectableText(sku.name),
                            Spacer(),
                            Checkbox(
                              onChanged: (value) {
                                if (value != null) {
                                  updateCheckBox(value, sku);
                                }
                              },
                              value: selectedProducts
                                  .where((element) => element.id == sku.id)
                                  .toList()
                                  .isNotEmpty,
                            ),
                          ],
                        ),
                        Image.network(
                          sku.imageUrl,
                          height: 250,
                          width: 175,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                            return Text("${lang.errors} : ${sku.imageUrl}");
                          },
                        ),
                        SelectableText("${lang.id} : ${sku.id}"),
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

  Future<List<Sku>> getData(index) async {
    return <Sku>[];
  }

  List<Sku> selectedProducts() {
    return [...selectedStream.value];
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
  void updateCheckBox(bool selected, Sku product) {
    var selectedProducts = selectedStream.value;
    selected
        ? selectedProducts.add(product)
        : selectedProducts.removeWhere((element) => element.id == product.id);
    selectedStream.add(selectedProducts);
  }
}
