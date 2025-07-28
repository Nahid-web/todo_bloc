import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class RestoreTodo implements UseCase<Todo, RestoreTodoParams> {
  final TodoRepository repository;

  RestoreTodo(this.repository);

  @override
  Future<Either<Failure, Todo>> call(RestoreTodoParams params) async {
    return await repository.addTodo(params.todo);
  }
}

class RestoreTodoParams extends Equatable {
  final Todo todo;

  const RestoreTodoParams({required this.todo});

  @override
  List<Object> get props => [todo];
}
