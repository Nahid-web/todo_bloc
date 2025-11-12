import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_service.dart';
import '../network/network_info.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/create_user_with_email_and_password.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/sign_in_anonymously.dart';
import '../../features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/todo/data/datasources/todo_local_data_source.dart';
import '../../features/todo/data/datasources/todo_remote_data_source.dart';
import '../../features/todo/data/repositories/todo_repository_impl.dart';
import '../../features/todo/domain/repositories/todo_repository.dart';
import '../../features/todo/domain/usecases/add_todo.dart';
import '../../features/todo/domain/usecases/delete_todo.dart';
import '../../features/todo/domain/usecases/get_todo_by_id.dart';
import '../../features/todo/domain/usecases/get_todos.dart';
import '../../features/todo/domain/usecases/restore_todo.dart';
import '../../features/todo/domain/usecases/search_todos.dart';
import '../../features/todo/domain/usecases/update_todo.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/delete_profile_picture.dart';
import '../../features/profile/domain/usecases/get_user_profile.dart';
import '../../features/profile/domain/usecases/update_password.dart';
import '../../features/profile/domain/usecases/update_user_profile.dart';
import '../../features/profile/domain/usecases/upload_profile_picture.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/settings/presentation/bloc/theme_bloc.dart';
import '../../features/todo/presentation/bloc/todo_detail/todo_detail_bloc.dart';
import '../../features/todo/presentation/bloc/todo_form/todo_form_bloc.dart';
import '../../features/todo/presentation/bloc/todo_list/todo_list_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Todo
  // Bloc
  sl.registerFactory(
    () => TodoListBloc(
      getTodos: sl(),
      deleteTodo: sl(),
      searchTodos: sl(),
      updateTodo: sl(),
      restoreTodo: sl(),
    ),
  );

  sl.registerFactory(
    () => TodoFormBloc(addTodo: sl(), updateTodo: sl(), getTodoById: sl()),
  );

  sl.registerFactory(
    () => TodoDetailBloc(getTodoById: sl(), updateTodo: sl(), deleteTodo: sl()),
  );

  // Auth Bloc
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

  // Theme Bloc
  sl.registerLazySingleton(() => ThemeBloc(sharedPreferences: sl()));

  // Profile Bloc
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfile: sl(),
      updateUserProfile: sl(),
      uploadProfilePicture: sl(),
      deleteProfilePicture: sl(),
      updatePassword: sl(),
    ),
  );

  // Use cases - Profile
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));
  sl.registerLazySingleton(() => UploadProfilePicture(sl()));
  sl.registerLazySingleton(() => DeleteProfilePicture(sl()));
  sl.registerLazySingleton(() => UpdatePassword(sl()));

  // Use cases - Todo
  sl.registerLazySingleton(() => GetTodos(sl()));
  sl.registerLazySingleton(() => GetTodoById(sl()));
  sl.registerLazySingleton(() => AddTodo(sl()));
  sl.registerLazySingleton(() => UpdateTodo(sl()));
  sl.registerLazySingleton(() => DeleteTodo(sl()));
  sl.registerLazySingleton(() => SearchTodos(sl()));

  // Use cases - Auth
  sl.registerLazySingleton(() => SignInAnonymously(sl()));
  sl.registerLazySingleton(() => SignInWithEmailAndPassword(sl()));
  sl.registerLazySingleton(() => CreateUserWithEmailAndPassword(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => RestoreTodo(sl()));

  // Repository - Todo
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      authService: sl(),
    ),
  );

  // Repository - Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Repository - Profile
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources - Todo
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSourceImpl(firestore: sl(), auth: sl()),
  );

  // Data sources - Auth
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );

  // Data sources - Profile
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

  // Auth
  sl.registerLazySingleton<AuthService>(() => AuthServiceImpl(sl()));

  // Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! Core

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Firebase
  final firestore = FirebaseFirestore.instance;

  // Enable offline persistence
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  sl.registerLazySingleton(() => firestore);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => InternetConnection());
}
