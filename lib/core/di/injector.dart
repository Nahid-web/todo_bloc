import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../features/auth/di/auth_injector.dart';
import '../../features/profile/di/profile_injector.dart';
import '../../features/todo/di/todo_injector.dart';
import '../../features/settings/di/settings_injector.dart';
import '../auth/auth_service.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Initialize core dependencies
  await _initCore();

  // Initialize feature modules
  await initAuthModule(sl);
  await initProfileModule(sl);
  await initTodoModule(sl);
  await initSettingsModule(sl);
}

Future<void> _initCore() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Firebase
  final firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  sl.registerLazySingleton(() => firestore);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => InternetConnection());

  // Core Services
  sl.registerLazySingleton<AuthService>(() => AuthServiceImpl(sl()));
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}
