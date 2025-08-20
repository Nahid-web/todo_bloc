import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_bloc/core/error/failures.dart';
import 'package:todo_bloc/core/usecases/usecase.dart';
import 'package:todo_bloc/features/todo/domain/entities/todo.dart';
import 'package:todo_bloc/features/todo/domain/repositories/todo_repository.dart';
import 'package:todo_bloc/features/todo/domain/usecases/get_todos.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late GetTodos usecase;
  late MockTodoRepository mockTodoRepository;

  setUp(() {
    mockTodoRepository = MockTodoRepository();
    usecase = GetTodos(mockTodoRepository);
  });

  group('GetTodos UseCase', () {
    final testTodos = [
      Todo(
        id: '1',
        title: 'Test Todo 1',
        description: 'Description 1',
        isCompleted: false,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
        userId: 'user-123',
        priority: TodoPriority.medium,
        category: TodoCategory.work,
      ),
      Todo(
        id: '2',
        title: 'Test Todo 2',
        description: 'Description 2',
        isCompleted: true,
        createdAt: DateTime(2025, 1, 14),
        updatedAt: DateTime(2025, 1, 16),
        userId: 'user-123',
        priority: TodoPriority.high,
        category: TodoCategory.personal,
      ),
    ];

    test('should get todos from the repository', () async {
      // arrange
      when(
        () => mockTodoRepository.getTodos(),
      ).thenAnswer((_) async => Right(testTodos));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, Right(testTodos));
      verify(() => mockTodoRepository.getTodos());
      verifyNoMoreInteractions(mockTodoRepository);
    });

    test('should return failure when repository fails', () async {
      // arrange
      const failure = ServerFailure('Server error');
      when(
        () => mockTodoRepository.getTodos(),
      ).thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(failure));
      verify(() => mockTodoRepository.getTodos());
      verifyNoMoreInteractions(mockTodoRepository);
    });

    test('should return empty list when no todos exist', () async {
      // arrange
      when(
        () => mockTodoRepository.getTodos(),
      ).thenAnswer((_) async => const Right(<Todo>[]));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Right(<Todo>[]));
      verify(() => mockTodoRepository.getTodos());
      verifyNoMoreInteractions(mockTodoRepository);
    });

    test('should handle network failure', () async {
      // arrange
      const failure = NetworkFailure('No internet connection');
      when(
        () => mockTodoRepository.getTodos(),
      ).thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(failure));
      verify(() => mockTodoRepository.getTodos());
      verifyNoMoreInteractions(mockTodoRepository);
    });

    test('should handle cache failure', () async {
      // arrange
      const failure = CacheFailure('Cache error');
      when(
        () => mockTodoRepository.getTodos(),
      ).thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(failure));
      verify(() => mockTodoRepository.getTodos());
      verifyNoMoreInteractions(mockTodoRepository);
    });

    test('should handle unexpected failure', () async {
      // arrange
      const failure = UnexpectedFailure('Unexpected error occurred');
      when(
        () => mockTodoRepository.getTodos(),
      ).thenAnswer((_) async => const Left(failure));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(failure));
      verify(() => mockTodoRepository.getTodos());
      verifyNoMoreInteractions(mockTodoRepository);
    });
  });
}
