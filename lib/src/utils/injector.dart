import 'package:get_it/get_it.dart';
import 'package:recs_front/src/managers/auth_manager.dart';

abstract class Injector {
  static AuthManager provideAuthManager() {
    return GetIt.instance.get<AuthManager>();
  }
}
