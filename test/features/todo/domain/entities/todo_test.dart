import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/features/todo/domain/entities/todo.dart';

void main() {
  group('Todo Entity', () {
    late Todo testTodo;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 1, 15, 10, 30);
      testTodo = Todo(
        id: 'test-id-123',
        title: 'Test Todo',
        description: 'Test Description',
        isCompleted: false,
        createdAt: testDate,
        updatedAt: testDate,
        userId: 'user-123',
        priority: TodoPriority.medium,
        category: TodoCategory.work,
        dueDate: testDate.add(const Duration(days: 7)),
        tags: ['work', 'important'],
        isDeleted: false,
      );
    });

    group('Constructor', () {
      test('should create Todo with all properties', () {
        expect(testTodo.id, 'test-id-123');
        expect(testTodo.title, 'Test Todo');
        expect(testTodo.description, 'Test Description');
        expect(testTodo.isCompleted, false);
        expect(testTodo.createdAt, testDate);
        expect(testTodo.updatedAt, testDate);
        expect(testTodo.userId, 'user-123');
        expect(testTodo.priority, TodoPriority.medium);
        expect(testTodo.category, TodoCategory.work);
        expect(testTodo.dueDate, testDate.add(const Duration(days: 7)));
        expect(testTodo.tags, ['work', 'important']);
        expect(testTodo.isDeleted, false);
      });

      test('should create Todo with minimal required properties', () {
        final minimalTodo = Todo(
          id: 'minimal-id',
          title: 'Minimal Todo',
          description: 'Minimal Description',
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
          userId: 'user-123',
        );

        expect(minimalTodo.id, 'minimal-id');
        expect(minimalTodo.title, 'Minimal Todo');
        expect(minimalTodo.description, 'Minimal Description');
        expect(minimalTodo.isCompleted, false);
        expect(minimalTodo.priority, TodoPriority.medium);
        expect(minimalTodo.category, TodoCategory.personal);
        expect(minimalTodo.dueDate, isNull);
        expect(minimalTodo.tags, isEmpty);
        expect(minimalTodo.isDeleted, false);
        expect(minimalTodo.deletedAt, isNull);
      });
    });

    group('copyWith', () {
      test('should create new Todo with updated properties', () {
        final updatedTodo = testTodo.copyWith(
          title: 'Updated Title',
          isCompleted: true,
          priority: TodoPriority.urgent,
        );

        expect(updatedTodo.id, testTodo.id);
        expect(updatedTodo.title, 'Updated Title');
        expect(updatedTodo.isCompleted, true);
        expect(updatedTodo.priority, TodoPriority.urgent);
        expect(updatedTodo.category, testTodo.category);
        expect(updatedTodo.description, testTodo.description);
      });

      test('should preserve original properties when not specified', () {
        final updatedTodo = testTodo.copyWith(title: 'New Title');

        expect(updatedTodo.description, testTodo.description);
        expect(updatedTodo.isCompleted, testTodo.isCompleted);
        expect(updatedTodo.priority, testTodo.priority);
        expect(updatedTodo.category, testTodo.category);
        expect(updatedTodo.userId, testTodo.userId);
      });
    });

    group('Utility Methods', () {
      test('isOverdue should return true when due date is in the past', () {
        final overdueTodo = testTodo.copyWith(
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(overdueTodo.isOverdue, true);
      });

      test('isOverdue should return false when due date is in the future', () {
        final futureTodo = testTodo.copyWith(
          dueDate: DateTime.now().add(const Duration(days: 1)),
        );

        expect(futureTodo.isOverdue, false);
      });

      test('isOverdue should return false when no due date is set', () {
        final noDueDateTodo = Todo(
          id: 'no-due-date-id',
          title: 'No Due Date Todo',
          description: 'No due date description',
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
          userId: 'user-123',
          // dueDate is not set (null)
        );

        expect(noDueDateTodo.isOverdue, false);
      });

      test('isDueSoon should return true when due date is within 24 hours', () {
        final dueSoonTodo = testTodo.copyWith(
          dueDate: DateTime.now().add(const Duration(hours: 12)),
        );

        expect(dueSoonTodo.isDueSoon, true);
      });

      test(
        'isDueSoon should return false when due date is more than 24 hours away',
        () {
          final notDueSoonTodo = testTodo.copyWith(
            dueDate: DateTime.now().add(const Duration(days: 2)),
          );

          expect(notDueSoonTodo.isDueSoon, false);
        },
      );

      test('isDueSoon should return false when no due date is set', () {
        final noDueDateTodo = Todo(
          id: 'no-due-date-id-2',
          title: 'No Due Date Todo 2',
          description: 'No due date description 2',
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
          userId: 'user-123',
          // dueDate is not set (null)
        );

        expect(noDueDateTodo.isDueSoon, false);
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        final todo1 = Todo(
          id: 'same-id',
          title: 'Same Title',
          description: 'Same Description',
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
          userId: 'user-123',
        );

        final todo2 = Todo(
          id: 'same-id',
          title: 'Same Title',
          description: 'Same Description',
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
          userId: 'user-123',
        );

        expect(todo1, equals(todo2));
        expect(todo1.hashCode, equals(todo2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final todo1 = testTodo;
        final todo2 = testTodo.copyWith(title: 'Different Title');

        expect(todo1, isNot(equals(todo2)));
        expect(todo1.hashCode, isNot(equals(todo2.hashCode)));
      });
    });

    group('Enums', () {
      test('TodoPriority should have correct values', () {
        expect(TodoPriority.values, [
          TodoPriority.low,
          TodoPriority.medium,
          TodoPriority.high,
          TodoPriority.urgent,
        ]);
      });

      test('TodoCategory should have correct values', () {
        expect(TodoCategory.values, [
          TodoCategory.personal,
          TodoCategory.work,
          TodoCategory.shopping,
          TodoCategory.health,
          TodoCategory.education,
          TodoCategory.other,
        ]);
      });
    });
  });
}
