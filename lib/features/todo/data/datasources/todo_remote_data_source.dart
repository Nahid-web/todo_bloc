import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos(String userId);
  Future<TodoModel?> getTodoById(String userId, String id);
  Future<TodoModel> addTodo(String userId, TodoModel todo);
  Future<TodoModel> updateTodo(String userId, TodoModel todo);
  Future<void> deleteTodo(String userId, String id);
  Future<List<TodoModel>> searchTodos(String userId, String query);
  Stream<List<TodoModel>> getTodosStream(String userId);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  TodoRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  CollectionReference _getUserTodosCollection(String userId) {
    return firestore.collection('users').doc(userId).collection('todos');
  }

  @override
  Future<List<TodoModel>> getTodos(String userId) async {
    try {
      final querySnapshot = await _getUserTodosCollection(userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TodoModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get todos: $e');
    }
  }

  @override
  Future<TodoModel?> getTodoById(String userId, String id) async {
    try {
      final doc = await _getUserTodosCollection(userId).doc(id).get();
      
      if (doc.exists) {
        return TodoModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get todo: $e');
    }
  }

  @override
  Future<TodoModel> addTodo(String userId, TodoModel todo) async {
    try {
      final docRef = _getUserTodosCollection(userId).doc(todo.id);
      await docRef.set(todo.toFirestore());
      
      final doc = await docRef.get();
      return TodoModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to add todo: $e');
    }
  }

  @override
  Future<TodoModel> updateTodo(String userId, TodoModel todo) async {
    try {
      final docRef = _getUserTodosCollection(userId).doc(todo.id);
      await docRef.update(todo.toFirestore());
      
      final doc = await docRef.get();
      return TodoModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to update todo: $e');
    }
  }

  @override
  Future<void> deleteTodo(String userId, String id) async {
    try {
      await _getUserTodosCollection(userId).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }

  @override
  Future<List<TodoModel>> searchTodos(String userId, String query) async {
    try {
      final querySnapshot = await _getUserTodosCollection(userId)
          .orderBy('createdAt', descending: true)
          .get();

      final todos = querySnapshot.docs
          .map((doc) => TodoModel.fromFirestore(doc))
          .toList();

      // Filter locally since Firestore doesn't support full-text search
      final lowercaseQuery = query.toLowerCase();
      return todos
          .where((todo) =>
              todo.title.toLowerCase().contains(lowercaseQuery) ||
              todo.description.toLowerCase().contains(lowercaseQuery))
          .toList();
    } catch (e) {
      throw Exception('Failed to search todos: $e');
    }
  }

  @override
  Stream<List<TodoModel>> getTodosStream(String userId) {
    return _getUserTodosCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TodoModel.fromFirestore(doc))
            .toList());
  }
}
