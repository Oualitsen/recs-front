import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart' as table;
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/utils/widget_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';

class RulesPage extends StatefulWidget {
  const RulesPage({super.key});

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends BasicState<RulesPage> with WidgetUtilsMixin {
  final client = GetIt.instance.get<GQClient>();
  final key = GlobalKey<table.LazyPaginatedDataTableState>();
  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text(lang.rules),
          actions: [FilledButton(onPressed: () => _addRule(null), child: Text(lang.addRule))],
        ),
        body: table.LazyPaginatedDataTable<Rule>(
          key: key,
          getData: (table.PageInfo info) {
            return client.queries
                .getRules(pageInfo: PageInfo(page: info.pageIndex, size: info.pageSize))
                .asStream()
                .map((event) => event.findRules)
                .first;
          },
          getTotal: () {
            return client.queries.countRules().asStream().map((event) => event.countRules).first;
          },
          columns: [
            DataColumn(label: Text(lang.id)),
            DataColumn(label: Text(lang.attribute)),
            DataColumn(label: Text(lang.edit)),
          ],
          dataToRow: (Rule data, int indexInCurrentPage) {
            return DataRow(cells: [
              DataCell(Text(data.id)),
              DataCell(Text(data.config.path)),
              DataCell(TextButton(
                child: Text(lang.edit),
                onPressed: () => _addRule(data),
              )),
            ]);
          },
        ),
      ),
    );
  }

  void _addRule(Rule? current) async {
    Rule? result;
    if (current == null) {
      result = await Navigator.of(context).pushNamed<dynamic>("/rules/add-rule");
    } else {
      result = await Navigator.of(context).pushNamed<dynamic>("/rules/edit-rule/${current.id}");
    }
    if (result != null) {
      //reload table
      key.currentState!.refreshPage();
    }
  }
}
