import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UpdatePassword implements UseCase<void, UpdatePasswordParams> {
  final ProfileRepository repository;

  UpdatePassword(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdatePasswordParams params) async {
    AppLogger.logApp(
      'UpdatePassword - Updating password',
      category: 'PROFILE_USECASE',
    );

    final result = await repository.updatePassword(
      params.currentPassword,
      params.newPassword,
    );

    result.fold(
      (failure) => AppLogger.logApp(
        'UpdatePassword - Failed',
        category: 'PROFILE_USECASE',
        error: failure.toString(),
        level: LogLevel.error,
      ),
      (_) => AppLogger.logApp(
        'UpdatePassword - Success',
        category: 'PROFILE_USECASE',
      ),
    );

    return result;
  }
}

class UpdatePasswordParams extends Equatable {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}
