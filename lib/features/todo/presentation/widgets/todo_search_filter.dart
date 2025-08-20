import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/todo.dart';

class TodoSearchFilter extends StatefulWidget {
  final String searchQuery;
  final TodoCategory? selectedCategory;
  final TodoPriority? selectedPriority;
  final bool showCompleted;
  final bool showOverdue;
  final Function(String) onSearchChanged;
  final Function(TodoCategory?) onCategoryChanged;
  final Function(TodoPriority?) onPriorityChanged;
  final Function(bool) onShowCompletedChanged;
  final Function(bool) onShowOverdueChanged;
  final VoidCallback onClearFilters;

  const TodoSearchFilter({
    super.key,
    required this.searchQuery,
    this.selectedCategory,
    this.selectedPriority,
    required this.showCompleted,
    required this.showOverdue,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onShowCompletedChanged,
    required this.onShowOverdueChanged,
    required this.onClearFilters,
  });

  @override
  State<TodoSearchFilter> createState() => _TodoSearchFilterState();
}

class _TodoSearchFilterState extends State<TodoSearchFilter> {
  final _searchController = TextEditingController();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilters = widget.selectedCategory != null ||
        widget.selectedPriority != null ||
        !widget.showCompleted ||
        widget.showOverdue;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search todos...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                widget.onSearchChanged('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: widget.onSearchChanged,
                  ),
                ),
                const SizedBox(width: 8),
                // Filter toggle button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded ? Icons.filter_list_off : Icons.filter_list,
                    color: hasActiveFilters ? theme.colorScheme.primary : null,
                  ),
                  tooltip: 'Filters',
                ),
                if (hasActiveFilters)
                  IconButton(
                    onPressed: widget.onClearFilters,
                    icon: const Icon(Icons.clear_all),
                    tooltip: 'Clear filters',
                  ),
              ],
            ),
          ),

          // Expandable filters
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category filter
                  Text(
                    'Category',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: widget.selectedCategory == null,
                        onSelected: (selected) {
                          widget.onCategoryChanged(selected ? null : widget.selectedCategory);
                        },
                      ),
                      ...TodoCategory.values.map((category) {
                        final isSelected = widget.selectedCategory == category;
                        final color = AppTheme.getCategoryColor(category.name);
                        
                        return FilterChip(
                          label: Text(
                            category.name.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            widget.onCategoryChanged(selected ? category : null);
                          },
                          backgroundColor: color.withOpacity(0.1),
                          selectedColor: color,
                          checkmarkColor: Colors.white,
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Priority filter
                  Text(
                    'Priority',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: widget.selectedPriority == null,
                        onSelected: (selected) {
                          widget.onPriorityChanged(selected ? null : widget.selectedPriority);
                        },
                      ),
                      ...TodoPriority.values.map((priority) {
                        final isSelected = widget.selectedPriority == priority;
                        final color = AppTheme.getPriorityColor(priority.name);
                        
                        return FilterChip(
                          label: Text(
                            priority.name.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            widget.onPriorityChanged(selected ? priority : null);
                          },
                          backgroundColor: color.withOpacity(0.1),
                          selectedColor: color,
                          checkmarkColor: Colors.white,
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status filters
                  Text(
                    'Status',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Show Completed'),
                        selected: widget.showCompleted,
                        onSelected: widget.onShowCompletedChanged,
                      ),
                      FilterChip(
                        label: const Text('Show Overdue Only'),
                        selected: widget.showOverdue,
                        onSelected: widget.onShowOverdueChanged,
                        selectedColor: Colors.red.withOpacity(0.2),
                        checkmarkColor: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
