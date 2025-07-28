import 'package:equatable/equatable.dart';

import '../../../domain/entities/todo.dart';

abstract class TodoDetailEvent extends Equatable {
  const TodoDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadTodoDetail extends TodoDetailEvent {
  final String id;

  const LoadTodoDetail(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleTodoCompletionDetail extends TodoDetailEvent {
  final Todo todo;

  const ToggleTodoCompletionDetail(this.todo);

  @override
  List<Object> get props => [todo];
}

class DeleteTodoDetail extends TodoDetailEvent {
  final String id;

  const DeleteTodoDetail(this.id);

  @override
  List<Object> get props => [id];
}
