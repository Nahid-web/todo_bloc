import 'package:equatable/equatable.dart';

import '../../../domain/entities/todo.dart';

abstract class TodoFormEvent extends Equatable {
  const TodoFormEvent();

  @override
  List<Object> get props => [];
}

class LoadTodoForEdit extends TodoFormEvent {
  final String id;

  const LoadTodoForEdit(this.id);

  @override
  List<Object> get props => [id];
}

class SubmitTodo extends TodoFormEvent {
  final String title;
  final String description;

  const SubmitTodo({
    required this.title,
    required this.description,
  });

  @override
  List<Object> get props => [title, description];
}

class UpdateExistingTodo extends TodoFormEvent {
  final Todo todo;

  const UpdateExistingTodo(this.todo);

  @override
  List<Object> get props => [todo];
}

class ResetForm extends TodoFormEvent {}
