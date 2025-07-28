import 'package:equatable/equatable.dart';

import '../../../domain/entities/todo.dart';

abstract class TodoListEvent extends Equatable {
  const TodoListEvent();

  @override
  List<Object> get props => [];
}

class LoadTodos extends TodoListEvent {}

class RefreshTodos extends TodoListEvent {}

class DeleteTodoEvent extends TodoListEvent {
  final String id;

  const DeleteTodoEvent(this.id);

  @override
  List<Object> get props => [id];
}

class SearchTodosEvent extends TodoListEvent {
  final String query;

  const SearchTodosEvent(this.query);

  @override
  List<Object> get props => [query];
}

class ClearSearch extends TodoListEvent {}

class ToggleTodoCompletion extends TodoListEvent {
  final String id;

  const ToggleTodoCompletion(this.id);

  @override
  List<Object> get props => [id];
}

class RestoreTodoEvent extends TodoListEvent {
  final Todo todo;

  const RestoreTodoEvent(this.todo);

  @override
  List<Object> get props => [todo];
}
