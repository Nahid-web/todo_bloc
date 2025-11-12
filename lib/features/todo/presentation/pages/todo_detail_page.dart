import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../bloc/todo_detail/todo_detail_bloc.dart';
import '../bloc/todo_detail/todo_detail_event.dart';
import '../bloc/todo_detail/todo_detail_state.dart';
import 'add_edit_todo_page.dart';

class TodoDetailPage extends StatelessWidget {
  final String todoId;

  const TodoDetailPage({super.key, required this.todoId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TodoDetailBloc>()..add(LoadTodoDetail(todoId)),
      child: const TodoDetailView(),
    );
  }
}

class TodoDetailView extends StatelessWidget {
  const TodoDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy \'at\' HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details'),
        actions: [
          BlocBuilder<TodoDetailBloc, TodoDetailState>(
            builder: (context, state) {
              if (state is TodoDetailLoaded) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _navigateToEdit(context, state.todo.id);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(
                          context,
                          state.todo.id,
                          state.todo.title,
                        );
                        break;
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete'),
                          ),
                        ),
                      ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<TodoDetailBloc, TodoDetailState>(
        listener: (context, state) {
          if (state is TodoDetailDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Todo "${state.deletedTodo.title}" deleted'),
              ),
            );
            context.pop(true);
          } else if (state is TodoDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TodoDetailLoading) {
            return const LoadingWidget();
          } else if (state is TodoDetailLoaded) {
            final todo = state.todo;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  todo.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                    decoration:
                                        todo.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                  ),
                                ),
                              ),
                              Checkbox(
                                value: todo.isCompleted,
                                onChanged: (_) {
                                  context.read<TodoDetailBloc>().add(
                                    ToggleTodoCompletionDetail(todo),
                                  );
                                },
                              ),
                            ],
                          ),
                          if (todo.description.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              todo.description,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Details',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            context,
                            'Status',
                            todo.isCompleted ? 'Completed' : 'Pending',
                            icon:
                                todo.isCompleted
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                            iconColor:
                                todo.isCompleted ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            context,
                            'Created',
                            dateFormat.format(todo.createdAt),
                            icon: Icons.access_time,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            context,
                            'Last Updated',
                            dateFormat.format(todo.updatedAt),
                            icon: Icons.update,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is TodoDetailError) {
            return MessageDisplay(message: state.message);
          }

          return const MessageDisplay(message: 'Something went wrong');
        },
      ),
      floatingActionButton: BlocBuilder<TodoDetailBloc, TodoDetailState>(
        builder: (context, state) {
          if (state is TodoDetailLoaded) {
            return FloatingActionButton(
              onPressed: () => _navigateToEdit(context, state.todo.id),
              child: const Icon(Icons.edit),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: iconColor ?? Theme.of(context).disabledColor,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  void _navigateToEdit(BuildContext context, String todoId) async {
    final result = await context.push('/todos/edit/$todoId');
    if (result == true && context.mounted) {
      context.read<TodoDetailBloc>().add(LoadTodoDetail(todoId));
    }
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
                context.read<TodoDetailBloc>().add(DeleteTodoDetail(todoId));
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
