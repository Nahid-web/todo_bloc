import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/todo.dart';
import '../../../domain/usecases/add_todo.dart';
import '../../../domain/usecases/get_todo_by_id.dart';
import '../../../domain/usecases/update_todo.dart';
import 'todo_form_event.dart';
import 'todo_form_state.dart';

class TodoFormBloc extends Bloc<TodoFormEvent, TodoFormState> {
  final AddTodo addTodo;
  final UpdateTodo updateTodo;
  final GetTodoById getTodoById;

  TodoFormBloc({
    required this.addTodo,
    required this.updateTodo,
    required this.getTodoById,
  }) : super(TodoFormInitial()) {
    on<LoadTodoForEdit>(_onLoadTodoForEdit);
    on<SubmitTodo>(_onSubmitTodo);
    on<UpdateExistingTodo>(_onUpdateExistingTodo);
    on<ResetForm>(_onResetForm);
  }

  Future<void> _onLoadTodoForEdit(
    LoadTodoForEdit event,
    Emitter<TodoFormState> emit,
  ) async {
    emit(TodoFormLoading());
    final failureOrTodo = await getTodoById(GetTodoByIdParams(id: event.id));
    failureOrTodo.fold(
      (failure) => emit(const TodoFormError('Failed to load todo')),
      (todo) => emit(TodoFormLoaded(todo: todo, isEditing: true)),
    );
  }

  Future<void> _onSubmitTodo(
    SubmitTodo event,
    Emitter<TodoFormState> emit,
  ) async {
    if (event.title.trim().isEmpty) {
      emit(const TodoFormError('Title cannot be empty'));
      return;
    }

    emit(TodoFormSubmitting());

    final now = DateTime.now();
    final todo = Todo(
      id: const Uuid().v4(),
      title: event.title.trim(),
      description: event.description.trim(),
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    final failureOrTodo = await addTodo(AddTodoParams(todo: todo));
    failureOrTodo.fold(
      (failure) => emit(const TodoFormError('Failed to add todo')),
      (todo) => emit(TodoFormSuccess(todo: todo, wasEditing: false)),
    );
  }

  Future<void> _onUpdateExistingTodo(
    UpdateExistingTodo event,
    Emitter<TodoFormState> emit,
  ) async {
    emit(TodoFormSubmitting());

    final updatedTodo = event.todo.copyWith(
      updatedAt: DateTime.now(),
    );

    final failureOrTodo = await updateTodo(UpdateTodoParams(todo: updatedTodo));
    failureOrTodo.fold(
      (failure) => emit(const TodoFormError('Failed to update todo')),
      (todo) => emit(TodoFormSuccess(todo: todo, wasEditing: true)),
    );
  }

  void _onResetForm(
    ResetForm event,
    Emitter<TodoFormState> emit,
  ) {
    emit(TodoFormInitial());
  }
}
