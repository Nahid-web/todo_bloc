import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getTodos();
  Future<TodoModel?> getTodoById(String id);
  Future<TodoModel> addTodo(TodoModel todo);
  Future<TodoModel> updateTodo(TodoModel todo);
  Future<void> deleteTodo(String id);
  Future<List<TodoModel>> searchTodos(String query);
}

const String cachedTodos = 'CACHED_TODOS';

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final SharedPreferences sharedPreferences;

  TodoLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<TodoModel>> getTodos() async {
    final jsonString = sharedPreferences.getString(cachedTodos);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => TodoModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  @override
  Future<TodoModel?> getTodoById(String id) async {
    final todos = await getTodos();
    try {
      return todos.firstWhere((todo) => todo.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<TodoModel> addTodo(TodoModel todo) async {
    final todos = await getTodos();
    todos.add(todo);
    await _saveTodos(todos);
    return todo;
  }

  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    final todos = await getTodos();
    final index = todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      todos[index] = todo;
      await _saveTodos(todos);
      return todo;
    } else {
      throw Exception('Todo not found');
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    final todos = await getTodos();
    todos.removeWhere((todo) => todo.id == id);
    await _saveTodos(todos);
  }

  @override
  Future<List<TodoModel>> searchTodos(String query) async {
    final todos = await getTodos();
    final lowercaseQuery = query.toLowerCase();
    return todos
        .where(
          (todo) =>
              todo.title.toLowerCase().contains(lowercaseQuery) ||
              todo.description.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  Future<void> _saveTodos(List<TodoModel> todos) async {
    final jsonString = json.encode(todos.map((todo) => todo.toJson()).toList());
    await sharedPreferences.setString(cachedTodos, jsonString);
  }
}
