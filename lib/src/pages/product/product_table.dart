import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart' as table;
import 'package:recs_ymal/generated/client.gq.dart';
import 'package:recs_ymal/generated/inputs.gq.dart';
import 'package:recs_ymal/generated/types.gq.dart';
import 'package:recs_ymal/src/widgets/basic_state.dart';
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
  @override
  Widget build(BuildContext context) {
    return table.LazyPaginatedDataTable<Product>(
      getData: getData,
      getTotal: getTotal,
      columns: columns,
      dataToRow: (data, indexInCurrentPage) {
        return DataRow(cells: [
          DataCell(Text(data.id)),
          DataCell(Text(data.name)),
          DataCell(Text(data.brand)),
          DataCell(Text(data.price.toString())),
          DataCell(Text(data.oldPrice.toString())),
          DataCell(Text(data.category.name)),
        ]);
      },
    );
  }

  Future<List<Product>> getData(table.PageInfo pageInfo) {
    try {
      return service.queries
          .getProducts(pageInfo: PageInfo(page: pageInfo.pageIndex, size: pageInfo.pageSize))
          .asStream()
          .map((event) {
        totalCount.add(event.total);
        return event.getProducts;
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

  List<DataColumn> get columns => [
        DataColumn(label: Text(lang.id)),
        DataColumn(label: Text(lang.name)),
        DataColumn(label: Text(lang.brand)),
        DataColumn(label: Text(lang.price)),
        DataColumn(label: Text(lang.oldPrice)),
        DataColumn(label: Text(lang.category)),
      ];
  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
