import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class GetTodosByPriority implements UseCase<List<Todo>, GetTodosByPriorityParams> {
  final TodoRepository repository;

  GetTodosByPriority(this.repository);

  @override
  Future<Either<Failure, List<Todo>>> call(GetTodosByPriorityParams params) async {
    AppLogger.logApp(
      'GetTodosByPriority - Fetching todos by priority',
      category: 'TODO_USECASE',
      data: {
        'priority': params.priority.name,
        'includeCompleted': params.includeCompleted,
      },
    );

    final result = await repository.getTodos();

    return result.fold(
      (failure) {
        AppLogger.logApp(
          'GetTodosByPriority - Failed',
          category: 'TODO_USECASE',
          data: {'priority': params.priority.name},
          error: failure.toString(),
          level: LogLevel.error,
        );
        return Left(failure);
      },
      (todos) {
        final filteredTodos = todos.where((todo) {
          if (todo.isDeleted) return false;
          if (todo.priority != params.priority) return false;
          if (!params.includeCompleted && todo.isCompleted) return false;
          return true;
        }).toList();

        // Sort by due date and creation date
        filteredTodos.sort((a, b) {
          // Overdue todos first
          if (a.isOverdue && !b.isOverdue) return -1;
          if (!a.isOverdue && b.isOverdue) return 1;
          
          // Then by due date
          if (a.dueDate != null && b.dueDate != null) {
            return a.dueDate!.compareTo(b.dueDate!);
          }
          if (a.dueDate != null) return -1;
          if (b.dueDate != null) return 1;
          
          // Finally by creation date
          return b.createdAt.compareTo(a.createdAt);
        });

        AppLogger.logApp(
          'GetTodosByPriority - Success',
          category: 'TODO_USECASE',
          data: {
            'priority': params.priority.name,
            'totalTodos': todos.length,
            'filteredTodos': filteredTodos.length,
          },
        );

        return Right(filteredTodos);
      },
    );
  }
}

class GetTodosByPriorityParams extends Equatable {
  final TodoPriority priority;
  final bool includeCompleted;

  const GetTodosByPriorityParams({
    required this.priority,
    this.includeCompleted = false,
  });

  @override
  List<Object> get props => [priority, includeCompleted];
}
