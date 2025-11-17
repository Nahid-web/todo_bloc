import 'package:get_it/get_it.dart';

import '../data/datasources/todo_local_data_source.dart';
import '../data/datasources/todo_remote_data_source.dart';
import '../data/repositories/todo_repository_impl.dart';
import '../domain/repositories/todo_repository.dart';
import '../domain/usecases/add_todo.dart';
import '../domain/usecases/delete_todo.dart';
import '../domain/usecases/get_todo_by_id.dart';
import '../domain/usecases/get_todos.dart';
import '../domain/usecases/restore_todo.dart';
import '../domain/usecases/search_todos.dart';
import '../domain/usecases/update_todo.dart';
import '../presentation/bloc/todo_detail/todo_detail_bloc.dart';
import '../presentation/bloc/todo_form/todo_form_bloc.dart';
import '../presentation/bloc/todo_list/todo_list_bloc.dart';

Future<void> initTodoModule(GetIt sl) async {
  // Blocs
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
}
