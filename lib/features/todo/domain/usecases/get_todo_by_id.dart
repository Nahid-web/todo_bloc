import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class GetTodoById implements UseCase<Todo, GetTodoByIdParams> {
  final TodoRepository repository;

  GetTodoById(this.repository);

  @override
  Future<Either<Failure, Todo>> call(GetTodoByIdParams params) async {
    return await repository.getTodoById(params.id);
  }
}

class GetTodoByIdParams extends Equatable {
  final String id;

  const GetTodoByIdParams({required this.id});

  @override
  List<Object> get props => [id];
}
