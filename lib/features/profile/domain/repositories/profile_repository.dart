import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile);
  Future<Either<Failure, String>> uploadProfilePicture(String userId, File imageFile);
  Future<Either<Failure, void>> deleteProfilePicture(String userId);
  Future<Either<Failure, void>> deleteUserAccount(String userId);
  Future<Either<Failure, void>> updatePassword(String currentPassword, String newPassword);
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, void>> sendEmailVerification();
  Future<Either<Failure, void>> updateEmail(String newEmail, String password);
}
