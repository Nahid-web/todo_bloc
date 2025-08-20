import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/todo.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TodoCard({
    super.key,
    required this.todo,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = AppTheme.getPriorityColor(todo.priority.name);
    final categoryColor = AppTheme.getCategoryColor(todo.category.name);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and priority
              Row(
                children: [
                  // Completion checkbox
                  Checkbox(
                    value: todo.isCompleted,
                    onChanged: (_) => onToggleComplete?.call(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Title and priority
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration:
                                todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                            color:
                                todo.isCompleted
                                    ? theme.colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    )
                                    : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (todo.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            todo.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                              decoration:
                                  todo.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Priority indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tags and category
              if (todo.tags.isNotEmpty ||
                  todo.category != TodoCategory.personal) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    // Category chip
                    if (todo.category != TodoCategory.personal)
                      Chip(
                        label: Text(
                          todo.category.name.toUpperCase(),
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: categoryColor.withValues(alpha: 0.2),
                        side: BorderSide(color: categoryColor, width: 1),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),

                    // Tag chips
                    ...todo.tags
                        .take(3)
                        .map(
                          (tag) => Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 10),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),

                    if (todo.tags.length > 3)
                      Chip(
                        label: Text(
                          '+${todo.tags.length - 3}',
                          style: const TextStyle(fontSize: 10),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Footer with due date and actions
              Row(
                children: [
                  // Due date
                  if (todo.dueDate != null) ...[
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color:
                          todo.isOverdue
                              ? Colors.red
                              : todo.isDueSoon
                              ? Colors.orange
                              : theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(todo.dueDate!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            todo.isOverdue
                                ? Colors.red
                                : todo.isDueSoon
                                ? Colors.orange
                                : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                        fontWeight:
                            todo.isOverdue || todo.isDueSoon
                                ? FontWeight.w600
                                : null,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          iconSize: 20,
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Edit',
                        ),
                      if (onDelete != null)
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          iconSize: 20,
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Delete',
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
