import 'package:flutter/material.dart';
import 'package:recs_front/generated/enums.gq.dart';
import 'package:recs_front/src/pages/adjacency/typed_adjacency_table.dart';
import 'package:recs_front/src/utils/widget_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';

class AdjacencyTablePage extends StatefulWidget {
  const AdjacencyTablePage({super.key});

  @override
  State<AdjacencyTablePage> createState() => _AdjacencyTablePageState();
}

class _AdjacencyTablePageState extends BasicState<AdjacencyTablePage>
    with WidgetUtilsMixin {
  late List<Tab> tabs = <Tab>[
    ...AdjacencyType.values
        .map((e) => Tab(text: lang.adjecencyTypeName(e)))
        .toList()
  ];
  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(lang.adjacencies),
            bottom: TabBar(
              tabs: tabs,
              isScrollable: true,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2.0,
                  ),
                ),
                color: Color.fromARGB(20, 255, 250, 255),
              ),
            ),
          ),
          body: TabBarView(
              children: AdjacencyType.values
                  .map(
                    (e) => TypedAdjacencyTable(type: e),
                  )
                  .toList()),
        ),
      ),
    );
  }
}
