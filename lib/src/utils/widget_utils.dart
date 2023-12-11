import 'package:flutter_responsive_tools/responsive_builder.dart';
import 'package:gap/gap.dart';
import 'package:recs_ymal/generated/types.gq.dart';
import 'package:recs_ymal/src/pages/login_page.dart';
import 'package:recs_ymal/src/pages/profile_page.dart';
import 'package:recs_ymal/src/widgets/basic_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_responsive_tools/device_screen_type.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_ymal/src/db_services/token_db_service.dart';
import 'package:recs_ymal/src/utils/injector.dart';
import 'package:recs_ymal/src/widgets/menu_drawer.dart';
import 'package:recs_ymal/src/utils/lang.dart';
import 'package:recs_ymal/src/widgets/route_guard_widget.dart';

class WidgetUtils {
  static Widget wrapRoute(Widget Function(BuildContext context, DeviceScreenType type) route,
      {guard = true, useTemplate = true}) {
    final _authManager = Injector.provideAuthManager();
    if (guard) {
      return RouteGuardWidget(
        authStream: _authManager.subject,
        loggedOutBuilder: (context) => const LoginPage(),
        childBuilder: (context) {
          var user = _authManager.currentUser;
          if (user != null) {
            return ResponsiveBuilder((context, info) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: route(context, info.type),
                ));
          } else {
            return const LoginPage();
          }
        },
      );
    }
    return ResponsiveBuilder((context, info) => route(context, info.type));
  }
}

Widget createDrawer(BuildContext context) {
  final authManager = Injector.provideAuthManager();
  final lang = getLang(context);
  return MenuDrawer(
    items: [
      DrawerMenuItem(
        title: (lang.profile),
        icon: Icons.person,
        onTap: () => Navigator.of(context).pushNamed(ProfilePage.routeName),
      ),
      DrawerMenuItem(
        title: (lang.logout),
        icon: Icons.logout,
        onTap: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(lang.confirm),
              content: Text(lang.confirmLogout),
              actions: <Widget>[
                TextButton(
                  child: Text(lang.no.toUpperCase()),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(lang.yes.toUpperCase()),
                  onPressed: () => Navigator.of(context).pop(true),
                )
              ],
            ),
          ).asStream().where((event) => event).asyncMap((event) {
            final userManager = Injector.provideAuthManager();
            return userManager.remove();
          }).asyncMap((event) {
            var service = GetIt.instance.get<TokenDbService>();
            return service.remove();
          }).listen((event) {
            //print("logged out");
          });
        },
      ),
    ],
    header: DrawerHeader(
      decoration: const BoxDecoration(),
      child: StreamBuilder<Admin?>(
          stream: authManager.userSubject,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            var user = snapshot.data!;

            return Column(
              children: <Widget>[
                Gap(30),
                Text(
                  "${user.user.preferredUsername}".toUpperCase(),
                ),
                Gap(15),
                const Gap(5),
              ],
            );
          }),
    ),
  );
}

AppBar defaultAppBar(BuildContext context, {List<Widget>? actions}) {
  return AppBar(
    iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/logo-no-bg.png",
          height: 45,
          scale: 1.0,
        )
      ],
    ),
    actions: actions,
  );
}

Widget wrap(Widget child, {double radius = 16}) => Container(
    decoration: BoxDecoration(
        color: const Color(0xFFf2f2f2), borderRadius: BorderRadius.all(Radius.circular(radius))),
    child: child);

Widget logoutButton(BuildContext context) {
  var lang = getLang(context);
  return wrap(TextButton(
    onPressed: () async {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(lang.confirm),
          content: Text(lang.confirmLogout),
          actions: <Widget>[
            TextButton(
              child: Text(lang.no.toUpperCase()),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(lang.yes.toUpperCase()),
              onPressed: () => Navigator.of(context).pop(true),
            )
          ],
        ),
      ).asStream().where((event) => event).asyncMap((event) async {
        // final service = GetIt.instance.get<TokenService>();
        var dbService = GetIt.instance.get<TokenDbService>();
        //try {
        // var token = await FirebaseMessaging.instance.getToken();
        // if (token != null) {
        //   await service.removeToken(token);
        // }
        // } catch (error, stacktrace) {
        //   print(stacktrace);
        //   showServerError(context, error: error);
        // }

        dbService.remove();
        final userManager = Injector.provideAuthManager();
        return userManager.remove();
      }).listen((event) {
        //print("logged out");
      });
    },
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          const Icon(Icons.logout),
          const Gap(10),
          Text(lang.logout),
        ],
      ),
    ),
  ));
}

StepperType getStepperType(DeviceScreenType type) {
  switch (type) {
    case DeviceScreenType.mobile:
      return StepperType.vertical;
    case DeviceScreenType.tablet:
      return StepperType.vertical;
    case DeviceScreenType.desktop:
      return StepperType.horizontal;
  }
}
