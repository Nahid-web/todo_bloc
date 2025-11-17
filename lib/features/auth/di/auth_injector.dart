import 'package:get_it/get_it.dart';

import '../data/datasources/auth_local_data_source.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/create_user_with_email_and_password.dart';
import '../domain/usecases/get_current_user.dart';
import '../domain/usecases/sign_in_anonymously.dart';
import '../domain/usecases/sign_in_with_email_and_password.dart';
import '../domain/usecases/sign_out.dart';
import '../presentation/bloc/auth_bloc.dart';

Future<void> initAuthModule(GetIt sl) async {
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signInAnonymouslyUseCase: sl(),
      signInWithEmailAndPasswordUseCase: sl(),
      createUserWithEmailAndPasswordUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInAnonymously(sl()));
  sl.registerLazySingleton(() => SignInWithEmailAndPassword(sl()));
  sl.registerLazySingleton(() => CreateUserWithEmailAndPassword(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );
}
