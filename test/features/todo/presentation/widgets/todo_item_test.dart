import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/features/todo/domain/entities/todo.dart';
import 'package:todo_bloc/features/todo/presentation/widgets/todo_item.dart';

void main() {
  group('TodoItem Widget', () {
    late Todo testTodo;

    setUp(() {
      testTodo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
        isCompleted: false,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );
    });

    Widget createWidgetUnderTest({
      VoidCallback? onTap,
      VoidCallback? onToggle,
      VoidCallback? onDelete,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TodoItem(
            todo: testTodo,
            onTap: onTap,
            onToggle: onToggle,
            onDelete: onDelete,
          ),
        ),
      );
    }

    testWidgets('should display todo title and description', (tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Test Todo'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('should display checkbox with correct state', (tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('should call onToggle when checkbox is tapped', (tester) async {
      // arrange
      bool toggleCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        onToggle: () => toggleCalled = true,
      ));

      // act
      await tester.tap(find.byType(Checkbox));

      // assert
      expect(toggleCalled, true);
    });

    testWidgets('should call onTap when list tile is tapped', (tester) async {
      // arrange
      bool tapCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        onTap: () => tapCalled = true,
      ));

      // act
      await tester.tap(find.byType(ListTile));

      // assert
      expect(tapCalled, true);
    });

    testWidgets('should show delete button when onDelete is provided', (tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(
        onDelete: () {},
      ));

      // assert
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('should not show delete button when onDelete is null', (tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('should call onDelete when delete button is tapped', (tester) async {
      // arrange
      bool deleteCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        onDelete: () => deleteCalled = true,
      ));

      // act
      await tester.tap(find.byIcon(Icons.delete_outline));

      // assert
      expect(deleteCalled, true);
    });
  });
}
