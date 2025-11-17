import 'package:get_it/get_it.dart';

import '../presentation/bloc/theme_bloc.dart';

Future<void> initSettingsModule(GetIt sl) async {
  // Bloc
  sl.registerLazySingleton(() => ThemeBloc(sharedPreferences: sl()));
}
