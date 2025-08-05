import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_service.dart';
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
  sl.registerFactory(() => AuthBloc(authService: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetTodos(sl()));
  sl.registerLazySingleton(() => GetTodoById(sl()));
  sl.registerLazySingleton(() => AddTodo(sl()));
  sl.registerLazySingleton(() => UpdateTodo(sl()));
  sl.registerLazySingleton(() => DeleteTodo(sl()));
  sl.registerLazySingleton(() => SearchTodos(sl()));
  sl.registerLazySingleton(() => RestoreTodo(sl()));

  // Repository
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      authService: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSourceImpl(firestore: sl(), auth: sl()),
  );

  // Auth
  sl.registerLazySingleton<AuthService>(() => AuthServiceImpl(sl()));

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
}
