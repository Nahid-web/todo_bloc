import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
    try {
      AppLogger.logApp(
        'ProfileRepository - Getting user profile',
        category: 'REPOSITORY',
        data: {'userId': userId},
      );

      if (await networkInfo.isConnected) {
        // Try to get from remote first
        try {
          final remoteProfile = await remoteDataSource.getUserProfile(userId);
          
          // Cache the profile locally
          await localDataSource.cacheUserProfile(remoteProfile);
          
          AppLogger.logApp(
            'ProfileRepository - User profile retrieved from remote',
            category: 'REPOSITORY',
            data: {
              'userId': remoteProfile.id,
              'email': remoteProfile.email,
              'displayName': remoteProfile.displayName,
            },
          );
          
          return Right(remoteProfile);
        } catch (e) {
          AppLogger.logApp(
            'ProfileRepository - Failed to get profile from remote, trying local',
            category: 'REPOSITORY',
            data: {'userId': userId},
            error: e.toString(),
            level: LogLevel.warning,
          );
          
          // Fall back to local cache
          final cachedProfile = await localDataSource.getCachedUserProfile(userId);
          if (cachedProfile != null) {
            return Right(cachedProfile);
          }
          
          return Left(ServerFailure('Failed to get user profile'));
        }
      } else {
        // No internet, try local cache
        final cachedProfile = await localDataSource.getCachedUserProfile(userId);
        if (cachedProfile != null) {
          AppLogger.logApp(
            'ProfileRepository - User profile retrieved from cache (offline)',
            category: 'REPOSITORY',
            data: {
              'userId': cachedProfile.id,
              'email': cachedProfile.email,
              'displayName': cachedProfile.displayName,
            },
          );
          
          return Right(cachedProfile);
        }
        
        return Left(CacheFailure('No cached profile available and device is offline'));
      }
    } catch (e) {
      AppLogger.logApp(
        'ProfileRepository - Failed to get user profile',
        category: 'REPOSITORY',
        data: {'userId': userId},
        error: e.toString(),
        level: LogLevel.error,
      );
      
      if (e is ServerException) {
        return Left(ServerFailure(e.message));
      } else if (e is CacheException) {
        return Left(CacheFailure(e.message));
      } else {
        return Left(ServerFailure('Unexpected error occurred'));
      }
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile) async {
    try {
      AppLogger.logApp(
        'ProfileRepository - Updating user profile',
        category: 'REPOSITORY',
        data: {
          'userId': profile.id,
          'displayName': profile.displayName,
          'bio': profile.bio,
        },
      );

      if (await networkInfo.isConnected) {
        final profileModel = UserProfileModel.fromEntity(profile);
        final updatedProfile = await remoteDataSource.updateUserProfile(profileModel);
        
        // Cache the updated profile locally
        await localDataSource.cacheUserProfile(updatedProfile);
        
        AppLogger.logApp(
          'ProfileRepository - User profile updated successfully',
          category: 'REPOSITORY',
          data: {
            'userId': updatedProfile.id,
            'displayName': updatedProfile.displayName,
            'bio': updatedProfile.bio,
          },
        );
        
        return Right(updatedProfile);
      } else {
        return Left(ServerFailure('Cannot update profile while offline'));
      }
    } catch (e) {
      AppLogger.logApp(
        'ProfileRepository - Failed to update user profile',
        category: 'REPOSITORY',
        data: {'userId': profile.id},
        error: e.toString(),
        level: LogLevel.error,
      );
      
      if (e is ServerException) {
        return Left(ServerFailure(e.message));
      } else {
        return Left(ServerFailure('Unexpected error occurred'));
      }
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(String userId, File imageFile) async {
    try {
      AppLogger.logApp(
        'ProfileRepository - Uploading profile picture',
        category: 'REPOSITORY',
        data: {
          'userId': userId,
          'fileSize': imageFile.lengthSync(),
          'fileName': imageFile.path.split('/').last,
        },
      );

      if (await networkInfo.isConnected) {
        final imageUrl = await remoteDataSource.uploadProfilePicture(userId, imageFile);
        
        AppLogger.logApp(
          'ProfileRepository - Profile picture uploaded successfully',
          category: 'REPOSITORY',
          data: {
            'userId': userId,
            'imageUrl': imageUrl,
          },
        );
        
        return Right(imageUrl);
      } else {
        return Left(ServerFailure('Cannot upload profile picture while offline'));
      }
    } catch (e) {
      AppLogger.logApp(
        'ProfileRepository - Failed to upload profile picture',
        category: 'REPOSITORY',
        data: {'userId': userId},
        error: e.toString(),
        level: LogLevel.error,
      );
      
      if (e is ServerException) {
        return Left(ServerFailure(e.message));
      } else {
        return Left(ServerFailure('Unexpected error occurred'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfilePicture(String userId) async {
    try {
      AppLogger.logApp(
        'ProfileRepository - Deleting profile picture',
        category: 'REPOSITORY',
        data: {'userId': userId},
      );

      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteProfilePicture(userId);
        
        AppLogger.logApp(
          'ProfileRepository - Profile picture deleted successfully',
          category: 'REPOSITORY',
          data: {'userId': userId},
        );
        
        return const Right(null);
      } else {
        return Left(ServerFailure('Cannot delete profile picture while offline'));
      }
    } catch (e) {
      AppLogger.logApp(
        'ProfileRepository - Failed to delete profile picture',
        category: 'REPOSITORY',
        data: {'userId': userId},
        error: e.toString(),
        level: LogLevel.error,
      );
      
      if (e is ServerException) {
        return Left(ServerFailure(e.message));
      } else {
        return Left(ServerFailure('Unexpected error occurred'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserAccount(String userId) async {
    try {
      AppLogger.logApp(
        'ProfileRepository - Deleting user account',
        category: 'REPOSITORY',
        data: {'userId': userId},
      );

      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteUserAccount(userId);
        
        // Clear local cache
        await localDataSource.clearCachedUserProfile(userId);
        
        AppLogger.logApp(
          'ProfileRepository - User account deleted successfully',
          category: 'REPOSITORY',
          data: {'userId': userId},
        );
        
        return const Right(null);
      } else {
        return Left(ServerFailure('Cannot delete account while offline'));
      }
    } catch (e) {
      AppLogger.logApp(
        'ProfileRepository - Failed to delete user account',
        category: 'REPOSITORY',
        data: {'userId': userId},
        error: e.toString(),
        level: LogLevel.error,
      );
      
      if (e is ServerException) {
        return Left(ServerFailure(e.message));
      } else {
        return Left(ServerFailure('Unexpected error occurred'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword(String currentPassword, String newPassword) async {
    try {
      AppLogger.logApp(
        'ProfileRepository - Updating password',
        category: 'REPOSITORY',
      );

      if (await networkInfo.isConnected) {
        await remoteDataSource.updatePassword(currentPassword, newPassword);
        
        AppLogger.logApp(
          'ProfileRepository - Password updated successfully',
          category: 'REPOSITORY',
        );
        
        return const Right(null);
      } else {
        return Left(ServerFailure('Cannot update password while offline'));
      }
    } catch (e) {
      AppLogger.logApp(
        'ProfileRepository - Failed to update password',
        category: 'REPOSITORY',
        error: e.toString(),
        level: LogLevel.error,
      );
      
      if (e is ServerException) {
        return Left(ServerFailure(e.message));
      } else {
        return Left(ServerFailure('Unexpected error occurred'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      AppLogger.logApp(
        'ProfileRepository - Sending password reset email',
        category: 'REPOSITORY',
        data: {'email': email},
      );

      if (await networkInfo.isConnected) {
        await remoteDataSource.sendPasswordResetEmail(email);
        
        AppLogger.logApp(
          'ProfileRepository - Password reset email sent successfully',
          category: 'REPOSITORY',
          data: {'email': email},
        );
        
        return const Right(null);
      } else {
        return Left(ServerFailure('Cannot send password reset email while offline'));
      }
    } catch (e) {
      AppLogger.logApp(
        'ProfileRepository - Failed to send password reset email',
        category: 'REPOSITORY',
        data: {'email': email},
        error: e.toString(),
        level: LogLevel.error,
      );
      
      if (e is ServerException) {
        return Left(ServerFailure(e.message));
      } else {
        return Left(ServerFailure('Unexpected error occurred'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      AppLogger.logApp(
        'ProfileRepository - Sending email verification',
        category: 'REPOSITORY',
      );

      if (await networkInfo.isConnected) {
        await remoteDataSource.sendEmailVerification();
        
        AppLogger.logApp(
          'ProfileRepository - Email verification sent successfully',
          category: 'REPOSITORY',
        );
        
        return const Right(null);
      } else {
        return Left(ServerFailure('Cannot send email verification while offline'));
      }
    } catch (e) {
      AppLogger.logApp(
        'ProfileRepository - Failed to send email verification',
        category: 'REPOSITORY',
        error: e.toString(),
        level: LogLevel.error,
      );
      
      if (e is ServerException) {
        return Left(ServerFailure(e.message));
      } else {
        return Left(ServerFailure('Unexpected error occurred'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> updateEmail(String newEmail, String password) async {
    try {
      AppLogger.logApp(
        'ProfileRepository - Updating email',
        category: 'REPOSITORY',
        data: {'newEmail': newEmail},
      );

      if (await networkInfo.isConnected) {
        await remoteDataSource.updateEmail(newEmail, password);
        
        AppLogger.logApp(
          'ProfileRepository - Email updated successfully',
          category: 'REPOSITORY',
          data: {'newEmail': newEmail},
        );
        
        return const Right(null);
      } else {
        return Left(ServerFailure('Cannot update email while offline'));
      }
    } catch (e) {
      AppLogger.logApp(
        'ProfileRepository - Failed to update email',
        category: 'REPOSITORY',
        data: {'newEmail': newEmail},
        error: e.toString(),
        level: LogLevel.error,
      );
      
      if (e is ServerException) {
        return Left(ServerFailure(e.message));
      } else {
        return Left(ServerFailure('Unexpected error occurred'));
      }
    }
  }
}
