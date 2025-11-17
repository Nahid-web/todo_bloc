import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_bloc/core/di/injector.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../todo/domain/entities/todo.dart';
import '../../../todo/presentation/bloc/todo_list/todo_list_bloc.dart';
import '../../../todo/presentation/bloc/todo_list/todo_list_event.dart';
import '../../../todo/presentation/bloc/todo_list/todo_list_state.dart';
import '../../../todo/presentation/pages/add_edit_todo_page.dart';
import '../../../todo/presentation/widgets/todo_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TodoListBloc>()..add(LoadTodos()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditTodoPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add Todo',
          ),
        ],
      ),
      body: BlocBuilder<TodoListBloc, TodoListState>(
        builder: (context, state) {
          if (state is TodoListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TodoListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading todos',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TodoListBloc>().add(LoadTodos());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TodoListLoaded) {
            final todos = state.todos.where((todo) => !todo.isDeleted).toList();
            final completedTodos =
                todos.where((todo) => todo.isCompleted).length;
            final pendingTodos =
                todos.where((todo) => !todo.isCompleted).length;
            final overdueTodos = todos.where((todo) => todo.isOverdue).length;
            final dueSoonTodos = todos.where((todo) => todo.isDueSoon).length;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TodoListBloc>().add(LoadTodos());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Cards
                    _buildStatisticsSection(
                      context,
                      totalTodos: todos.length,
                      completedTodos: completedTodos,
                      pendingTodos: pendingTodos,
                      overdueTodos: overdueTodos,
                      dueSoonTodos: dueSoonTodos,
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActionsSection(context),

                    const SizedBox(height: 24),

                    // Recent Todos
                    _buildRecentTodosSection(context, todos),

                    const SizedBox(height: 24),

                    // Overdue Todos
                    if (overdueTodos > 0) ...[
                      _buildOverdueTodosSection(
                        context,
                        todos.where((todo) => todo.isOverdue).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Due Soon Todos
                    if (dueSoonTodos > 0) ...[
                      _buildDueSoonTodosSection(
                        context,
                        todos.where((todo) => todo.isDueSoon).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('No todos found'));
        },
      ),
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context, {
    required int totalTodos,
    required int completedTodos,
    required int pendingTodos,
    required int overdueTodos,
    required int dueSoonTodos,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Total',
                value: totalTodos.toString(),
                icon: Icons.list_alt,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Completed',
                value: completedTodos.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Pending',
                value: pendingTodos.toString(),
                icon: Icons.pending,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Overdue',
                value: overdueTodos.toString(),
                icon: Icons.warning,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                title: 'Add Todo',
                icon: Icons.add,
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddEditTodoPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                title: 'View All',
                icon: Icons.list,
                color: Colors.green,
                onTap: () {
                  // Navigate to all todos
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTodosSection(BuildContext context, List<Todo> todos) {
    final recentTodos =
        todos.where((todo) => !todo.isCompleted).take(3).toList();

    if (recentTodos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Todos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all todos
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recentTodos.map((todo) => TodoCard(
              todo: todo,
              onToggleComplete: () {
                // Handle toggle complete
              },
            )),
      ],
    );
  }

  Widget _buildOverdueTodosSection(
      BuildContext context, List<Todo> overdueTodos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overdue Todos',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
        ),
        const SizedBox(height: 8),
        ...overdueTodos.take(3).map((todo) => TodoCard(
              todo: todo,
              onToggleComplete: () {
                // Handle toggle complete
              },
            )),
      ],
    );
  }

  Widget _buildDueSoonTodosSection(
      BuildContext context, List<Todo> dueSoonTodos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Soon',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
        ),
        const SizedBox(height: 8),
        ...dueSoonTodos.take(3).map((todo) => TodoCard(
              todo: todo,
              onToggleComplete: () {
                // Handle toggle complete
              },
            )),
      ],
    );
  }
}
