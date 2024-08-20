import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart'
    as table;
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/pages/color_index/color_rectangle_widget.dart';
import 'package:recs_front/src/utils/validation_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/custom_text_input_widget.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class ColorAdjacencyTable extends StatefulWidget {
  const ColorAdjacencyTable({super.key});

  @override
  State<ColorAdjacencyTable> createState() => _ColorAdjacencyTableState();
}

class _ColorAdjacencyTableState extends BasicState<ColorAdjacencyTable>
    with WidgetUtilsMixin {
  final colorIndexStream = BehaviorSubject.seeded(<ColorIndex>[]);
  final totalStream = BehaviorSubject.seeded(0);
  final client = GetIt.instance.get<GQClient>();
  final editStream = BehaviorSubject<ColorIndex?>();
  final distanceInputKey = GlobalKey<CustomTextInputWidgetState>();
  final tableKey = GlobalKey<table.LazyPaginatedDataTableState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return table.LazyPaginatedDataTable<ColorIndex>(
      key: tableKey,
      getData: getData,
      getTotal: getTotal,
      columns: getColumns(),
      dataToRow: dataToRow,
    );
  }

  Future<List<ColorIndex>> getData(table.PageInfo info) {
    return client.queries
        .listIndexElements(
          pageInfo: PageInfo(
            page: info.pageIndex,
            size: info.pageSize,
          ),
        )
        .asStream()
        .map((event) {
      totalStream.add(event.total);
      return event.listIndexElements;
    }).first;
  }

  Future<int> getTotal() async {
    return Future.value(totalStream.value);
  }

  List<DataColumn> getColumns() {
    return [
      DataColumn(label: Text("${lang.name} 1")),
      DataColumn(label: Text("${lang.color} 2")),
      DataColumn(label: Text("${lang.name} 1")),
      DataColumn(label: Text("${lang.color} 2")),
      DataColumn(label: Text(lang.distance)),
    ];
  }

  DataRow dataToRow(ColorIndex data, int indexInCurrentPage) {
    return DataRow(cells: [
      DataCell(Text(data.name1)),
      DataCell(
        ColorRectangle(
          hexCode: data.color1,
        ),
      ),
      DataCell(Text(data.name2)),
      DataCell(
        ColorRectangle(
          hexCode: data.color2,
        ),
      ),
      DataCell(
        StreamBuilder<ColorIndex?>(
            stream: editStream,
            builder: (context, snapshot) {
              var currentEdit = snapshot.data;
              if (currentEdit == null) {
                return Row(
                  children: [
                    SizedBox(
                      width: 75,
                      child: Text(data.distance != null
                          ? data.distance!.toStringAsFixed(4)
                          : lang.na),
                    ),
                    Gap(5),
                    IconButton(
                        onPressed: () {
                          editStream.add(data);
                        },
                        icon: Icon(Icons.edit))
                  ],
                );
              }
              if (currentEdit.id != data.id) {
                return SizedBox(
                  width: 75,
                  child: Text(data.distance != null
                      ? data.distance!.toStringAsFixed(4)
                      : lang.na),
                );
              }
              return Row(
                children: [
                  CustomTextInputWidget(
                    key: distanceInputKey,
                    showPrefixIcon: false,
                    initValue: data.distance?.toStringAsFixed(4),
                    validator: (p0) {
                      return ValidationUtils.doubleValidator(p0, context,
                          required: true, minValue: 0);
                    },
                  ),
                  Gap(5),
                  IconButton(
                      onPressed: () async {
                        var value = distanceInputKey.currentState?.getValue();
                        if (value != null) {
                          var newDistance = double.tryParse(value) ?? -1;
                          if (newDistance >= 0) {
                            await updateDistance(data, newDistance);
                          }
                        }
                      },
                      icon: Icon(Icons.check)),
                  IconButton(
                      onPressed: () {
                        editStream.add(null);
                      },
                      icon: Icon(Icons.cancel)),
                ],
              );
            }),
      ),
    ]);
  }

  Future updateDistance(ColorIndex data, double newDistance) async {
    progressSubject.add(true);
    try {
      await client.mutations
          .updateDistance(id: data.id, distance: newDistance)
          .asStream()
          .first;
      editStream.add(null);
      tableKey.currentState?.refreshPage();
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError2(context, error: error);
    } finally {
      progressSubject.add(false);
    }
  }
}
