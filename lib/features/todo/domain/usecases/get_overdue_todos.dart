import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class GetOverdueTodos implements UseCase<List<Todo>, NoParams> {
  final TodoRepository repository;

  GetOverdueTodos(this.repository);

  @override
  Future<Either<Failure, List<Todo>>> call(NoParams params) async {
    AppLogger.logApp(
      'GetOverdueTodos - Fetching overdue todos',
      category: 'TODO_USECASE',
    );

    final result = await repository.getTodos();

    return result.fold(
      (failure) {
        AppLogger.logApp(
          'GetOverdueTodos - Failed',
          category: 'TODO_USECASE',
          error: failure.toString(),
          level: LogLevel.error,
        );
        return Left(failure);
      },
      (todos) {
        final overdueTodos = todos.where((todo) {
          return !todo.isDeleted && !todo.isCompleted && todo.isOverdue;
        }).toList();

        // Sort by how overdue they are (most overdue first)
        overdueTodos.sort((a, b) {
          if (a.dueDate == null || b.dueDate == null) return 0;
          return a.dueDate!.compareTo(b.dueDate!);
        });

        AppLogger.logApp(
          'GetOverdueTodos - Success',
          category: 'TODO_USECASE',
          data: {
            'totalTodos': todos.length,
            'overdueTodos': overdueTodos.length,
          },
        );

        return Right(overdueTodos);
      },
    );
  }
}
