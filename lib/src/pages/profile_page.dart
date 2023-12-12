import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';

import 'package:rxdart/rxdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recs_ymal/generated/client.gq.dart';
import 'package:recs_ymal/generated/inputs.gq.dart';
import 'package:recs_ymal/generated/types.gq.dart';
import 'package:recs_ymal/main.dart';
import 'package:recs_ymal/src/db_services/token_db_service.dart';
import 'package:recs_ymal/src/utils/injector.dart';
import 'package:recs_ymal/src/utils/lang.dart';
import 'package:recs_ymal/src/utils/media_mixin.dart';
import 'package:recs_ymal/src/utils/validation_utils.dart';
import 'package:recs_ymal/src/utils/widget_utils.dart';
import 'package:recs_ymal/src/widgets/basic_state.dart';
import 'package:recs_ymal/src/widgets/password_input.dart';
import 'package:recs_ymal/src/widgets/widget_utils_mixin.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = "profile";

  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends BasicState<ProfilePage>
    with WidgetUtilsMixin, MediaMixin {
  final authMan = Injector.provideAuthManager();

  final service = GetIt.instance.get<GQClient>();
  final passwordKey = GlobalKey<FormState>();

  final newPasswordController = TextEditingController();
  final oldPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => StreamBuilder<RecsUser?>(
          stream: authMan.userSubject,
          initialData: authMan.userSubject.valueOrNull,
          builder: (context, snapshot) {
            var user = snapshot.data;
            if (user == null) {
              return const SizedBox.shrink();
            }
            return Scaffold(
              appBar: AppBar(
                iconTheme: const IconThemeData(color: Colors.black),
                elevation: 0.0,
                backgroundColor: Colors.transparent,
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user.preferredUsername,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              )
                            ],
                          ),
                          const Gap(20),
                          wrap(Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(FontAwesomeIcons.globe),
                                    const Gap(10),
                                    Text(lang.changeLanguage),
                                  ],
                                ),
                                const Gap(32),
                                Row(
                                  textDirection: TextDirection.ltr,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children:
                                      settingsController.supportedLocales.map(
                                    (e) {
                                      if (settingsController.locale == e) {
                                        return ElevatedButton(
                                            onPressed: () {
                                              settingsController
                                                  .updateLocale(e);
                                            },
                                            child: Text(lang
                                                .getLangName(e.languageCode)));
                                      }
                                      return OutlinedButton(
                                          onPressed: () {
                                            settingsController.updateLocale(e);
                                          },
                                          child: Text(lang
                                              .getLangName(e.languageCode)));
                                    },
                                  ).toList(),
                                )
                              ],
                            ),
                          )),
                          const Gap(20),
                          wrap(InkWell(
                            onTap: () async {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Form(
                                      key: passwordKey,
                                      child: AlertDialog(
                                        title: Text(lang.changePassword),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            PasswordInput(
                                              controller: oldPasswordController,
                                              label: Text(lang.oldPassword),
                                              validator: (text) {
                                                return ValidationUtils
                                                    .requiredField(
                                                        text, context);
                                              },
                                            ),
                                            Gap(16),
                                            PasswordInput(
                                              controller: newPasswordController,
                                              label: Text(lang.newPassword),
                                              validator: (text) {
                                                return ValidationUtils
                                                    .requiredField(
                                                        text, context);
                                              },
                                            ),
                                            const Gap(16),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          getButtons(
                                              onSave: null,
                                              saveLabel: lang.changePassword),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.lock),
                                  const Gap(10),
                                  Text(lang.changePassword),
                                ],
                              ),
                            ),
                          )),
                          const Gap(20),
                          wrap(InkWell(
                            onTap: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text(lang.confirm),
                                  content: Text(lang.confirmLogout),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(lang.no.toUpperCase()),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                    ),
                                    TextButton(
                                      child: Text(lang.yes.toUpperCase()),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                    )
                                  ],
                                ),
                              )
                                  .asStream()
                                  .where((event) => event)
                                  .asyncMap((event) {
                                final userManager =
                                    Injector.provideAuthManager();
                                return userManager.remove();
                              }).asyncMap((event) {
                                var service =
                                    GetIt.instance.get<TokenDbService>();
                                return service.remove();
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
                          ))
                        ],
                      ),
                      const Gap(20),
                      wrap(
                        InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                const Icon(Icons.file_copy_rounded),
                                Text(lang.termsAndConditions)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Future<ImageSource?> imageSource2(BuildContext context) =>
      showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => ListView(
          children: [
            ListTile(
              title: Text(lang.camera.toUpperCase()),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              title: Text(lang.gallery.toUpperCase()),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      );

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [uploadProgress];
}
