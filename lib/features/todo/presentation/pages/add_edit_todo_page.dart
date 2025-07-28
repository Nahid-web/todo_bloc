import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/loading_widget.dart';
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
            Navigator.of(context).pop(true);
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
          }
        },
        builder: (context, state) {
          if (state is TodoFormLoading) {
            return const LoadingWidget();
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'title',
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(1),
                    ]),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'description',
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  if (state is TodoFormSubmitting)
                    const CircularProgressIndicator()
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(widget.isEditing ? 'Update Todo' : 'Add Todo'),
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

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();

      final state = context.read<TodoFormBloc>().state;
      if (state is TodoFormLoaded && state.isEditing && state.todo != null) {
        final updatedTodo = state.todo!.copyWith(
          title: title,
          description: description,
        );
        context.read<TodoFormBloc>().add(UpdateExistingTodo(updatedTodo));
      } else {
        context.read<TodoFormBloc>().add(
              SubmitTodo(title: title, description: description),
            );
      }
    }
  }
}
