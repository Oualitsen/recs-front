import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart' as table;
import 'package:recs_ymal/generated/client.gq.dart';
import 'package:recs_ymal/generated/inputs.gq.dart';
import 'package:recs_ymal/generated/types.gq.dart';
import 'package:recs_ymal/src/app.dart';
import 'package:recs_ymal/src/pages/product/product_details_page.dart';
import 'package:recs_ymal/src/utils/extensions.dart';
import 'package:recs_ymal/src/widgets/basic_state.dart';
import 'package:recs_ymal/src/widgets/custom_text_input_widget.dart';
import 'package:recs_ymal/src/widgets/multi_select_widget.dart';
import 'package:recs_ymal/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class ProductTable extends StatefulWidget {
  const ProductTable({super.key});

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends BasicState<ProductTable> with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  final totalCount = BehaviorSubject.seeded(0);
  final selectedProductsStream = BehaviorSubject.seeded(<Product>[]);
  final tableKey = GlobalKey<table.LazyPaginatedDataTableState>();
  final multiSelectionKey = GlobalKey<MultiSelectWidgetState>();
  final selectedCategoriesStream = BehaviorSubject.seeded(<Category>{});
  final allCategoriesStream = BehaviorSubject.seeded(<Category>{});
  final searchStream = BehaviorSubject.seeded(ProductSearchParams(
    search: false,
    info: ProductParamSearch(
      productId: null,
      name: null,
      brand: null,
      categoryIds: null,
    ),
  ));
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProductSearchParams>(
        stream: searchStream,
        initialData: searchStream.value,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          var data = snapshot.data!;
          return table.LazyPaginatedDataTable<Product>(
            key: tableKey,
            getData: getData,
            getTotal: getTotal,
            columns: getColumns(data),
            dataToRow: (data, indexInCurrentPage) {
              return DataRow(cells: [
                DataCell(CircleAvatar(child: Text(data.name[0]))),
                DataCell(SelectableText(data.id)),
                DataCell(
                  TextButton(
                    onPressed: () => router.navigateTo(navKey.currentContext!, "/products/${data.id}"),
                    child: Text(data.name),
                  ),
                ),
                DataCell(SelectableText(data.brand)),
                DataCell(SelectableText(data.price.toString())),
                DataCell(SelectableText(data.oldPrice.toString())),
                DataCell(SelectableText(data.category.name)),
              ]);
            },
          );
        });
  }

  Future<List<Product>> getData(table.PageInfo pageInfo) {
    var params = searchStream.value;
    try {
      return service.queries
          .searchProducts(
            pageInfo: PageInfo(page: pageInfo.pageIndex, size: pageInfo.pageSize),
            params: params.info,
          )
          .asStream()
          .map((event) {
        totalCount.add(event.count);
        if (!params.search) {
          var categories = event.searchProducts.map((e) => e.category).toList();
          allCategoriesStream.add(categories.toSet());
        }
        return event.searchProducts;
      }).first;
    } catch (error, stacktrace) {
      print(stacktrace);
      totalCount.add(0);
      return Future.value(<Product>[]);
    }
  }

  Future<int> getTotal() {
    return Future.value(totalCount.value);
  }

  void reload() {
    tableKey.currentState?.refreshPage();
  }

  List<DataColumn> getColumns(ProductSearchParams params) {
    return params.search
        ? [
            DataColumn(
              label: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  var paramsCopy = new ProductSearchParams(search: params.search, info: params.info);
                  var val = params;
                  val.search = false;
                  val.info = ProductParamSearch(
                    name: null,
                    brand: null,
                    categoryIds: null,
                    productId: null,
                  );
                  selectedCategoriesStream.value.clear();
                  if (!paramsCopy.info.isNull()) {
                    reload();
                  }
                  searchStream.add(val);
                },
              ),
            ),
            DataColumn(
              label: CustomTextInputWidget(
                width: 200,
                onChange: (value) {
                  addToSearchParams(ProductSearchParams(
                    search: params.search,
                    info: ProductParamSearch(
                      productId: value,
                      brand: params.info.brand,
                      categoryIds: params.info.categoryIds,
                      name: params.info.name,
                    ),
                  ));
                },
                hint: lang.id,
              ),
            ),
            DataColumn(
              label: CustomTextInputWidget(
                onChange: (value) {
                  addToSearchParams(ProductSearchParams(
                    search: params.search,
                    info: ProductParamSearch(
                      name: value,
                      brand: params.info.brand,
                      categoryIds: params.info.categoryIds,
                      productId: params.info.productId,
                    ),
                  ));
                },
                hint: lang.name,
              ),
            ),
            DataColumn(
              label: CustomTextInputWidget(
                onChange: (value) {
                  addToSearchParams(ProductSearchParams(
                    search: params.search,
                    info: ProductParamSearch(
                      brand: value,
                      name: params.info.name,
                      categoryIds: params.info.categoryIds,
                      productId: params.info.productId,
                    ),
                  ));
                },
                hint: lang.brand,
              ),
            ),
            DataColumn(label: Text(lang.price)),
            DataColumn(label: Text(lang.oldPrice)),
            DataColumn(
                label: ElevatedButton(
              child: Text(lang.category),
              onPressed: selectCategories,
            )),
          ]
        : [
            DataColumn(
                label: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                var val = params;
                val.search = true;
                searchStream.add(val);
              },
            )),
            DataColumn(label: Text(lang.id)),
            DataColumn(label: Text(lang.name)),
            DataColumn(label: Text(lang.brand)),
            DataColumn(label: Text(lang.price)),
            DataColumn(label: Text(lang.oldPrice)),
            DataColumn(label: Text(lang.category)),
          ];
  }

  addToSearchParams(ProductSearchParams value) {
    var current = searchStream.value;
    if (!current.info.isEqualTo(value.info)) {
      searchStream.add(value);
      reload();
    }
  }

  selectCategories() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            lang.categories,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
          ),
          content: SizedBox(
            height: 400,
            width: 500,
            child: MultiSelectWidget<Category>(
              key: multiSelectionKey,
              initialData: selectedCategoriesStream.value.toList(),
              comparator: (a, b) => a.id == b.id,
              mapper: (category) => (category.name),
              onSelectionChanged: (selected) {
                selectedCategoriesStream.value.clear();
                selectedCategoriesStream.add(selected.toSet());
                var params = searchStream.value;

                addToSearchParams(ProductSearchParams(
                  search: params.search,
                  info: ProductParamSearch(
                    name: params.info.name,
                    brand: params.info.brand,
                    categoryIds: selected.map((e) => e.id).toList(),
                    productId: params.info.productId,
                  ),
                ));
                Navigator.of(context).pop();
              },
              items: allCategoriesStream.value.toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}

class ProductSearchParams {
  bool search;
  ProductParamSearch info;
  ProductSearchParams({
    required this.search,
    required this.info,
  });
}
