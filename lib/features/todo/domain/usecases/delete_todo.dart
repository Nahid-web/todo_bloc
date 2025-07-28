import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/todo_repository.dart';

class DeleteTodo implements UseCase<void, DeleteTodoParams> {
  final TodoRepository repository;

  DeleteTodo(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTodoParams params) async {
    return await repository.deleteTodo(params.id);
  }
}

class DeleteTodoParams extends Equatable {
  final String id;

  const DeleteTodoParams({required this.id});

  @override
  List<Object> get props => [id];
}
