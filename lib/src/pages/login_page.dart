import 'package:recs_ymal/generated/client.gq.dart';
import 'package:recs_ymal/src/managers/auth_status.dart';
import 'package:recs_ymal/src/utils/ui_utils.dart';
import 'package:recs_ymal/src/widgets/progress_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_ymal/src/utils/validation_utils.dart';
import 'package:recs_ymal/src/widgets/basic_state.dart';
import 'package:recs_ymal/src/widgets/password_input.dart';
import 'package:rxdart/rxdart.dart';
import 'package:recs_ymal/src/db_services/token_db_service.dart';
import 'package:recs_ymal/src/utils/injector.dart';
import 'package:recs_ymal/src/widgets/widget_utils_mixin.dart';

class LoginPage extends StatefulWidget {
  static const login = "/login";

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends BasicState<LoginPage> with WidgetUtilsMixin {
  final key = GlobalKey<FormState>();
  final emailNameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final graphQlClient = GetIt.instance.get<GQClient>();
  final _authMan = Injector.provideAuthManager();
  final _tokenDbService = GetIt.instance.get<TokenDbService>();
  final errorStream = BehaviorSubject.seeded("");

  @override
  void initState() {
    errorStream
        .where((event) => event.isNotEmpty && key.currentState != null)
        .map((event) => key.currentState!)
        .listen((state) => state.validate());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Container(
            width: 450,
            child: Card(
              child: Form(
                key: key,
                child: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(36),
                          child: Text(
                            lang.login.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(36),
                            child: Text(
                              lang.title2,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        FormUiUtils.requiredPostFix(lang.email),
                        FormUiUtils.labelToInputMargin,
                        TextFormField(
                          controller: emailNameCtrl,
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          validator: (text) {
                            if (errorStream.value.isNotEmpty) {
                              return "";
                            }
                            return ValidationUtils.requiredField(text, context);
                          },
                          decoration: getDecoration("", false),
                        ),
                        FormUiUtils.inertInputMargin,
                        FormUiUtils.requiredPostFix(lang.password),
                        FormUiUtils.labelToInputMargin,
                        PasswordInput(
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (p0) {
                            _login(context);
                          },
                          controller: passwordCtrl,
                          validator: (text) {
                            if (errorStream.value.isNotEmpty) {
                              return "";
                            }
                            return ValidationUtils.requiredField(text, context);
                          },
                        ),
                        FormUiUtils.inertInputMargin,
                        InkWell(
                          onTap: () {
                            print("forgot password");
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Text(
                              lang.forgotPassword,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        FormUiUtils.inertInputMargin,
                        Row(
                          children: [
                            Expanded(
                              child: ProgressWrapper(
                                progressStream: progressSubject,
                                child: FilledButton(
                                  onPressed: () async {
                                    _login(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(lang.login),
                                  ),
                                ),
                                progressChild: FilledButton(
                                  onPressed: null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(lang.login),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        FormUiUtils.inertInputMargin,
                        streamBuilderDiscretLoading<String>(
                          stream: errorStream,
                          onDataChanged: (text) {
                            if (text.isEmpty) {
                              return SizedBox.shrink();
                            }
                            return Center(child: FormUiUtils.errorText(text));
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context) async {
    var state = key.currentState;
    if (state != null) {
      errorStream.add("");
      if (state.validate()) {
        progressSubject.add(true);
        try {
          var result = await graphQlClient.mutations
              .adminLogin(
                  username: emailNameCtrl.text, password: passwordCtrl.text)
              .asStream()
              .map((event) => event.login)
              .first;
          await _tokenDbService.saveTokens(
              accessToken: result.token.accessToken,
              refreshToken: result.token.refreshToken);

          await _authMan.save(result.user);
          _authMan.add(AuthStatus.logged_in);
        } catch (error, stacktrace) {
          // showServerError(context, error: error);
          errorStream.add(lang.invalidCredentials);
          print(stacktrace);
        } finally {
          progressSubject.add(false);
        }
      }
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [emailNameCtrl, passwordCtrl];

  @override
  List<Subject> get subjects => [];
}
