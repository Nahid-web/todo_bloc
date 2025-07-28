import 'package:equatable/equatable.dart';

import '../../../domain/entities/todo.dart';

abstract class TodoFormState extends Equatable {
  const TodoFormState();

  @override
  List<Object> get props => [];
}

class TodoFormInitial extends TodoFormState {}

class TodoFormLoading extends TodoFormState {}

class TodoFormLoaded extends TodoFormState {
  final Todo? todo;
  final bool isEditing;

  const TodoFormLoaded({
    this.todo,
    this.isEditing = false,
  });

  @override
  List<Object> get props => [todo ?? '', isEditing];
}

class TodoFormSubmitting extends TodoFormState {}

class TodoFormSuccess extends TodoFormState {
  final Todo todo;
  final bool wasEditing;

  const TodoFormSuccess({
    required this.todo,
    required this.wasEditing,
  });

  @override
  List<Object> get props => [todo, wasEditing];
}

class TodoFormError extends TodoFormState {
  final String message;

  const TodoFormError(this.message);

  @override
  List<Object> get props => [message];
}
