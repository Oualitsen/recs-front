import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart'
    as table;
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/page_wrapper.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class CategoryTreeTable extends StatefulWidget {
  final String? parentId;
  const CategoryTreeTable({super.key, this.parentId});

  @override
  State<CategoryTreeTable> createState() => _CategoryTreeTableState();
}

class _CategoryTreeTableState extends BasicState<CategoryTreeTable>
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
            DataCell(
              widget.parentId == null
                  ? TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PageWrapper(
                              title:
                                  "${lang.childCategories} - ${lang.id} : ${data.id}",
                              child: CategoryTreeTable(
                                parentId: data.id,
                              )),
                        ));
                      },
                      child: Text(data.childCategoryCount.toString()))
                  : Text(lang.na),
            ),
          ]);
        },
      ),
    );
  }

  Future<List<Category>> getData(table.PageInfo pageInfo) {
    try {
      if (widget.parentId == null) {
        return service.queries
            .getRootCategories(
                pageInfo:
                    PageInfo(page: pageInfo.pageIndex, size: pageInfo.pageSize))
            .asStream()
            .map((event) {
          totalCount.add(event.total);
          return event.getRootCategories;
        }).first;
      } else {
        return service.queries
            .findCategoriesByParentId(
                parentId: widget.parentId!,
                pageInfo:
                    PageInfo(page: pageInfo.pageIndex, size: pageInfo.pageSize))
            .asStream()
            .map((event) {
          totalCount.add(event.total);
          return event.findCategoriesByParentId;
        }).first;
      }
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
        DataColumn(label: Text(lang.childCategories)),
      ];
  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
