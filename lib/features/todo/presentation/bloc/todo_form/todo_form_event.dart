import 'package:equatable/equatable.dart';

import '../../../domain/entities/todo.dart';

abstract class TodoFormEvent extends Equatable {
  const TodoFormEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodoForEdit extends TodoFormEvent {
  final String id;

  const LoadTodoForEdit(this.id);

  @override
  List<Object?> get props => [id];
}

class SubmitTodo extends TodoFormEvent {
  final String title;
  final String description;
  final DateTime? dueDate;
  final TodoPriority priority;
  final TodoCategory category;
  final List<String> tags;

  const SubmitTodo({
    required this.title,
    required this.description,
    this.dueDate,
    this.priority = TodoPriority.medium,
    this.category = TodoCategory.personal,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
    title,
    description,
    dueDate,
    priority,
    category,
    tags,
  ];
}

class UpdateExistingTodo extends TodoFormEvent {
  final Todo todo;

  const UpdateExistingTodo(this.todo);

  @override
  List<Object?> get props => [todo];
}

class ResetForm extends TodoFormEvent {}
