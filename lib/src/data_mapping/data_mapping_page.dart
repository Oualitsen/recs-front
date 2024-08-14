import 'package:flutter/material.dart';
import 'package:recs_front/src/data_mapping/data_mapping_widget.dart';
import 'package:recs_front/src/utils/widget_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';

class DataMappingPage extends StatefulWidget {
  const DataMappingPage({super.key});

  @override
  State<DataMappingPage> createState() => _DataMappingPageState();
}

class _DataMappingPageState extends BasicState<DataMappingPage>
    with WidgetUtilsMixin {
  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(title: Text(lang.mappings)),
        body: DataMappingWidget(),
      ),
    );
  }
}
