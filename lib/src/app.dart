import 'dart:ui';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:recs_front/src/data_mapping/data_mapping_widget.dart';
import 'package:recs_front/src/pages/home/home_page.dart';
import 'package:recs_front/src/pages/images/image_search_page.dart';
import 'package:recs_front/src/pages/product/product_details_page.dart';
import 'package:recs_front/src/pages/profile_page.dart';
import 'package:recs_front/src/pages/sku/sku_list_page.dart';
import 'package:recs_front/src/utils/widget_utils.dart';
import 'package:recs_front/src/widgets/image_with_online_circle_widget.dart';
import 'package:recs_front/src/widgets/side_menu_button.dart';

import 'package:rxdart/rxdart.dart';
import 'package:recs_front/generated/types.gq.dart';

import 'package:recs_front/src/settings/settings_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:recs_front/src/utils/image_utils.dart';
import 'package:recs_front/src/utils/injector.dart';
import 'package:recs_front/src/utils/ui_utils.dart';
import 'package:gap/gap.dart';

final router = FluroRouter();
void initRouter() {
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
          return element.destinationRoute;
        },
      ),
    );
  }
}

final currentLocationStream = BehaviorSubject<String>();
final menuButtonList = <MenuButtonInfo>[
  MenuButtonInfo(
    name: Icons.home,
    routeName: "/",
    destinationRoute: HomePage(),
  ),
  MenuButtonInfo(
    name: Icons.search,
    routeName: "search",
    destinationRoute: ImageSearchPage(),
  ),
  MenuButtonInfo(
    name: Icons.settings,
    routeName: "mappings",
    destinationRoute: DataMappingWidget(),
  ),
  MenuButtonInfo(
    name: Icons.settings,
    routeName: "settings",
    destinationRoute: ProfilePage(),
  ),
];

final appKey = GlobalKey();
final routeObserverProvider = RouteObserver<ModalRoute<void>>();

class MyApp extends StatefulWidget {
  final SettingsController settingsController;

  MyApp({
    super.key,
    required this.settingsController,
  });

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> with RouteAware {
  final authMan = Injector.provideAuthManager();
  ScrollBehavior scrollBehavior = MaterialScrollBehavior().copyWith(
    dragDevices: {
      PointerDeviceKind.mouse,
      PointerDeviceKind.touch,
      PointerDeviceKind.stylus,
      PointerDeviceKind.unknown
    },
    scrollbars: true,
    overscroll: true,
  );

  static const localizationsDelegates2 = const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  @override
  void initState() {
    initRouter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [MyNavigatorObserver()],
      debugShowCheckedModeBanner: false,
      scrollBehavior: scrollBehavior,
      locale: widget.settingsController.locale,
      localizationsDelegates: localizationsDelegates2,
      supportedLocales: widget.settingsController.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      navigatorKey: navKey,
      onGenerateRoute: router.generator,
      builder: (context, child) => Scaffold(
        body: Row(
          children: [
            StreamBuilder<FeUser?>(
                stream: authMan.userSubject,
                initialData: authMan.currentUser,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return SizedBox.shrink();
                  }
                  FeUser recsUser = snapshot.data!;
                  return Container(
                      color: Colors.blueGrey,
                      width: 100,
                      child: streamBuilderDiscretLoading(
                          stream: currentLocationStream,
                          onDataChanged: (url) {
                            return Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Gap(50),
                                        ImageUtils.fromAssetRounded("assets/images/logo.png",
                                            height: 40, fit: BoxFit.contain),
                                        Gap(50),
                                        ...menuButtonList.map(
                                          (e) {
                                            var isActive = false;

                                            //home page
                                            if (url == "/") {
                                              isActive = e.routeName == "/";
                                            } else {
                                              isActive = url.startsWith("/${e.routeName}");
                                            }
                                            return SideMenuButton(
                                              iconData: e.name,
                                              isActive: isActive,
                                              onTap: () {
                                                var url = e.routeName;
                                                if (!url.startsWith("/")) {
                                                  url = "/${url}";
                                                }
                                                router.navigateTo(navKey.currentContext!, url);
                                              },
                                            );
                                          },
                                        ).toList()
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    router.navigateTo(navKey.currentContext!, "/settings");
                                  },
                                  child: ImageWithOnlineCircleWidget(
                                    child: Center(
                                      child: Text(
                                        "${recsUser.name[0].toUpperCase()}",
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                Gap(40)
                              ],
                            );
                          }));
                }),
            Expanded(child: child ?? SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

final navKey = GlobalKey<NavigatorState>();

class MenuButtonInfo {
  final IconData name;
  final String routeName;
  final Widget destinationRoute;

  MenuButtonInfo({
    required this.name,
    required this.routeName,
    required this.destinationRoute,
  });
}

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    currentLocationStream.add(route.settings.name ?? '/');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    currentLocationStream.add(previousRoute?.settings.name ?? '/');
  }
}
