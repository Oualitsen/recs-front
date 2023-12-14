import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_ymal/generated/client.gq.dart';
import 'package:recs_ymal/src/widgets/basic_state.dart';
import 'package:recs_ymal/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class EmptyPage extends StatefulWidget {
  const EmptyPage({super.key});

  @override
  State<EmptyPage> createState() => _EmptyPageState();
}

class _EmptyPageState extends BasicState<EmptyPage> with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
