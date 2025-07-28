import 'package:equatable/equatable.dart';

import '../../../domain/entities/todo.dart';

abstract class TodoListState extends Equatable {
  const TodoListState();

  @override
  List<Object> get props => [];
}

class TodoListInitial extends TodoListState {}

class TodoListLoading extends TodoListState {}

class TodoListLoaded extends TodoListState {
  final List<Todo> todos;
  final bool isSearching;
  final String searchQuery;

  const TodoListLoaded({
    required this.todos,
    this.isSearching = false,
    this.searchQuery = '',
  });

  TodoListLoaded copyWith({
    List<Todo>? todos,
    bool? isSearching,
    String? searchQuery,
  }) {
    return TodoListLoaded(
      todos: todos ?? this.todos,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props => [todos, isSearching, searchQuery];
}

class TodoListError extends TodoListState {
  final String message;

  const TodoListError(this.message);

  @override
  List<Object> get props => [message];
}

class TodoDeleted extends TodoListState {
  final Todo deletedTodo;
  final List<Todo> todos;

  const TodoDeleted({
    required this.deletedTodo,
    required this.todos,
  });

  @override
  List<Object> get props => [deletedTodo, todos];
}
