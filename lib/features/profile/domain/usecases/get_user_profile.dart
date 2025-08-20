import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetUserProfile implements UseCase<UserProfile, GetUserProfileParams> {
  final ProfileRepository repository;

  GetUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(GetUserProfileParams params) async {
    AppLogger.logApp(
      'GetUserProfile - Fetching user profile',
      category: 'PROFILE_USECASE',
      data: {'userId': params.userId},
    );

    final result = await repository.getUserProfile(params.userId);

    result.fold(
      (failure) => AppLogger.logApp(
        'GetUserProfile - Failed',
        category: 'PROFILE_USECASE',
        data: {'userId': params.userId},
        error: failure.toString(),
        level: LogLevel.error,
      ),
      (profile) => AppLogger.logApp(
        'GetUserProfile - Success',
        category: 'PROFILE_USECASE',
        data: {
          'userId': profile.id,
          'email': profile.email,
          'displayName': profile.displayName,
          'hasProfilePicture': profile.hasProfilePicture,
        },
      ),
    );

    return result;
  }
}

class GetUserProfileParams extends Equatable {
  final String userId;

  const GetUserProfileParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
