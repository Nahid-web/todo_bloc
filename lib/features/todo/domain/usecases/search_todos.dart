import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class SearchTodos implements UseCase<List<Todo>, SearchTodosParams> {
  final TodoRepository repository;

  SearchTodos(this.repository);

  @override
  Future<Either<Failure, List<Todo>>> call(SearchTodosParams params) async {
    return await repository.searchTodos(params.query);
  }
}

class SearchTodosParams extends Equatable {
  final String query;

  const SearchTodosParams({required this.query});

  @override
  List<Object> get props => [query];
}
