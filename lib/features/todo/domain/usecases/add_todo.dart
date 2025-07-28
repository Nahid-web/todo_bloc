import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class AddTodo implements UseCase<Todo, AddTodoParams> {
  final TodoRepository repository;

  AddTodo(this.repository);

  @override
  Future<Either<Failure, Todo>> call(AddTodoParams params) async {
    return await repository.addTodo(params.todo);
  }
}

class AddTodoParams extends Equatable {
  final Todo todo;

  const AddTodoParams({required this.todo});

  @override
  List<Object> get props => [todo];
}
