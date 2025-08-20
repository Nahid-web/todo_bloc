import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UploadProfilePicture implements UseCase<String, UploadProfilePictureParams> {
  final ProfileRepository repository;

  UploadProfilePicture(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadProfilePictureParams params) async {
    AppLogger.logApp(
      'UploadProfilePicture - Uploading profile picture',
      category: 'PROFILE_USECASE',
      data: {
        'userId': params.userId,
        'fileSize': params.imageFile.lengthSync(),
        'fileName': params.imageFile.path.split('/').last,
      },
    );

    final result = await repository.uploadProfilePicture(params.userId, params.imageFile);

    result.fold(
      (failure) => AppLogger.logApp(
        'UploadProfilePicture - Failed',
        category: 'PROFILE_USECASE',
        data: {'userId': params.userId},
        error: failure.toString(),
        level: LogLevel.error,
      ),
      (imageUrl) => AppLogger.logApp(
        'UploadProfilePicture - Success',
        category: 'PROFILE_USECASE',
        data: {
          'userId': params.userId,
          'imageUrl': imageUrl,
        },
      ),
    );

    return result;
  }
}

class UploadProfilePictureParams extends Equatable {
  final String userId;
  final File imageFile;

  const UploadProfilePictureParams({
    required this.userId,
    required this.imageFile,
  });

  @override
  List<Object> get props => [userId, imageFile];
}
