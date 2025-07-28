import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_data_source.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;

  TodoRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Todo>>> getTodos() async {
    try {
      final localTodos = await localDataSource.getTodos();
      return Right(localTodos);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Todo>> getTodoById(String id) async {
    try {
      final todo = await localDataSource.getTodoById(id);
      if (todo != null) {
        return Right(todo);
      } else {
        return Left(NotFoundFailure());
      }
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Todo>> addTodo(Todo todo) async {
    try {
      final todoModel = TodoModel.fromEntity(todo);
      final result = await localDataSource.addTodo(todoModel);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Todo>> updateTodo(Todo todo) async {
    try {
      final todoModel = TodoModel.fromEntity(todo);
      final result = await localDataSource.updateTodo(todoModel);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteTodo(String id) async {
    try {
      await localDataSource.deleteTodo(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Todo>>> searchTodos(String query) async {
    try {
      final todos = await localDataSource.searchTodos(query);
      return Right(todos);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
