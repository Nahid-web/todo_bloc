import 'package:get_it/get_it.dart';

import '../data/datasources/profile_local_data_source.dart';
import '../data/datasources/profile_remote_data_source.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/usecases/delete_profile_picture.dart';
import '../domain/usecases/get_user_profile.dart';
import '../domain/usecases/update_password.dart';
import '../domain/usecases/update_user_profile.dart';
import '../domain/usecases/upload_profile_picture.dart';
import '../presentation/bloc/profile_bloc.dart';

Future<void> initProfileModule(GetIt sl) async {
  // Bloc
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfile: sl(),
      updateUserProfile: sl(),
      uploadProfilePicture: sl(),
      deleteProfilePicture: sl(),
      updatePassword: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));
  sl.registerLazySingleton(() => UploadProfilePicture(sl()));
  sl.registerLazySingleton(() => DeleteProfilePicture(sl()));
  sl.registerLazySingleton(() => UpdatePassword(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
      firebaseStorage: sl(),
    ),
  );
}
