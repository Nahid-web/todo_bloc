import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/delete_todo.dart';
import '../../../domain/usecases/get_todo_by_id.dart';
import '../../../domain/usecases/update_todo.dart';
import 'todo_detail_event.dart';
import 'todo_detail_state.dart';

class TodoDetailBloc extends Bloc<TodoDetailEvent, TodoDetailState> {
  final GetTodoById getTodoById;
  final UpdateTodo updateTodo;
  final DeleteTodo deleteTodo;

  TodoDetailBloc({
    required this.getTodoById,
    required this.updateTodo,
    required this.deleteTodo,
  }) : super(TodoDetailInitial()) {
    on<LoadTodoDetail>(_onLoadTodoDetail);
    on<ToggleTodoCompletionDetail>(_onToggleTodoCompletion);
    on<DeleteTodoDetail>(_onDeleteTodo);
  }

  Future<void> _onLoadTodoDetail(
    LoadTodoDetail event,
    Emitter<TodoDetailState> emit,
  ) async {
    emit(TodoDetailLoading());
    final failureOrTodo = await getTodoById(GetTodoByIdParams(id: event.id));
    failureOrTodo.fold(
      (failure) => emit(const TodoDetailError('Failed to load todo')),
      (todo) => emit(TodoDetailLoaded(todo)),
    );
  }

  Future<void> _onToggleTodoCompletion(
    ToggleTodoCompletionDetail event,
    Emitter<TodoDetailState> emit,
  ) async {
    final updatedTodo = event.todo.copyWith(
      isCompleted: !event.todo.isCompleted,
      updatedAt: DateTime.now(),
    );

    final failureOrTodo = await updateTodo(UpdateTodoParams(todo: updatedTodo));
    failureOrTodo.fold(
      (failure) => emit(const TodoDetailError('Failed to update todo')),
      (todo) => emit(TodoDetailLoaded(todo)),
    );
  }

  Future<void> _onDeleteTodo(
    DeleteTodoDetail event,
    Emitter<TodoDetailState> emit,
  ) async {
    if (state is TodoDetailLoaded) {
      final currentTodo = (state as TodoDetailLoaded).todo;
      final failureOrSuccess = await deleteTodo(DeleteTodoParams(id: event.id));
      failureOrSuccess.fold(
        (failure) => emit(const TodoDetailError('Failed to delete todo')),
        (_) => emit(TodoDetailDeleted(currentTodo)),
      );
    }
  }
}
