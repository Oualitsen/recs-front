import 'package:flutter/material.dart';
import 'package:recs_front/src/pages/color_index/color_adjacency_table.dart';
import 'package:recs_front/src/utils/widget_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';

class ColorAdjacencyPage extends StatefulWidget {
  const ColorAdjacencyPage({super.key});

  @override
  State<ColorAdjacencyPage> createState() => _ColorAdjacencyPageState();
}

class _ColorAdjacencyPageState extends BasicState<ColorAdjacencyPage>
    with WidgetUtilsMixin {
  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(title: Text(lang.colorAdjacency)),
        body: ColorAdjacencyTable(),
      ),
    );
  }
}
