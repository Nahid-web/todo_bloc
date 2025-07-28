import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/features/todo/domain/entities/todo.dart';

void main() {
  group('Todo Entity', () {
    final testTodo = Todo(
      id: '1',
      title: 'Test Todo',
      description: 'Test Description',
      isCompleted: false,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    test('should be a subclass of Equatable', () {
      // assert
      expect(testTodo, isA<Todo>());
    });

    test('should return correct props', () {
      // assert
      expect(testTodo.props, [
        '1',
        'Test Todo',
        'Test Description',
        false,
        DateTime(2023, 1, 1),
        DateTime(2023, 1, 1),
      ]);
    });

    test('copyWith should return a new instance with updated values', () {
      // act
      final updatedTodo = testTodo.copyWith(
        title: 'Updated Title',
        isCompleted: true,
      );

      // assert
      expect(updatedTodo.id, testTodo.id);
      expect(updatedTodo.title, 'Updated Title');
      expect(updatedTodo.description, testTodo.description);
      expect(updatedTodo.isCompleted, true);
      expect(updatedTodo.createdAt, testTodo.createdAt);
      expect(updatedTodo.updatedAt, testTodo.updatedAt);
    });

    test('toString should return correct string representation', () {
      // act
      final result = testTodo.toString();

      // assert
      expect(result, contains('Test Todo'));
      expect(result, contains('Test Description'));
      expect(result, contains('false'));
    });
  });
}
