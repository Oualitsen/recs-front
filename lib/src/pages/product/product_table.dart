import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart' as table;
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/app.dart';
import 'package:recs_front/src/pages/category/select_category_widget.dart';
import 'package:recs_front/src/router_config.dart';
import 'package:recs_front/src/utils/extensions.dart';
import 'package:recs_front/src/utils/image_utils.dart';
import 'package:recs_front/src/utils/ui_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/custom_text_input_widget.dart';
import 'package:recs_front/src/widgets/multi_select_widget.dart';
import 'package:recs_front/src/widgets/selection_type.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class ProductTableWidget extends StatefulWidget {
  final SelectionType selectionType;
  final void Function(ProductDetails product)? onSelect;
  final List<ProductDetails> preselected;

  const ProductTableWidget(
      {super.key, required this.selectionType, this.onSelect, this.preselected = const []})
      : assert(
          selectionType != SelectionType.SINGLE || onSelect != null,
          "When selection type is 'SINGLE' you must provide 'onSelect' method",
        );

  @override
  State<ProductTableWidget> createState() => ProductTableWidgetState();
}

class ProductTableWidgetState extends BasicState<ProductTableWidget> with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  final totalCount = BehaviorSubject.seeded(0);
  final selectedProductsStream = BehaviorSubject.seeded(<ProductDetails>[]);
  final tableKey = GlobalKey<table.LazyPaginatedDataTableState>();
  final multiSelectionKey = GlobalKey<MultiSelectWidgetState>();
  final selectedCategoryStream = BehaviorSubject<Category?>();
  final selectedIds = BehaviorSubject.seeded(<String>[]);
  final selectedProducts = BehaviorSubject.seeded(<ProductDetails>[]);
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
    selectedProducts.add(widget.preselected);
    selectedProducts.listen((value) {
      selectedIds.add(value.map((e) => e.id).toList());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _getHeader(),
        SingleChildScrollView(
          child: streamBuilder<List<String>>(
              stream: selectedIds,
              initialData: selectedIds.valueOrNull,
              onDataChanged: (selectedIds) {
                return Expanded(
                  child: table.LazyPaginatedDataTable<ProductDetails>(
                    showCheckboxColumn: true,
                    showFirstLastButtons: true,
                    key: tableKey,
                    getData: getData,
                    getTotal: getTotal,
                    columns: getColumns(),
                    dataToRow: (data, _) {
                      return DataRow(
                        selected: selectedIds.contains(data.id),
                        onSelectChanged: widget.selectionType == SelectionType.MULTIPLE
                            ? (selected) => onSelectChanged(selected, data)
                            : null,
                        cells: [
                          DataCell(InkWell(
                              onTap: () => showImage(data),
                              child: ImageUtils.fromNetworkRounded(data.firstImageUrl))),
                          DataCell(
                            TextButton(
                              onPressed: () => onTap(data),
                              child: Text(data.id),
                            ),
                          ),
                          DataCell(
                            TextButton(
                              onPressed: () => onTap(data),
                              child: Text(data.name),
                            ),
                          ),
                          DataCell(SelectableText(data.brand ?? lang.na)),
                          DataCell(SelectableText(data.price.toString())),
                          DataCell(SelectableText(data.oldPrice.toString())),
                          DataCell(SelectableText(data.category.name)),
                        ],
                      );
                    },
                  ),
                );
              }),
        ),
      ],
    );
  }

  Widget _getHeader() {
    if (widget.selectionType == SelectionType.MULTIPLE) {
      return StreamBuilder<int>(
          stream: selectedIds.map((event) => event.length),
          initialData: 0,
          builder: (context, snapshot) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${lang.selectedProducts}: ${snapshot.data}'),
                SizedBox(width: 16),
              ],
            );
          });
    }
    return SizedBox.shrink();
  }

  void onTap(ProductDetails data) {
    print("onTap called on id = ${data.id}");
    if (widget.selectionType == SelectionType.SINGLE) {
      widget.onSelect?.call(data);
    } else {
      router.navigateTo(navKey.currentContext!, "/skus/${data.id}");
    }
  }

  void onSelectChanged(bool? selected, ProductDetails product) {
    if (selected == null) {
      return;
    }
    var selectedValues = [...selectedProducts.value];
    if (selected) {
      selectedValues.add(product);
    } else {
      selectedValues.removeWhere((element) => element.id == product.id);
    }
    selectedProducts.add(selectedValues);
  }

  Future<List<ProductDetails>> getData(table.PageInfo pageInfo) {
    try {
      return service.queries
          .searchProducts(
            pageInfo: PageInfo(page: pageInfo.pageIndex, size: pageInfo.pageSize),
            params: searchStream.value,
          )
          .asStream()
          .map((event) => event.searchProducts)
          .first;
    } catch (error, stacktrace) {
      print(stacktrace);
      totalCount.add(0);
      return Future.value(<ProductDetails>[]);
    }
  }

  Future<int> getTotal() {
    return service.queries
        .countProducts(params: searchStream.value)
        .asStream()
        .map((event) => event.count)
        .first;
  }

  void reload() {
    tableKey.currentState?.refreshPage();
  }

  List<DataColumn> getColumns() {
    return [
      DataColumn(label: Text(lang.productImage)),
      DataColumn(
        label: CustomTextInputWidget(
          onChange: (value) {
            var params = searchStream.value;
            addToSearchParams(
              ProductParamSearch(
                brand: params.brand,
                name: params.name,
                categoryIds: params.categoryIds,
                productId: value,
              ),
            );
          },
          hint: lang.id,
        ),
      ),
      DataColumn(
        label: CustomTextInputWidget(
          onChange: (value) {
            var params = searchStream.value;

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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
          ),
          content: SizedBox(
            height: 400,
            width: 500,
            child: SelectCategoryWidget(
                selectedCategory: (category) {
                  if (category.isNotEmpty && selectedCategoryStream.valueOrNull != category.first) {
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

  List<ProductDetails> getSelectedItems() {
    return selectedProducts.value;
  }
}
