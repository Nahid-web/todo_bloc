import 'package:dartz/dartz.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/error/failures.dart';
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
    final user = authService.getCurrentUser();
    if (user == null) {
      return Left(UnexpectedFailure('User not authenticated'));
    }

    try {
      // Try to get from remote first
      final remoteTodos = await remoteDataSource.getTodos(user.uid);

      // Update local cache with remote data
      await _syncLocalCache(remoteTodos);

      return Right(remoteTodos);
    } catch (e) {
      // Fallback to local data if remote fails
      try {
        final localTodos = await localDataSource.getTodos();
        return Right(localTodos);
      } catch (localError) {
        return Left(CacheFailure());
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
        return Left(NotFoundFailure());
      }
    } catch (e) {
      return Left(CacheFailure());
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
        return Left(CacheFailure());
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
        return Left(CacheFailure());
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
        return Left(CacheFailure());
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
        return Left(CacheFailure());
      }
    }
  }

  /// Synchronizes local cache with remote data
  Future<void> _syncLocalCache(List<TodoModel> remoteTodos) async {
    try {
      // Get current local todos
      final localTodos = await localDataSource.getTodos();
      final localTodoIds = localTodos.map((todo) => todo.id).toSet();

      // Add or update todos from remote
      for (final remoteTodo in remoteTodos) {
        if (localTodoIds.contains(remoteTodo.id)) {
          // Update existing todo
          await localDataSource.updateTodo(remoteTodo);
        } else {
          // Add new todo
          await localDataSource.addTodo(remoteTodo);
        }
      }

      // Remove todos that exist locally but not remotely
      final remoteTodoIds = remoteTodos.map((todo) => todo.id).toSet();
      for (final localTodo in localTodos) {
        if (!remoteTodoIds.contains(localTodo.id)) {
          await localDataSource.deleteTodo(localTodo.id);
        }
      }
    } catch (e) {
      // If sync fails, we'll just continue with remote data
      // Local cache will be updated on next successful operation
    }
  }
}
