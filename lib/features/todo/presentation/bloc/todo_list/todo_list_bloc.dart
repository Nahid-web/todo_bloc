import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/todo.dart';
import '../../../domain/usecases/delete_todo.dart';
import '../../../domain/usecases/get_todos.dart';
import '../../../domain/usecases/restore_todo.dart';
import '../../../domain/usecases/search_todos.dart';
import '../../../domain/usecases/update_todo.dart';
import 'todo_list_event.dart';
import 'todo_list_state.dart';

class TodoListBloc extends Bloc<TodoListEvent, TodoListState> {
  final GetTodos getTodos;
  final DeleteTodo deleteTodo;
  final SearchTodos searchTodos;
  final UpdateTodo updateTodo;
  final RestoreTodo restoreTodo;

  TodoListBloc({
    required this.getTodos,
    required this.deleteTodo,
    required this.searchTodos,
    required this.updateTodo,
    required this.restoreTodo,
  }) : super(TodoListInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<RefreshTodos>(_onRefreshTodos);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<SearchTodosEvent>(_onSearchTodos);
    on<ClearSearch>(_onClearSearch);
    on<ToggleTodoCompletion>(_onToggleTodoCompletion);
    on<RestoreTodoEvent>(_onRestoreTodo);
  }

  Future<void> _onLoadTodos(
    LoadTodos event,
    Emitter<TodoListState> emit,
  ) async {
    emit(TodoListLoading());
    final failureOrTodos = await getTodos(NoParams());
    failureOrTodos.fold(
      (failure) => emit(const TodoListError('Failed to load todos')),
      (todos) => emit(TodoListLoaded(todos: todos)),
    );
  }

  Future<void> _onRefreshTodos(
    RefreshTodos event,
    Emitter<TodoListState> emit,
  ) async {
    final failureOrTodos = await getTodos(NoParams());
    failureOrTodos.fold(
      (failure) => emit(const TodoListError('Failed to refresh todos')),
      (todos) {
        if (state is TodoListLoaded) {
          final currentState = state as TodoListLoaded;
          emit(currentState.copyWith(todos: todos));
        } else {
          emit(TodoListLoaded(todos: todos));
        }
      },
    );
  }

  Future<void> _onDeleteTodo(
    DeleteTodoEvent event,
    Emitter<TodoListState> emit,
  ) async {
    if (state is TodoListLoaded) {
      final currentState = state as TodoListLoaded;
      final todoToDelete = currentState.todos.firstWhere(
        (todo) => todo.id == event.id,
      );

      final failureOrSuccess = await deleteTodo(DeleteTodoParams(id: event.id));
      failureOrSuccess.fold(
        (failure) => emit(const TodoListError('Failed to delete todo')),
        (_) {
          final updatedTodos =
              currentState.todos.where((todo) => todo.id != event.id).toList();
          emit(TodoDeleted(deletedTodo: todoToDelete, todos: updatedTodos));
        },
      );
    }
  }

  Future<void> _onSearchTodos(
    SearchTodosEvent event,
    Emitter<TodoListState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(ClearSearch());
      return;
    }

    final failureOrTodos = await searchTodos(
      SearchTodosParams(query: event.query),
    );
    failureOrTodos.fold(
      (failure) => emit(const TodoListError('Failed to search todos')),
      (todos) => emit(
        TodoListLoaded(
          todos: todos,
          isSearching: true,
          searchQuery: event.query,
        ),
      ),
    );
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<TodoListState> emit,
  ) async {
    final failureOrTodos = await getTodos(NoParams());
    failureOrTodos.fold(
      (failure) => emit(const TodoListError('Failed to load todos')),
      (todos) => emit(TodoListLoaded(todos: todos)),
    );
  }

  Future<void> _onToggleTodoCompletion(
    ToggleTodoCompletion event,
    Emitter<TodoListState> emit,
  ) async {
    if (state is TodoListLoaded) {
      final currentState = state as TodoListLoaded;
      final todoIndex = currentState.todos.indexWhere(
        (todo) => todo.id == event.id,
      );

      if (todoIndex != -1) {
        final todo = currentState.todos[todoIndex];
        final updatedTodo = todo.copyWith(
          isCompleted: !todo.isCompleted,
          updatedAt: DateTime.now(),
        );

        final failureOrTodo = await updateTodo(
          UpdateTodoParams(todo: updatedTodo),
        );
        failureOrTodo.fold(
          (failure) => emit(const TodoListError('Failed to update todo')),
          (todo) {
            final updatedTodos = List<Todo>.from(currentState.todos);
            updatedTodos[todoIndex] = todo;
            emit(currentState.copyWith(todos: updatedTodos));
          },
        );
      }
    }
  }

  Future<void> _onRestoreTodo(
    RestoreTodoEvent event,
    Emitter<TodoListState> emit,
  ) async {
    final failureOrTodo = await restoreTodo(
      RestoreTodoParams(todo: event.todo),
    );
    failureOrTodo.fold(
      (failure) => emit(const TodoListError('Failed to restore todo')),
      (_) {
        // Refresh the todo list after restoring
        add(RefreshTodos());
      },
    );
  }
}
