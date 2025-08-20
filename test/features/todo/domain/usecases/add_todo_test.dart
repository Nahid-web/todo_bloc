import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_bloc/core/error/failures.dart';
import 'package:todo_bloc/features/todo/domain/entities/todo.dart';
import 'package:todo_bloc/features/todo/domain/repositories/todo_repository.dart';
import 'package:todo_bloc/features/todo/domain/usecases/add_todo.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late AddTodo usecase;
  late MockTodoRepository mockTodoRepository;

  setUp(() {
    mockTodoRepository = MockTodoRepository();
    usecase = AddTodo(mockTodoRepository);
  });

  group('AddTodo UseCase', () {
    final testTodo = Todo(
      id: 'test-id-123',
      title: 'Test Todo',
      description: 'Test Description',
      isCompleted: false,
      createdAt: DateTime(2025, 1, 15),
      updatedAt: DateTime(2025, 1, 15),
      userId: 'user-123',
      priority: TodoPriority.medium,
      category: TodoCategory.work,
      tags: ['work', 'important'],
    );

    // Register fallback values for mocktail
    setUpAll(() {
      registerFallbackValue(testTodo);
    });

    test('should add todo through the repository', () async {
      // arrange
      when(
        () => mockTodoRepository.addTodo(any()),
      ).thenAnswer((_) async => Right(testTodo));

      // act
      final result = await usecase(AddTodoParams(todo: testTodo));

      // assert
      expect(result, Right(testTodo));
      verify(() => mockTodoRepository.addTodo(testTodo));
      verifyNoMoreInteractions(mockTodoRepository);
    });

    test('should return failure when repository fails', () async {
      // arrange
      const failure = ServerFailure('Failed to add todo');
      when(
        () => mockTodoRepository.addTodo(any()),
      ).thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(AddTodoParams(todo: testTodo));

      // assert
      expect(result, const Left(failure));
      verify(() => mockTodoRepository.addTodo(testTodo));
      verifyNoMoreInteractions(mockTodoRepository);
    });

    test('should handle network failure', () async {
      // arrange
      const failure = NetworkFailure('No internet connection');
      when(
        () => mockTodoRepository.addTodo(any()),
      ).thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(AddTodoParams(todo: testTodo));

      // assert
      expect(result, const Left(failure));
      verify(() => mockTodoRepository.addTodo(testTodo));
      verifyNoMoreInteractions(mockTodoRepository);
    });

    test('should handle cache failure', () async {
      // arrange
      const failure = CacheFailure('Failed to cache todo');
      when(
        () => mockTodoRepository.addTodo(any()),
      ).thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(AddTodoParams(todo: testTodo));

      // assert
      expect(result, const Left(failure));
      verify(() => mockTodoRepository.addTodo(testTodo));
      verifyNoMoreInteractions(mockTodoRepository);
    });

    test('should handle validation failure', () async {
      // arrange
      const failure = ValidationFailure('Invalid todo data');
      when(
        () => mockTodoRepository.addTodo(any()),
      ).thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(AddTodoParams(todo: testTodo));

      // assert
      expect(result, const Left(failure));
      verify(() => mockTodoRepository.addTodo(testTodo));
      verifyNoMoreInteractions(mockTodoRepository);
    });

    group('AddTodoParams', () {
      test('should be equal when todo is the same', () {
        // arrange
        final params1 = AddTodoParams(todo: testTodo);
        final params2 = AddTodoParams(todo: testTodo);

        // assert
        expect(params1, equals(params2));
        expect(params1.hashCode, equals(params2.hashCode));
      });

      test('should not be equal when todo is different', () {
        // arrange
        final params1 = AddTodoParams(todo: testTodo);
        final differentTodo = testTodo.copyWith(title: 'Different Title');
        final params2 = AddTodoParams(todo: differentTodo);

        // assert
        expect(params1, isNot(equals(params2)));
        expect(params1.hashCode, isNot(equals(params2.hashCode)));
      });

      test('should return correct props', () {
        // arrange
        final params = AddTodoParams(todo: testTodo);

        // assert
        expect(params.props, [testTodo]);
      });
    });

    group('Edge Cases', () {
      test('should handle todo with minimal properties', () async {
        // arrange
        final minimalTodo = Todo(
          id: 'minimal-id',
          title: 'Minimal Todo',
          description: 'Minimal Description',
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 'user-123',
        );

        when(
          () => mockTodoRepository.addTodo(any()),
        ).thenAnswer((_) async => Right(minimalTodo));

        // act
        final result = await usecase(AddTodoParams(todo: minimalTodo));

        // assert
        expect(result, Right(minimalTodo));
        verify(() => mockTodoRepository.addTodo(minimalTodo));
      });

      test('should handle todo with all properties', () async {
        // arrange
        final fullTodo = Todo(
          id: 'full-id',
          title: 'Full Todo',
          description: 'Full description with lots of details',
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 'user-123',
          priority: TodoPriority.urgent,
          category: TodoCategory.health,
          dueDate: DateTime.now().add(const Duration(days: 7)),
          tags: ['urgent', 'health', 'important', 'personal'],
        );

        when(
          () => mockTodoRepository.addTodo(any()),
        ).thenAnswer((_) async => Right(fullTodo));

        // act
        final result = await usecase(AddTodoParams(todo: fullTodo));

        // assert
        expect(result, Right(fullTodo));
        verify(() => mockTodoRepository.addTodo(fullTodo));
      });

      test('should handle todo with very long title', () async {
        // arrange
        final longTitle = 'A' * 1000;
        final todoWithLongTitle = testTodo.copyWith(title: longTitle);

        when(
          () => mockTodoRepository.addTodo(any()),
        ).thenAnswer((_) async => Right(todoWithLongTitle));

        // act
        final result = await usecase(AddTodoParams(todo: todoWithLongTitle));

        // assert
        expect(result, Right(todoWithLongTitle));
        verify(() => mockTodoRepository.addTodo(todoWithLongTitle));
      });

      test('should handle todo with special characters', () async {
        // arrange
        final specialTodo = testTodo.copyWith(
          title: 'Todo with special chars: @#\$%^&*()_+-=[]{}|;:,.<>?',
          description: 'Description with émojis 🚀 and ünïcödé characters',
        );

        when(
          () => mockTodoRepository.addTodo(any()),
        ).thenAnswer((_) async => Right(specialTodo));

        // act
        final result = await usecase(AddTodoParams(todo: specialTodo));

        // assert
        expect(result, Right(specialTodo));
        verify(() => mockTodoRepository.addTodo(specialTodo));
      });
    });
  });
}
