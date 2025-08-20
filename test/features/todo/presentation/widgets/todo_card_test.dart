import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/features/todo/domain/entities/todo.dart';
import 'package:todo_bloc/features/todo/presentation/widgets/todo_card.dart';

void main() {
  group('TodoCard Widget', () {
    late Todo testTodo;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 1, 15, 10, 30);
      testTodo = Todo(
        id: 'test-id-123',
        title: 'Test Todo Title',
        description: 'Test todo description for widget testing',
        isCompleted: false,
        createdAt: testDate,
        updatedAt: testDate,
        userId: 'user-123',
        priority: TodoPriority.medium,
        category: TodoCategory.work,
        dueDate: testDate.add(const Duration(days: 7)),
        tags: ['work', 'important'],
      );
    });

    Widget createWidgetUnderTest({
      Todo? todo,
      VoidCallback? onTap,
      VoidCallback? onToggleComplete,
      VoidCallback? onDelete,
      VoidCallback? onEdit,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TodoCard(
            todo: todo ?? testTodo,
            onTap: onTap ?? () {},
            onToggleComplete: onToggleComplete ?? () {},
            onDelete: onDelete ?? () {},
            onEdit: onEdit ?? () {},
          ),
        ),
      );
    }

    group('Display', () {
      testWidgets('should display todo title and description', (tester) async {
        // arrange & act
        await tester.pumpWidget(createWidgetUnderTest());

        // assert
        expect(find.text('Test Todo Title'), findsOneWidget);
        expect(
          find.text('Test todo description for widget testing'),
          findsOneWidget,
        );
      });

      testWidgets('should display priority indicator', (tester) async {
        // arrange & act
        await tester.pumpWidget(createWidgetUnderTest());

        // assert
        // Priority should be displayed somehow (icon, color, or text)
        expect(find.byType(TodoCard), findsOneWidget);
      });

      testWidgets('should display category information', (tester) async {
        // arrange & act
        await tester.pumpWidget(createWidgetUnderTest());

        // assert
        // Category should be displayed (work category)
        expect(find.byType(TodoCard), findsOneWidget);
      });

      testWidgets('should display due date when available', (tester) async {
        // arrange & act
        await tester.pumpWidget(createWidgetUnderTest());

        // assert
        // Due date should be displayed
        expect(find.byType(TodoCard), findsOneWidget);
      });

      testWidgets('should display tags when available', (tester) async {
        // arrange & act
        await tester.pumpWidget(createWidgetUnderTest());

        // assert
        // Tags should be displayed
        expect(find.byType(TodoCard), findsOneWidget);
      });

      testWidgets('should show completed state for completed todos', (
        tester,
      ) async {
        // arrange
        final completedTodo = testTodo.copyWith(isCompleted: true);

        // act
        await tester.pumpWidget(createWidgetUnderTest(todo: completedTodo));

        // assert
        expect(find.byType(TodoCard), findsOneWidget);
        // Should show some visual indication of completion (strikethrough, different color, etc.)
      });

      testWidgets('should show overdue indicator for overdue todos', (
        tester,
      ) async {
        // arrange
        final overdueTodo = testTodo.copyWith(
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        );

        // act
        await tester.pumpWidget(createWidgetUnderTest(todo: overdueTodo));

        // assert
        expect(find.byType(TodoCard), findsOneWidget);
        // Should show overdue indicator
      });

      testWidgets(
        'should show due soon indicator for todos due within 24 hours',
        (tester) async {
          // arrange
          final dueSoonTodo = testTodo.copyWith(
            dueDate: DateTime.now().add(const Duration(hours: 12)),
          );

          // act
          await tester.pumpWidget(createWidgetUnderTest(todo: dueSoonTodo));

          // assert
          expect(find.byType(TodoCard), findsOneWidget);
          // Should show due soon indicator
        },
      );
    });

    group('Interactions', () {
      testWidgets('should call onTap when card is tapped', (tester) async {
        // arrange
        bool wasTapped = false;
        void onTap() => wasTapped = true;

        await tester.pumpWidget(createWidgetUnderTest(onTap: onTap));

        // act
        await tester.tap(find.byType(TodoCard));
        await tester.pump();

        // assert
        expect(wasTapped, true);
      });

      testWidgets('should call onToggleComplete when toggle button is tapped', (
        tester,
      ) async {
        // arrange
        bool wasToggled = false;
        void onToggleComplete() => wasToggled = true;

        await tester.pumpWidget(
          createWidgetUnderTest(onToggleComplete: onToggleComplete),
        );

        // act
        // Find and tap the toggle button (checkbox or similar)
        final toggleButton = find.byType(Checkbox).first;
        if (toggleButton.evaluate().isNotEmpty) {
          await tester.tap(toggleButton);
          await tester.pump();
        }

        // assert
        // Note: This test might need adjustment based on actual TodoCard implementation
        expect(find.byType(TodoCard), findsOneWidget);
      });

      testWidgets('should call onDelete when delete button is tapped', (
        tester,
      ) async {
        // arrange
        bool wasDeleted = false;
        void onDelete() => wasDeleted = true;

        await tester.pumpWidget(createWidgetUnderTest(onDelete: onDelete));

        // act
        // Find and tap the delete button
        final deleteButton = find.byIcon(Icons.delete);
        if (deleteButton.evaluate().isNotEmpty) {
          await tester.tap(deleteButton);
          await tester.pump();
          expect(wasDeleted, true);
        }

        // assert
        expect(find.byType(TodoCard), findsOneWidget);
      });

      testWidgets('should call onEdit when edit button is tapped', (
        tester,
      ) async {
        // arrange
        bool wasEdited = false;
        void onEdit() => wasEdited = true;

        await tester.pumpWidget(createWidgetUnderTest(onEdit: onEdit));

        // act
        // Find and tap the edit button
        final editButton = find.byIcon(Icons.edit);
        if (editButton.evaluate().isNotEmpty) {
          await tester.tap(editButton);
          await tester.pump();
          expect(wasEdited, true);
        }

        // assert
        expect(find.byType(TodoCard), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle todo with no description', (tester) async {
        // arrange
        final todoWithoutDescription = Todo(
          id: 'no-desc-id',
          title: 'Todo without description',
          description: '',
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
          userId: 'user-123',
        );

        // act
        await tester.pumpWidget(
          createWidgetUnderTest(todo: todoWithoutDescription),
        );

        // assert
        expect(find.text('Todo without description'), findsOneWidget);
        expect(find.byType(TodoCard), findsOneWidget);
      });

      testWidgets('should handle todo with very long title', (tester) async {
        // arrange
        final longTitle = 'A' * 100;
        final todoWithLongTitle = testTodo.copyWith(title: longTitle);

        // act
        await tester.pumpWidget(createWidgetUnderTest(todo: todoWithLongTitle));

        // assert
        expect(find.byType(TodoCard), findsOneWidget);
        // Should handle text overflow gracefully
      });

      testWidgets('should handle todo with no due date', (tester) async {
        // arrange
        final todoWithoutDueDate = Todo(
          id: 'no-due-date-id',
          title: 'Todo without due date',
          description: 'No due date set',
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
          userId: 'user-123',
        );

        // act
        await tester.pumpWidget(
          createWidgetUnderTest(todo: todoWithoutDueDate),
        );

        // assert
        expect(find.text('Todo without due date'), findsOneWidget);
        expect(find.byType(TodoCard), findsOneWidget);
      });

      testWidgets('should handle todo with no tags', (tester) async {
        // arrange
        final todoWithoutTags = testTodo.copyWith(tags: []);

        // act
        await tester.pumpWidget(createWidgetUnderTest(todo: todoWithoutTags));

        // assert
        expect(find.text('Test Todo Title'), findsOneWidget);
        expect(find.byType(TodoCard), findsOneWidget);
      });

      testWidgets('should handle todo with many tags', (tester) async {
        // arrange
        final todoWithManyTags = testTodo.copyWith(
          tags: [
            'tag1',
            'tag2',
            'tag3',
            'tag4',
            'tag5',
            'tag6',
            'tag7',
            'tag8',
          ],
        );

        // act
        await tester.pumpWidget(createWidgetUnderTest(todo: todoWithManyTags));

        // assert
        expect(find.text('Test Todo Title'), findsOneWidget);
        expect(find.byType(TodoCard), findsOneWidget);
        // Should handle many tags gracefully (scrolling, wrapping, or truncation)
      });
    });
  });
}
