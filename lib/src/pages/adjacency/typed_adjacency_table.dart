import 'package:flutter/material.dart';
import 'package:recs_front/generated/enums.gq.dart';
import 'package:recs_front/src/pages/adjacency/adjacency_input_form.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart'
    as table;

class TypedAdjacencyTable extends StatefulWidget {
  final AdjacencyType type;
  const TypedAdjacencyTable({
    super.key,
    required this.type,
  });

  @override
  State<TypedAdjacencyTable> createState() => _TypedAdjacencyTableState();
}

class _TypedAdjacencyTableState extends BasicState<TypedAdjacencyTable>
    with WidgetUtilsMixin {
  final client = GetIt.instance.get<GQClient>();
  final tableKey = GlobalKey<table.LazyPaginatedDataTableState>();
  final totalStream = BehaviorSubject.seeded(0);
  final inputFormKey = GlobalKey<AdjacencyInputFormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                  onPressed: addAdjacency,
                  child: Text(
                      "${lang.add} ${lang.adjecencyTypeName(widget.type)}"),
                ),
              ],
            ),
          ),
          table.LazyPaginatedDataTable<Adjacency>(
            key: tableKey,
            getData: getData,
            getTotal: getTotal,
            columns: getColumns(),
            dataToRow: dataToRow,
          ),
        ],
      ),
    );
  }

  Future<List<Adjacency>> getData(table.PageInfo info) {
    return client.queries
        .getAdjacencies(
          pageInfo: PageInfo(
            page: info.pageIndex,
            size: info.pageSize,
          ),
          type: widget.type,
        )
        .asStream()
        .map((event) {
      totalStream.add(event.total);
      return event.getAdjacencies;
    }).first;
  }

  Future<int> getTotal() async {
    return Future.value(totalStream.value);
  }

  List<DataColumn> getColumns() {
    return [
      DataColumn(label: Text(lang.entry1)),
      DataColumn(label: Text(lang.entry2)),
      DataColumn(label: Text(lang.distance)),
    ];
  }

  DataRow dataToRow(Adjacency data, int indexInCurrentPage) {
    return DataRow(cells: [
      DataCell(Text(data.entryId1)),
      DataCell(Text(data.entryId2)),
      DataCell(Text(data.distance.toStringAsFixed(4))),
    ]);
  }

  void addAdjacency() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.adjacencyForm),
        content: SizedBox(
          width: 600,
          height: 400,
          child: AdjacencyInputForm(
            key: inputFormKey,
            adjacencyType: widget.type,
          ),
        ),
        actions: [
          getButtons(onSave: onSave),
        ],
      ),
    );
  }

  Future onSave() async {
    var input = inputFormKey.currentState?.read();
    if (input != null) {
      progressSubject.add(true);
      try {
        await client.mutations
            .addAdjacency(input: input)
            .asStream()
            .map((event) => event.addAdjacency)
            .first;
        tableKey.currentState?.refreshPage();
        Navigator.of(context).pop();
      } catch (error, stacktrace) {
        print(stacktrace);
        showServerError2(context, error: error);
      } finally {
        progressSubject.add(false);
      }
    }
  }
}
