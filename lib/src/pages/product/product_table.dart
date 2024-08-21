import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart'
    as table;
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/app.dart';
import 'package:recs_front/src/pages/category/select_category_widget.dart';
import 'package:recs_front/src/router_config.dart';
import 'package:recs_front/src/utils/extensions.dart';
import 'package:recs_front/src/utils/image_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/custom_text_input_widget.dart';
import 'package:recs_front/src/widgets/multi_select_widget.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class ProductTableWidget extends StatefulWidget {
  const ProductTableWidget({super.key});

  @override
  State<ProductTableWidget> createState() => _ProductTableWidgetState();
}

class _ProductTableWidgetState extends BasicState<ProductTableWidget>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  final totalCount = BehaviorSubject.seeded(0);
  final selectedProductsStream = BehaviorSubject.seeded(<ProductDetails>[]);
  final tableKey = GlobalKey<table.LazyPaginatedDataTableState>();
  final multiSelectionKey = GlobalKey<MultiSelectWidgetState>();
  final selectedCategoryStream = BehaviorSubject<Category?>();
  final searchStream = BehaviorSubject.seeded(ProductParamSearch(
    productId: null,
    name: null,
    brand: null,
    categoryIds: null,
  ));
  @override
  void initState() {
    selectedCategoryStream.listen((value) {
      var searchParams = searchStream.value;
      addToSearchParams(
        ProductParamSearch(
            productId: searchParams.productId,
            name: searchParams.name,
            brand: searchParams.brand,
            categoryIds: value != null ? [value.id] : null),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<ProductParamSearch>(
          stream: searchStream,
          initialData: searchStream.value,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            var data = snapshot.data!;
            return table.LazyPaginatedDataTable<ProductDetails>(
              key: tableKey,
              getData: getData,
              getTotal: getTotal,
              columns: getColumns(data),
              dataToRow: (data, indexInCurrentPage) {
                return DataRow(cells: [
                  DataCell(InkWell(
                      onTap: () => showImage(data),
                      child:
                          ImageUtils.fromNetworkRounded(data.firstImageUrl))),
                  DataCell(SelectableText(data.id)),
                  DataCell(
                    TextButton(
                      onPressed: () => router.navigateTo(
                          navKey.currentContext!, "/products/${data.id}"),
                      child: Text(data.name),
                    ),
                  ),
                  DataCell(SelectableText(data.brand ?? lang.na)),
                  DataCell(SelectableText(data.price.toString())),
                  DataCell(SelectableText(data.oldPrice.toString())),
                  DataCell(SelectableText(data.category.name)),
                  DataCell(
                    TextButton(
                      child: Text("${data.skuCount}"),
                      onPressed: () => router.navigateTo(
                          navKey.currentContext!, "/skus/${data.id}"),
                    ),
                  ),
                ]);
              },
            );
          }),
    );
  }

  Future<List<ProductDetails>> getData(table.PageInfo pageInfo) {
    var params = searchStream.value;
    try {
      return service.queries
          .searchProducts(
            pageInfo:
                PageInfo(page: pageInfo.pageIndex, size: pageInfo.pageSize),
            params: params,
          )
          .asStream()
          .map((event) {
        updateCount(event.count);

        return event.searchProducts;
      }).first;
    } catch (error, stacktrace) {
      print(stacktrace);
      totalCount.add(0);
      return Future.value(<ProductDetails>[]);
    }
  }

  void updateCount(int count) {
    if (count != totalCount.value) {
      totalCount.add(count);
    }
  }

  Future<int> getTotal() {
    return Future.value(totalCount.value);
  }

  void reload() {
    print("Reloading data table");
    tableKey.currentState?.refreshPage();
  }

  List<DataColumn> getColumns(ProductParamSearch params) {
    return [
      DataColumn(label: Text(lang.productImage)),
      DataColumn(label: Text(lang.id)),
      DataColumn(
        label: CustomTextInputWidget(
          onChange: (value) {
            addToSearchParams(
              ProductParamSearch(
                brand: params.brand,
                name: value,
                categoryIds: params.categoryIds,
                productId: params.productId,
              ),
            );
          },
          hint: lang.name,
        ),
      ),
      DataColumn(label: Text(lang.brand)),
      DataColumn(label: Text(lang.price)),
      DataColumn(label: Text(lang.oldPrice)),
      DataColumn(
        label: StreamBuilder<Category?>(
            stream: selectedCategoryStream,
            builder: (context, snapshot) {
              return getCategoryColumnWidget(snapshot.data);
            }),
      ),
      DataColumn(label: Text(lang.skuCount)),
    ];
  }

  addToSearchParams(ProductParamSearch value) {
    var current = searchStream.value;
    if (!current.isEqualTo(value)) {
      searchStream.add(value);
      reload();
    }
  }

  selectCategories() async {
    List<Category> initialElements = [];
    if (selectedCategoryStream.valueOrNull != null) {
      initialElements = [selectedCategoryStream.value!];
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            lang.categories,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.black87),
          ),
          content: SizedBox(
            height: 400,
            width: 500,
            child: SelectCategoryWidget(
                selectedCategory: (category) {
                  if (category.isNotEmpty &&
                      selectedCategoryStream.valueOrNull != category.first) {
                    selectedCategoryStream.add(category.first);
                  } else {
                    if (selectedCategoryStream.valueOrNull != null) {
                      selectedCategoryStream.add(null);
                    }
                  }
                  Navigator.of(context).pop();
                },
                initialElements: initialElements),
          ),
        );
      },
    );
  }

  Widget getCategoryColumnWidget(Category? data) {
    if (data == null) {
      return SizedBox(
        width: 150,
        child: InkWell(
          child: Row(
            children: [
              Text(lang.category),
              SizedBox(width: 3),
              Icon(Icons.search),
            ],
          ),
          onTap: selectCategories,
        ),
      );
    }
    return Container(
      width: 150,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.black38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Gap(5),
          SizedBox(
              width: 90,
              child: Text(
                data.name,
                overflow: TextOverflow.ellipsis,
              )),
          Gap(5),
          IconButton(
            onPressed: () => selectedCategoryStream.add(null),
            icon: Icon(
              FontAwesomeIcons.x,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future showImage(ProductDetails data) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SelectableText("${lang.id} : ${data.id}"),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(FontAwesomeIcons.x),
            )
          ],
        ),
        content: SizedBox(
          height: 400,
          width: 400,
          child: ImageUtils.fromNetwork(data.firstImageUrl),
        ),
      ),
    );
  }
}
