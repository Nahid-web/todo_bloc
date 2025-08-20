import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class GetTodosByCategory implements UseCase<List<Todo>, GetTodosByCategoryParams> {
  final TodoRepository repository;

  GetTodosByCategory(this.repository);

  @override
  Future<Either<Failure, List<Todo>>> call(GetTodosByCategoryParams params) async {
    AppLogger.logApp(
      'GetTodosByCategory - Fetching todos by category',
      category: 'TODO_USECASE',
      data: {
        'category': params.category.name,
        'includeCompleted': params.includeCompleted,
      },
    );

    final result = await repository.getTodos();

    return result.fold(
      (failure) {
        AppLogger.logApp(
          'GetTodosByCategory - Failed',
          category: 'TODO_USECASE',
          data: {'category': params.category.name},
          error: failure.toString(),
          level: LogLevel.error,
        );
        return Left(failure);
      },
      (todos) {
        final filteredTodos = todos.where((todo) {
          if (todo.isDeleted) return false;
          if (todo.category != params.category) return false;
          if (!params.includeCompleted && todo.isCompleted) return false;
          return true;
        }).toList();

        AppLogger.logApp(
          'GetTodosByCategory - Success',
          category: 'TODO_USECASE',
          data: {
            'category': params.category.name,
            'totalTodos': todos.length,
            'filteredTodos': filteredTodos.length,
          },
        );

        return Right(filteredTodos);
      },
    );
  }
}

class GetTodosByCategoryParams extends Equatable {
  final TodoCategory category;
  final bool includeCompleted;

  const GetTodosByCategoryParams({
    required this.category,
    this.includeCompleted = false,
  });

  @override
  List<Object> get props => [category, includeCompleted];
}
