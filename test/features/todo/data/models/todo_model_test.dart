import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/features/todo/data/models/todo_model.dart';
import 'package:todo_bloc/features/todo/domain/entities/todo.dart';

void main() {
  group('TodoModel', () {
    final testTodoModel = TodoModel(
      id: '1',
      title: 'Test Todo',
      description: 'Test Description',
      isCompleted: false,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    test('should be a subclass of Todo entity', () {
      // assert
      expect(testTodoModel, isA<Todo>());
    });

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': '1',
          'title': 'Test Todo',
          'description': 'Test Description',
          'isCompleted': false,
          'createdAt': '2023-01-01T00:00:00.000',
          'updatedAt': '2023-01-01T00:00:00.000',
        };

        // act
        final result = TodoModel.fromJson(jsonMap);

        // assert
        expect(result, testTodoModel);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // act
        final result = testTodoModel.toJson();

        // assert
        final expectedMap = {
          'id': '1',
          'title': 'Test Todo',
          'description': 'Test Description',
          'isCompleted': false,
          'createdAt': '2023-01-01T00:00:00.000',
          'updatedAt': '2023-01-01T00:00:00.000',
        };
        expect(result, expectedMap);
      });
    });

    group('fromEntity', () {
      test('should return a TodoModel from Todo entity', () {
        // arrange
        final todo = Todo(
          id: '1',
          title: 'Test Todo',
          description: 'Test Description',
          isCompleted: false,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        // act
        final result = TodoModel.fromEntity(todo);

        // assert
        expect(result, testTodoModel);
      });
    });

    group('copyWith', () {
      test('should return a new instance with updated values', () {
        // act
        final result = testTodoModel.copyWith(
          title: 'Updated Title',
          isCompleted: true,
        );

        // assert
        expect(result.id, testTodoModel.id);
        expect(result.title, 'Updated Title');
        expect(result.description, testTodoModel.description);
        expect(result.isCompleted, true);
        expect(result.createdAt, testTodoModel.createdAt);
        expect(result.updatedAt, testTodoModel.updatedAt);
      });
    });
  });
}
