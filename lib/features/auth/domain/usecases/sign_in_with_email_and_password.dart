import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailAndPassword implements UseCase<User, SignInWithEmailAndPasswordParams> {
  final AuthRepository repository;

  SignInWithEmailAndPassword(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInWithEmailAndPasswordParams params) async {
    AppLogger.logAuth(
      'SignInWithEmailAndPassword - Starting email sign in',
      data: {
        'email': params.email,
        'passwordLength': params.password.length,
      },
    );
    
    final result = await repository.signInWithEmailAndPassword(
      params.email,
      params.password,
    );
    
    result.fold(
      (failure) => AppLogger.logAuth(
        'SignInWithEmailAndPassword - Failed',
        data: {'email': params.email},
        error: failure.toString(),
      ),
      (user) => AppLogger.logAuth(
        'SignInWithEmailAndPassword - Success',
        data: {
          'userId': user.id,
          'email': user.email,
          'isAnonymous': user.isAnonymous,
          'lastSignInAt': user.lastSignInAt.toIso8601String(),
        },
      ),
    );
    
    return result;
  }
}

class SignInWithEmailAndPasswordParams extends Equatable {
  final String email;
  final String password;

  const SignInWithEmailAndPasswordParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
