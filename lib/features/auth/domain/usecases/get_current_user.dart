import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser implements UseCase<User?, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    AppLogger.logAuth('GetCurrentUser - Fetching current user');

    final result = await repository.getCurrentUser();

    result.fold(
      (failure) => AppLogger.logAuth(
        'GetCurrentUser - Failed',
        error: failure.toString(),
      ),
      (user) => AppLogger.logAuth(
        'GetCurrentUser - Success',
        data: user != null
            ? {
                'userId': user.id,
                'email': user.email,
                'isAnonymous': user.isAnonymous,
              }
            : {'user': 'null'},
      ),
    );

    return result;
  }
}
