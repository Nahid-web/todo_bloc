import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class DeleteProfilePicture implements UseCase<void, DeleteProfilePictureParams> {
  final ProfileRepository repository;

  DeleteProfilePicture(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteProfilePictureParams params) async {
    AppLogger.logApp(
      'DeleteProfilePicture - Deleting profile picture',
      category: 'PROFILE_USECASE',
      data: {'userId': params.userId},
    );

    final result = await repository.deleteProfilePicture(params.userId);

    result.fold(
      (failure) => AppLogger.logApp(
        'DeleteProfilePicture - Failed',
        category: 'PROFILE_USECASE',
        data: {'userId': params.userId},
        error: failure.toString(),
        level: LogLevel.error,
      ),
      (_) => AppLogger.logApp(
        'DeleteProfilePicture - Success',
        category: 'PROFILE_USECASE',
        data: {'userId': params.userId},
      ),
    );

    return result;
  }
}

class DeleteProfilePictureParams extends Equatable {
  final String userId;

  const DeleteProfilePictureParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
