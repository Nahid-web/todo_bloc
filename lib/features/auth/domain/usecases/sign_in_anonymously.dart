import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInAnonymously implements UseCase<User, NoParams> {
  final AuthRepository repository;

  SignInAnonymously(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    AppLogger.logAuth('SignInAnonymously - Starting anonymous sign in');
    
    final result = await repository.signInAnonymously();
    
    result.fold(
      (failure) => AppLogger.logAuth(
        'SignInAnonymously - Failed',
        error: failure.toString(),
      ),
      (user) => AppLogger.logAuth(
        'SignInAnonymously - Success',
        data: {
          'userId': user.id,
          'isAnonymous': user.isAnonymous,
          'createdAt': user.createdAt.toIso8601String(),
        },
      ),
    );
    
    return result;
  }
}
