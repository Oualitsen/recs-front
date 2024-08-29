import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recs_front/generated/enums.gq.dart';
import 'package:recs_front/src/data_mapping/data_mapping_page.dart';
import 'package:recs_front/src/pages/adjacency/adjacency_input_form.dart';
import 'package:recs_front/src/pages/adjacency/adjacency_table_page.dart';
import 'package:recs_front/src/pages/category/category_tree.dart';
import 'package:recs_front/src/pages/category/select_category_tree_widget.dart';
import 'package:recs_front/src/pages/color_index/color_adjacency_page.dart';
import 'package:recs_front/src/pages/home/home_page.dart';
import 'package:recs_front/src/pages/images/image_search_page.dart';
import 'package:recs_front/src/pages/product/product_details_page.dart';
import 'package:recs_front/src/pages/profile_page.dart';
import 'package:recs_front/src/pages/rules/add_rule_page.dart';
import 'package:recs_front/src/pages/rules/rules_page.dart';
import 'package:recs_front/src/pages/sku/sku_list_page.dart';
import 'package:recs_front/src/utils/lang.dart';
import 'package:recs_front/src/utils/widget_utils.dart';
import 'package:rxdart/rxdart.dart';

final router = FluroRouter();
final currentLocationStream = BehaviorSubject<String>();

final menuButtonList = <MenuButtonInfo>[
  MenuButtonInfo(
    icon: FontAwesomeIcons.house,
    getTitle: (context) => getLang(context).dashboard,
    routeName: "/",
    destinationRoute: (context, params) => HomePage(),
  ),
  MenuButtonInfo(
    icon: FontAwesomeIcons.magnifyingGlass,
    getTitle: (context) => getLang(context).search,
    routeName: "search",
    destinationRoute: (context, params) => ImageSearchPage(),
  ),
  MenuButtonInfo(
    icon: FontAwesomeIcons.gear,
    getTitle: (context) => getLang(context).mappings,
    routeName: "mappings",
    destinationRoute: (context, params) => DataMappingPage(),
  ),
  MenuButtonInfo(
    icon: FontAwesomeIcons.gear,
    getTitle: (context) => getLang(context).categoriesTree,
    routeName: "categories",
    destinationRoute: (context, params) => CategoriesTree(),
  ),
  MenuButtonInfo(
    icon: FontAwesomeIcons.gear,
    getTitle: (context) => getLang(context).colorAdjacency,
    routeName: "color-adjacency",
    destinationRoute: (context, params) => ColorAdjacencyPage(),
  ),
  MenuButtonInfo(
    icon: FontAwesomeIcons.gear,
    getTitle: (context) => getLang(context).adjacencies,
    routeName: "adjacencies",
    destinationRoute: (context, params) => AdjacencyTablePage(),
  ),
  MenuButtonInfo(
    icon: FontAwesomeIcons.gear,
    getTitle: (context) => getLang(context).rules,
    routeName: "rules",
    destinationRoute: (context, params) => RulesPage(),
  ),
  MenuButtonInfo(
    icon: FontAwesomeIcons.userLarge,
    getTitle: (context) => getLang(context).profile,
    routeName: "settings",
    destinationRoute: (context, params) => ProfilePage(),
  ),
];

void initRouter(
  BuildContext context,
) {
  router.notFoundHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return Scaffold(
      body: Center(
        child: Text("NOT FOUND"),
      ),
    );
  });
  router.define(
    '/skus/:productId',
    handler: Handler(
      handlerFunc: (context, parameters) {
        String productId = parameters['productId']!.first;
        return WidgetUtils.wrapRoute(
          (context, type) => SkuListPage(
            productId: productId,
          ),
        );
      },
    ),
  );
  router.define(
    '/rules/edit-rule/:ruleId',
    handler: Handler(
      handlerFunc: (context, parameters) {
        String ruleId = parameters['ruleId']!.first;
        return Builder(builder: (context) {
          return WidgetUtils.wrapRoute(
            (context, type) => AddRulePage(ruleId: ruleId),
          );
        });
      },
    ),
  );
  router.define(
    '/rules/add-rule',
    handler: Handler(
      handlerFunc: (context, parameters) {
        return WidgetUtils.wrapRoute(
          (context, type) => AddRulePage(),
        );
      },
    ),
  );

  router.define(
    '/products/:id',
    handler: Handler(
      handlerFunc: (context, parameters) {
        String id = parameters['id']!.first;
        return WidgetUtils.wrapRoute(
          (context, type) => ProductDetailsPage(
            skuId: id,
          ),
        );
      },
    ),
  );
  for (var element in menuButtonList) {
    router.define(
      element.routeName,
      handler: Handler(
        handlerFunc: (context, parameters) {
          return element.destinationRoute(context, parameters);
        },
      ),
    );
  }
}

class MenuButtonInfo {
  final IconData icon;
  final String routeName;
  final Widget Function(BuildContext? context, Map<String, List<String>> params) destinationRoute;
  final String Function(BuildContext context) getTitle;

  MenuButtonInfo({
    required this.icon,
    required this.routeName,
    required this.destinationRoute,
    required this.getTitle,
  });
}
