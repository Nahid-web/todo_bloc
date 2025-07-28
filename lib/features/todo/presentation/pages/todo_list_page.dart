import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../bloc/todo_list/todo_list_bloc.dart';
import '../bloc/todo_list/todo_list_event.dart';
import '../bloc/todo_list/todo_list_state.dart';
import '../widgets/todo_item.dart';
import 'add_edit_todo_page.dart';
import 'todo_detail_page.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TodoListBloc>()..add(LoadTodos()),
      child: const TodoListView(),
    );
  }
}

class TodoListView extends StatefulWidget {
  const TodoListView({super.key});

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search todos...',
                    border: InputBorder.none,
                  ),
                  onChanged: (query) {
                    if (query.isEmpty) {
                      context.read<TodoListBloc>().add(ClearSearch());
                    } else {
                      context.read<TodoListBloc>().add(SearchTodosEvent(query));
                    }
                  },
                )
                : const Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<TodoListBloc>().add(ClearSearch());
                }
              });
            },
          ),
        ],
      ),
      body: BlocConsumer<TodoListBloc, TodoListState>(
        listener: (context, state) {
          if (state is TodoDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Todo "${state.deletedTodo.title}" deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    context.read<TodoListBloc>().add(
                      RestoreTodoEvent(state.deletedTodo),
                    );
                  },
                ),
              ),
            );
          } else if (state is TodoListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TodoListLoading) {
            return const LoadingWidget();
          } else if (state is TodoListLoaded || state is TodoDeleted) {
            final todos =
                state is TodoListLoaded
                    ? state.todos
                    : (state as TodoDeleted).todos;

            if (todos.isEmpty) {
              return MessageDisplay(
                message:
                    state is TodoListLoaded && state.isSearching
                        ? 'No todos found for "${state.searchQuery}"'
                        : 'No todos yet. Add your first todo!',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TodoListBloc>().add(RefreshTodos());
              },
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return TodoItem(
                    todo: todo,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TodoDetailPage(todoId: todo.id),
                        ),
                      );
                    },
                    onToggle: () {
                      context.read<TodoListBloc>().add(
                        ToggleTodoCompletion(todo.id),
                      );
                    },
                    onDelete: () {
                      _showDeleteConfirmation(context, todo.id, todo.title);
                    },
                  );
                },
              ),
            );
          } else if (state is TodoListError) {
            return MessageDisplay(message: state.message);
          }

          return const MessageDisplay(message: 'Something went wrong');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddEditTodoPage()));
          if (result == true && context.mounted) {
            context.read<TodoListBloc>().add(RefreshTodos());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String todoId,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Todo'),
          content: Text('Are you sure you want to delete "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<TodoListBloc>().add(DeleteTodoEvent(todoId));
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
