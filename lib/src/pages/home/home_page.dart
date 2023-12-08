import 'package:flutter/material.dart';
import 'package:recs_ymal/src/utils/widget_utils.dart';
import 'package:recs_ymal/src/widgets/basic_state.dart';
import 'package:recs_ymal/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatefulWidget {
  static const home = "/";

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends BasicState<HomePage> with TickerProviderStateMixin, WidgetUtilsMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute((context, type) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            lang.homePage,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        body: ListView(
          children: [],
        ),
      );
    }, guard: true);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
