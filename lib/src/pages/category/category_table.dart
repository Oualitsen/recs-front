import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart'
    as table;
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class CategoryTable extends StatefulWidget {
  const CategoryTable({super.key});

  @override
  State<CategoryTable> createState() => _CategoryTableState();
}

class _CategoryTableState extends BasicState<CategoryTable>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  final totalCount = BehaviorSubject.seeded(0);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: table.LazyPaginatedDataTable<Category>(
        getData: getData,
        getTotal: getTotal,
        columns: columns,
        dataToRow: (data, indexInCurrentPage) {
          return DataRow(cells: [
            DataCell(Text(data.id)),
            DataCell(Text(data.name)),
            DataCell(Text(lang.na.toUpperCase())),
          ]);
        },
      ),
    );
  }

  Future<List<Category>> getData(table.PageInfo pageInfo) {
    try {
      return service.queries
          .getCategories(
              pageInfo:
                  PageInfo(page: pageInfo.pageIndex, size: pageInfo.pageSize))
          .asStream()
          .map((event) {
        totalCount.add(event.total);
        return event.getCategories;
      }).first;
    } catch (error, stacktrace) {
      print(stacktrace);
      totalCount.add(0);
      return Future.value(<Category>[]);
    }
  }

  Future<int> getTotal() {
    return Future.value(totalCount.value);
  }

  List<DataColumn> get columns => [
        DataColumn(label: Text(lang.id)),
        DataColumn(label: Text(lang.name)),
        DataColumn(label: Text(lang.parentCategory)),
      ];
  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
