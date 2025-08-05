import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SignOut implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    AppLogger.logAuth('SignOut - Starting sign out');
    
    final result = await repository.signOut();
    
    result.fold(
      (failure) => AppLogger.logAuth(
        'SignOut - Failed',
        error: failure.toString(),
      ),
      (_) => AppLogger.logAuth('SignOut - Success'),
    );
    
    return result;
  }
}
