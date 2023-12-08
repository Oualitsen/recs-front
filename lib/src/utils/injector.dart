import 'package:get_it/get_it.dart';
import 'package:recs_ymal/generated/types.gq.dart';
import 'package:recs_ymal/src/managers/auth_manager.dart';

abstract class Injector {
  static AuthManager<Admin> provideAuthManager() {
    return GetIt.instance.get<AuthManager<Admin>>();
  }
}
