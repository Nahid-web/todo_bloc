import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_form/todo_form_bloc.dart';
import '../bloc/todo_form/todo_form_event.dart';
import '../bloc/todo_form/todo_form_state.dart';

class AddEditTodoPage extends StatelessWidget {
  final String? todoId;

  const AddEditTodoPage({super.key, this.todoId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<TodoFormBloc>();
        if (todoId != null) {
          bloc.add(LoadTodoForEdit(todoId!));
        }
        return bloc;
      },
      child: AddEditTodoView(isEditing: todoId != null),
    );
  }
}

class AddEditTodoView extends StatefulWidget {
  final bool isEditing;

  const AddEditTodoView({super.key, required this.isEditing});

  @override
  State<AddEditTodoView> createState() => _AddEditTodoViewState();
}

class _AddEditTodoViewState extends State<AddEditTodoView> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  DateTime? _selectedDueDate;
  TodoPriority _selectedPriority = TodoPriority.medium;
  TodoCategory _selectedCategory = TodoCategory.personal;
  List<String> _tags = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Todo' : 'Add Todo'),
        actions: [
          BlocBuilder<TodoFormBloc, TodoFormState>(
            builder: (context, state) {
              return TextButton(
                onPressed: state is TodoFormSubmitting ? null : _submitForm,
                child: Text(
                  widget.isEditing ? 'Update' : 'Save',
                  style: TextStyle(
                    color: state is TodoFormSubmitting
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TodoFormBloc, TodoFormState>(
        listener: (context, state) {
          if (state is TodoFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.wasEditing
                      ? 'Todo updated successfully'
                      : 'Todo added successfully',
                ),
              ),
            );
            context.pop(true);
          } else if (state is TodoFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is TodoFormLoaded && state.todo != null) {
            _titleController.text = state.todo!.title;
            _descriptionController.text = state.todo!.description;
            setState(() {
              _selectedDueDate = state.todo!.dueDate;
              _selectedPriority = state.todo!.priority;
              _selectedCategory = state.todo!.category;
              _tags = List.from(state.todo!.tags);
              _tagsController.text = _tags.join(', ');
            });
          }
        },
        builder: (context, state) {
          if (state is TodoFormLoading) {
            return const LoadingWidget();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title field
                  FormBuilderTextField(
                    name: 'title',
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      hintText: 'Enter todo title',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.maxLength(100),
                    ]),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Description field
                  FormBuilderTextField(
                    name: 'description',
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter todo description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 16),

                  // Due date picker
                  FormBuilderField<DateTime?>(
                    name: 'dueDate',
                    initialValue: _selectedDueDate,
                    builder: (field) {
                      return InkWell(
                        onTap: () => _selectDueDate(context, field),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Due Date',
                            prefixIcon: Icon(Icons.calendar_today),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                          child: Text(
                            _selectedDueDate != null
                                ? DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(_selectedDueDate!)
                                : 'Select due date',
                            style: TextStyle(
                              color: _selectedDueDate != null
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Priority selector
                  Text(
                    'Priority',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: TodoPriority.values.map((priority) {
                      final isSelected = _selectedPriority == priority;
                      final color = AppTheme.getPriorityColor(
                        priority.name,
                      );

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
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                        backgroundColor: color.withValues(alpha: 0.1),
                        selectedColor: color,
                        checkmarkColor: Colors.white,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Category selector
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TodoCategory.values.map((category) {
                      final isSelected = _selectedCategory == category;
                      final color = AppTheme.getCategoryColor(
                        category.name,
                      );

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
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: color.withValues(alpha: 0.1),
                        selectedColor: color,
                        checkmarkColor: Colors.white,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Tags field
                  FormBuilderTextField(
                    name: 'tags',
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags',
                      hintText: 'Enter tags separated by commas',
                      prefixIcon: Icon(Icons.tag),
                      helperText: 'Separate multiple tags with commas',
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        _tags = value
                            .split(',')
                            .map((tag) => tag.trim())
                            .where((tag) => tag.isNotEmpty)
                            .toList();
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  if (state is TodoFormSubmitting)
                    const Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: Icon(widget.isEditing ? Icons.save : Icons.add),
                        label: Text(
                          widget.isEditing ? 'Update Todo' : 'Create Todo',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDueDate(
    BuildContext context,
    FormFieldState<DateTime?> field,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDueDate = selectedDate;
      });
      field.didChange(selectedDate);
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();

      final state = context.read<TodoFormBloc>().state;
      if (state is TodoFormLoaded && state.isEditing && state.todo != null) {
        final updatedTodo = state.todo!.copyWith(
          title: title,
          description: description,
          dueDate: _selectedDueDate,
          priority: _selectedPriority,
          category: _selectedCategory,
          tags: _tags,
          updatedAt: DateTime.now(),
        );
        context.read<TodoFormBloc>().add(UpdateExistingTodo(updatedTodo));
      } else {
        context.read<TodoFormBloc>().add(
              SubmitTodo(
                title: title,
                description: description,
                dueDate: _selectedDueDate,
                priority: _selectedPriority,
                category: _selectedCategory,
                tags: _tags,
              ),
            );
      }
    }
  }
}
