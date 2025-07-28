import 'package:equatable/equatable.dart';

import '../../../domain/entities/todo.dart';

abstract class TodoDetailState extends Equatable {
  const TodoDetailState();

  @override
  List<Object> get props => [];
}

class TodoDetailInitial extends TodoDetailState {}

class TodoDetailLoading extends TodoDetailState {}

class TodoDetailLoaded extends TodoDetailState {
  final Todo todo;

  const TodoDetailLoaded(this.todo);

  @override
  List<Object> get props => [todo];
}

class TodoDetailError extends TodoDetailState {
  final String message;

  const TodoDetailError(this.message);

  @override
  List<Object> get props => [message];
}

class TodoDetailDeleted extends TodoDetailState {
  final Todo deletedTodo;

  const TodoDetailDeleted(this.deletedTodo);

  @override
  List<Object> get props => [deletedTodo];
}
