import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

  final testTodos = [
    Todo(
      id: '1',
      title: 'Test Todo 1',
      description: 'Test Description 1',
      isCompleted: false,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    ),
    Todo(
      id: '2',
      title: 'Test Todo 2',
      description: 'Test Description 2',
      isCompleted: true,
      createdAt: DateTime(2023, 1, 2),
      updatedAt: DateTime(2023, 1, 2),
    ),
  ];

  test('should get todos from the repository', () async {
    // arrange
    when(() => mockTodoRepository.getTodos())
        .thenAnswer((_) async => Right(testTodos));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Right(testTodos));
    verify(() => mockTodoRepository.getTodos());
    verifyNoMoreInteractions(mockTodoRepository);
  });
}
