import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/utils/image_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';

class SkuListWidget extends StatefulWidget {
  final List<Sku> skus;
  const SkuListWidget({super.key, required this.skus});

  @override
  State<SkuListWidget> createState() => _SkuListWidgetState();
}

class _SkuListWidgetState extends BasicState<SkuListWidget> {
  @override
  Widget build(BuildContext context) {
    return LazyPaginatedDataTable<Sku>(
        getData: (info) => getData(info),
        getTotal: getTotal,
        columns: [
          DataColumn(label: Text(lang.productImage)),
          DataColumn(label: Text(lang.id)),
          DataColumn(label: Text(lang.name)),
          DataColumn(label: Text(lang.color)),
          DataColumn(label: Text(lang.inventory)),
          DataColumn(label: Text(lang.seasons)),
        ],
        dataToRow: (sku, index) {
          return DataRow(cells: [
            DataCell(ImageUtils.fromNetworkRounded(sku.imageUrl)),
            DataCell(Text(sku.gtin)),
            DataCell(Text(sku.product.name)),
            DataCell(Text(sku.colorLabel)),
            DataCell(Text("${sku.totalInventory}")),
            DataCell(Text("${sku.inventories.expand((e) => e.seasons).toSet().join(", ")}")),
          ]);
        });
  }

  Future<int> getTotal() async {
    return widget.skus.length;
  }

  Future<List<Sku>> getData(PageInfo info) async {
    print("info.size = ${info.pageSize} info.index = ${info.pageIndex}");
    print(
        "list.size = ${widget.skus.length}, from = ${info.pageIndex * info.pageSize} to ${(info.pageIndex + 1) * info.pageSize}");
    return widget.skus.sublist(
        info.pageIndex * info.pageSize, min((info.pageIndex + 1) * info.pageSize, widget.skus.length));
  }
}
