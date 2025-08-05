import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class CreateUserWithEmailAndPassword implements UseCase<User, CreateUserWithEmailAndPasswordParams> {
  final AuthRepository repository;

  CreateUserWithEmailAndPassword(this.repository);

  @override
  Future<Either<Failure, User>> call(CreateUserWithEmailAndPasswordParams params) async {
    AppLogger.logAuth(
      'CreateUserWithEmailAndPassword - Starting user creation',
      data: {
        'email': params.email,
        'passwordLength': params.password.length,
      },
    );
    
    final result = await repository.createUserWithEmailAndPassword(
      params.email,
      params.password,
    );
    
    result.fold(
      (failure) => AppLogger.logAuth(
        'CreateUserWithEmailAndPassword - Failed',
        data: {'email': params.email},
        error: failure.toString(),
      ),
      (user) => AppLogger.logAuth(
        'CreateUserWithEmailAndPassword - Success',
        data: {
          'userId': user.id,
          'email': user.email,
          'isAnonymous': user.isAnonymous,
          'createdAt': user.createdAt.toIso8601String(),
        },
      ),
    );
    
    return result;
  }
}

class CreateUserWithEmailAndPasswordParams extends Equatable {
  final String email;
  final String password;

  const CreateUserWithEmailAndPasswordParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
