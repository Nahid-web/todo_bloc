import 'package:dartz/dartz.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_data_source.dart';
import '../datasources/todo_remote_data_source.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;
  final TodoRemoteDataSource remoteDataSource;
  final AuthService authService;

  TodoRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.authService,
  });

  @override
  Future<Either<Failure, List<Todo>>> getTodos() async {
    AppLogger.logApp('TodoRepository - Getting todos', category: 'REPOSITORY');

    final user = authService.getCurrentUser();
    if (user == null) {
      AppLogger.logApp(
        'TodoRepository - User not authenticated',
        category: 'REPOSITORY',
        level: LogLevel.error,
      );
      return Left(UnexpectedFailure('User not authenticated'));
    }

    AppLogger.logUserAction('Get todos', userId: user.uid);

    try {
      // Try to get from remote first
      final remoteTodos = await remoteDataSource.getTodos(user.uid);

      AppLogger.logFirestore(
        'GET',
        'users/${user.uid}/todos',
        resultCount: remoteTodos.length,
      );

      // Cache locally
      for (final todo in remoteTodos) {
        await localDataSource.addTodo(todo);
      }

      AppLogger.logApp(
        'TodoRepository - Todos retrieved successfully from remote',
        category: 'REPOSITORY',
        data: {'count': remoteTodos.length},
      );

      return Right(remoteTodos);
    } catch (e) {
      AppLogger.logApp(
        'TodoRepository - Remote fetch failed, trying local cache',
        category: 'REPOSITORY',
        data: {'error': e.toString()},
        level: LogLevel.warning,
      );

      // Fallback to local data if remote fails
      try {
        final localTodos = await localDataSource.getTodos();

        AppLogger.logApp(
          'TodoRepository - Todos retrieved from local cache',
          category: 'REPOSITORY',
          data: {'count': localTodos.length},
        );

        return Right(localTodos);
      } catch (localError) {
        AppLogger.logApp(
          'TodoRepository - Both remote and local fetch failed',
          category: 'REPOSITORY',
          data: {'error': localError.toString()},
          level: LogLevel.error,
        );
        return Left(CacheFailure('Failed to get todos from cache'));
      }
    }
  }

  @override
  Future<Either<Failure, Todo>> getTodoById(String id) async {
    final user = authService.getCurrentUser();
    if (user == null) {
      return Left(UnexpectedFailure('User not authenticated'));
    }

    try {
      // Try remote first
      final remoteTodo = await remoteDataSource.getTodoById(user.uid, id);
      if (remoteTodo != null) {
        // Cache locally
        await localDataSource.updateTodo(remoteTodo);
        return Right(remoteTodo);
      }

      // Fallback to local
      final localTodo = await localDataSource.getTodoById(id);
      if (localTodo != null) {
        return Right(localTodo);
      } else {
        return Left(NotFoundFailure('Todo not found'));
      }
    } catch (e) {
      return Left(CacheFailure('Failed to get todo from cache'));
    }
  }

  @override
  Future<Either<Failure, Todo>> addTodo(Todo todo) async {
    final user = authService.getCurrentUser();
    if (user == null) {
      return Left(UnexpectedFailure('User not authenticated'));
    }

    try {
      final todoModel = TodoModel.fromEntity(todo);

      // Add to remote first
      final remoteTodo = await remoteDataSource.addTodo(user.uid, todoModel);

      // Cache locally
      await localDataSource.addTodo(remoteTodo);

      return Right(remoteTodo);
    } catch (e) {
      // Fallback to local only
      try {
        final todoModel = TodoModel.fromEntity(todo);
        final result = await localDataSource.addTodo(todoModel);
        return Right(result);
      } catch (localError) {
        return Left(CacheFailure('Failed to add todo to cache'));
      }
    }
  }

  @override
  Future<Either<Failure, Todo>> updateTodo(Todo todo) async {
    final user = authService.getCurrentUser();
    if (user == null) {
      return Left(UnexpectedFailure('User not authenticated'));
    }

    try {
      final todoModel = TodoModel.fromEntity(todo);

      // Update remote first
      final remoteTodo = await remoteDataSource.updateTodo(user.uid, todoModel);

      // Update local cache
      await localDataSource.updateTodo(remoteTodo);

      return Right(remoteTodo);
    } catch (e) {
      // Fallback to local only
      try {
        final todoModel = TodoModel.fromEntity(todo);
        final result = await localDataSource.updateTodo(todoModel);
        return Right(result);
      } catch (localError) {
        return Left(CacheFailure('Failed to update todo in cache'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> deleteTodo(String id) async {
    final user = authService.getCurrentUser();
    if (user == null) {
      return Left(UnexpectedFailure('User not authenticated'));
    }

    try {
      // Delete from remote first
      await remoteDataSource.deleteTodo(user.uid, id);

      // Delete from local cache
      await localDataSource.deleteTodo(id);

      return const Right(null);
    } catch (e) {
      // Fallback to local only
      try {
        await localDataSource.deleteTodo(id);
        return const Right(null);
      } catch (localError) {
        return Left(CacheFailure('Failed to delete todo from cache'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Todo>>> searchTodos(String query) async {
    final user = authService.getCurrentUser();
    if (user == null) {
      return Left(UnexpectedFailure('User not authenticated'));
    }

    try {
      // Search remote first
      final remoteTodos = await remoteDataSource.searchTodos(user.uid, query);
      return Right(remoteTodos);
    } catch (e) {
      // Fallback to local search
      try {
        final localTodos = await localDataSource.searchTodos(query);
        return Right(localTodos);
      } catch (localError) {
        return Left(CacheFailure('Failed to restore todo in cache'));
      }
    }
  }
}
