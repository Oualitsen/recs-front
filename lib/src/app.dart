import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:recs_front/src/router_config.dart';
import 'package:recs_front/src/widgets/image_with_online_circle_widget.dart';
import 'package:recs_front/src/widgets/side_menu_button.dart';

import 'package:recs_front/generated/types.gq.dart';

import 'package:recs_front/src/settings/settings_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:recs_front/src/utils/image_utils.dart';
import 'package:recs_front/src/utils/injector.dart';
import 'package:gap/gap.dart';

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
    initRouter(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.settingsController,
      builder: (BuildContext context, Widget? child) => MaterialApp(
        navigatorObservers: [MyNavigatorObserver()],
        debugShowCheckedModeBanner: false,
        scrollBehavior: scrollBehavior,
        locale: widget.settingsController.locale,
        localizationsDelegates: localizationsDelegates2,
        supportedLocales: widget.settingsController.supportedLocales,
        theme: ThemeData(
          primaryColor: Colors.blue,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        navigatorKey: navKey,
        onGenerateRoute: router.generator,
        builder: (context, child) => Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) {
                return Scaffold(
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
                                color: Color.fromARGB(255, 190, 204, 211),
                                width: 250,
                                child: StreamBuilder(
                                    stream: currentLocationStream,
                                    initialData:
                                        currentLocationStream.valueOrNull,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return SizedBox.shrink();
                                      }
                                      var url = snapshot.data!;

                                      return mainMenu(context, url, recsUser);
                                    }));
                          }),
                      Expanded(child: child ?? SizedBox.shrink()),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget mainMenu(BuildContext context, String url, FeUser recsUser) {
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
                    if (url == "/") {
                      isActive = e.routeName == "/";
                    } else {
                      isActive = url.startsWith("/${e.routeName}");
                    }
                    return SizedBox(
                      height: 60,
                      width: 270,
                      child: SideMenuButton(
                        showTooltip: false,
                        title: e.getTitle(context),
                        iconData: e.icon,
                        isActive: isActive,
                        onTap: () {
                          var url = e.routeName;
                          if (!url.startsWith("/")) {
                            url = "/${url}";
                          }
                          router.navigateTo(navKey.currentContext!, url);
                        },
                      ),
                    );
                  },
                ).toList(),
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
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Gap(40)
      ],
    );
  }
}

final navKey = GlobalKey<NavigatorState>();

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      currentLocationStream.add(route.settings.name ?? '/');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name != null) {
      currentLocationStream.add(previousRoute?.settings.name ?? '/');
    }
  }
}
