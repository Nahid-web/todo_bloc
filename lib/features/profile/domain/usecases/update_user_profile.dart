import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateUserProfile implements UseCase<UserProfile, UpdateUserProfileParams> {
  final ProfileRepository repository;

  UpdateUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(UpdateUserProfileParams params) async {
    AppLogger.logApp(
      'UpdateUserProfile - Updating user profile',
      category: 'PROFILE_USECASE',
      data: {
        'userId': params.profile.id,
        'displayName': params.profile.displayName,
        'bio': params.profile.bio,
      },
    );

    final result = await repository.updateUserProfile(params.profile);

    result.fold(
      (failure) => AppLogger.logApp(
        'UpdateUserProfile - Failed',
        category: 'PROFILE_USECASE',
        data: {'userId': params.profile.id},
        error: failure.toString(),
        level: LogLevel.error,
      ),
      (profile) => AppLogger.logApp(
        'UpdateUserProfile - Success',
        category: 'PROFILE_USECASE',
        data: {
          'userId': profile.id,
          'displayName': profile.displayName,
          'bio': profile.bio,
        },
      ),
    );

    return result;
  }
}

class UpdateUserProfileParams extends Equatable {
  final UserProfile profile;

  const UpdateUserProfileParams({required this.profile});

  @override
  List<Object> get props => [profile];
}
