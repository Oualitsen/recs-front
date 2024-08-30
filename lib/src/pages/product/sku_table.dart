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

class SkuTableWidget extends StatefulWidget {
  final SelectionType selectionType;
  final void Function(Sku product)? onSelect;
  final List<Sku> preselected;
  final String? productId;

  const SkuTableWidget(
      {super.key, required this.selectionType, this.onSelect, this.preselected = const [], this.productId})
      : assert(
          selectionType != SelectionType.SINGLE || onSelect != null,
          "When selection type is 'SINGLE' you must provide 'onSelect' method",
        );

  @override
  State<SkuTableWidget> createState() => SkuTableWidgetState();
}

class SkuTableWidgetState extends BasicState<SkuTableWidget> with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  final totalCount = BehaviorSubject.seeded(0);
  final selectedSkusStream = BehaviorSubject.seeded(<Sku>[]);
  final tableKey = GlobalKey<table.LazyPaginatedDataTableState>();
  final multiSelectionKey = GlobalKey<MultiSelectWidgetState>();
  final selectedCategoryStream = BehaviorSubject<Category?>();
  final selectedIds = BehaviorSubject.seeded(<String>[]);
  final selectedskus = BehaviorSubject.seeded(<Sku>[]);
  final searchStream = BehaviorSubject<SkuParamSearch>();
  @override
  void initState() {
    searchStream.add(SkuParamSearch(
      skuId: null,
      productId: widget.productId,
      name: null,
      brand: null,
      categoryIds: null,
    ));
    selectedCategoryStream.listen((value) {
      var searchParams = searchStream.value;
      addToSearchParams(
        SkuParamSearch(
            skuId: searchParams.skuId,
            productId: searchParams.productId,
            name: searchParams.name,
            brand: searchParams.brand,
            categoryIds: value != null ? [value.id] : null),
      );
    });
    selectedskus.add(widget.preselected);
    selectedskus.listen((value) {
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
                  child: table.LazyPaginatedDataTable<Sku>(
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
                              child: ImageUtils.fromNetworkRounded(data.imageUrl))),
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
                          DataCell(Text(data.colorLabel)),
                          DataCell(SelectableText(data.brand ?? lang.na)),
                          DataCell(SelectableText(data.price.toString())),
                          DataCell(SelectableText(data.oldPrice.toString())),
                          DataCell(SelectableText(data.category.name)),
                          DataCell(Text("${data.totalInventory}")),
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

  void onTap(Sku data) {
    if (widget.selectionType == SelectionType.SINGLE) {
      widget.onSelect?.call(data);
    } else {
      router.navigateTo(navKey.currentContext!, "/skus/${data.id}");
    }
  }

  void onSelectChanged(bool? selected, Sku sku) {
    if (selected == null) {
      return;
    }
    var selectedValues = [...selectedskus.value];
    if (selected) {
      selectedValues.add(sku);
    } else {
      selectedValues.removeWhere((element) => element.id == sku.id);
    }
    selectedskus.add(selectedValues);
  }

  Future<List<Sku>> getData(table.PageInfo pageInfo) {
    try {
      return service.queries
          .findSkus(
            pageInfo: PageInfo(page: pageInfo.pageIndex, size: pageInfo.pageSize),
            params: searchStream.value,
          )
          .asStream()
          .map((event) {
        updateCount(event.countSkus);

        return event.findSkus;
      }).first;
    } catch (error, stacktrace) {
      print(stacktrace);
      totalCount.add(0);
      return Future.value(<Sku>[]);
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
              SkuParamSearch(
                brand: params.brand,
                name: params.name,
                categoryIds: params.categoryIds,
                productId: params.productId,
                skuId: value,
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
              SkuParamSearch(
                skuId: params.skuId,
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
      DataColumn(label: Text(lang.color)),
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
      DataColumn(label: Text(lang.inventory)),
    ];
  }

  addToSearchParams(SkuParamSearch value) {
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

  Future showImage(Sku data) async {
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
          child: ImageUtils.fromNetwork(data.imageUrl),
        ),
      ),
    );
  }

  List<Sku> getSelectedItems() {
    return selectedskus.value;
  }
}
