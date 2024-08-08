import 'package:flutter/material.dart';
import 'package:recs_front/src/pages/category/category_table.dart';
import 'package:recs_front/src/pages/product/product_table.dart';
import 'package:recs_front/src/utils/widget_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
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
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              lang.dashboard,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          body: Column(
            children: [
              TabBar(
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
                tabs: [
                  Tab(text: lang.products),
                  Tab(text: lang.categories),
                ],
              ),
              Expanded(
                child: TabBarView(children: [
                  ProductTableWidget(),
                  CategoryTable(),
                ]),
              )
            ],
          ),
        ),
      );
    }, guard: true);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
