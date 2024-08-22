import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart'
    as table;
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/pages/color_index/color_adjacency_filter.dart';
import 'package:recs_front/src/pages/color_index/color_rectangle_widget.dart';
import 'package:recs_front/src/utils/validation_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/custom_text_input_widget.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class ColorAdjacencyTable extends StatefulWidget {
  const ColorAdjacencyTable({super.key});

  @override
  State<ColorAdjacencyTable> createState() => ColorAdjacencyTableState();
}

class ColorAdjacencyTableState extends BasicState<ColorAdjacencyTable>
    with WidgetUtilsMixin {
  final colorIndexStream = BehaviorSubject.seeded(<ColorIndex>[]);
  final totalStream = BehaviorSubject.seeded(0);
  final client = GetIt.instance.get<GQClient>();
  final editStream = BehaviorSubject<ColorIndex?>();
  final distanceInputKey = GlobalKey<CustomTextInputWidgetState>();
  final tableKey = GlobalKey<table.LazyPaginatedDataTableState>();
  final filterKey = GlobalKey<ColorAdjacencyFilterState>();
  final searchStream = BehaviorSubject.seeded("");
  final messageStream = BehaviorSubject<String?>();

  @override
  void initState() {
    searchStream.debounceTime(Duration(milliseconds: 500)).listen((value) {
      tableKey.currentState?.refreshPage();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: table.LazyPaginatedDataTable<ColorIndex>(
        key: tableKey,
        getData: getData,
        getTotal: getTotal,
        columns: getColumns(),
        dataToRow: dataToRow,
      ),
    );
  }

  Future<List<ColorIndex>> getData(table.PageInfo info) {
    return client.queries
        .listIndexElements(
            pageInfo: PageInfo(
              page: info.pageIndex,
              size: info.pageSize,
            ),
            name: searchStream.valueOrNull)
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
      DataColumn(
        label: StreamBuilder<String>(
            stream: searchStream,
            builder: (context, snapshot) {
              var currentSearch = snapshot.data ?? "";

              return CustomTextInputWidget(
                onChange: (value) {
                  if (currentSearch != value) {
                    searchStream.add(value);
                  }
                },
                hint: "${lang.name} 1",
              );
            }),
      ),
      DataColumn(label: Text("${lang.color} 1")),
      DataColumn(label: Text("${lang.name} 2")),
      DataColumn(label: Text("${lang.color} 2")),
      DataColumn(label: Text(lang.distance)),
      DataColumn(label: Text(lang.manualyUpdated)),
    ];
  }

  DataRow dataToRow(ColorIndex data, int indexInCurrentPage) {
    return DataRow(cells: [
      DataCell(
        TextButton(
          onPressed: () => filterColor(
            data.id,
            ColorInfo(
              name: data.name1,
              colorHex: data.color1,
            ),
          ),
          child: Text(data.name1),
        ),
      ),
      DataCell(
        ColorRectangle(
          hexCode: data.color1,
        ),
      ),
      DataCell(
        TextButton(
          onPressed: () => filterColor(
            data.id,
            ColorInfo(
              name: data.name2,
              colorHex: data.color2,
            ),
          ),
          child: Text(data.name2),
        ),
      ),
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
                      onPressed: () => editStream.add(data),
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
                StreamBuilder<String?>(
                    stream: messageStream,
                    builder: (context, snapshot) {
                      return Tooltip(
                        message: snapshot.data ?? "",
                        child: CustomTextInputWidget(
                          key: distanceInputKey,
                          showPrefixIcon: false,
                          initValue: data.distance?.toStringAsFixed(4),
                          validator: (p0) {
                            var res = ValidationUtils.doubleValidator(
                              p0,
                              context,
                              required: true,
                              minValue: 0,
                            );
                            messageStream.add(res);
                            return res;
                          },
                          onFieldSubmitted: (_) => saveDistance(data.id),
                        ),
                      );
                    }),
                Gap(5),
                IconButton(
                    onPressed: () => saveDistance(data.id),
                    icon: Icon(Icons.check)),
                IconButton(
                    onPressed: () => editStream.add(null),
                    icon: Icon(Icons.cancel)),
              ],
            );
          },
        ),
      ),
      DataCell(
        Text(data.manual ? lang.yes : lang.no),
      )
    ]);
  }

  Future updateDistance(String colorIndexId, double newDistance) async {
    progressSubject.add(true);
    try {
      await client.mutations
          .updateDistance(id: colorIndexId, distance: newDistance)
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

  filterColor(String id, ColorInfo colorInfo) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(colorInfo.name.toUpperCase()),
        content: SizedBox(
          width: 800,
          height: 600,
          child: ColorAdjacencyFilter(
            key: filterKey,
            colorHex: colorInfo.colorHex,
            onDistanceUpdate: (newDistance) => saveDistance(id),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(lang.ok.toUpperCase()),
          )
        ],
      ),
    );
  }

  reload() {
    tableKey.currentState?.refreshPage();
  }

  void saveDistance(String id) async {
    var value = distanceInputKey.currentState?.getValue();
    var newDistance = double.tryParse(value ?? "") ?? -1;
    if (newDistance >= 0) {
      await updateDistance(id, newDistance);
    }
  }
}

class ColorInfo {
  final String colorHex;
  final String name;

  ColorInfo({
    required this.colorHex,
    required this.name,
  });
}
