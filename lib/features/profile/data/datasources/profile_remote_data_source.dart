import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/logging/app_logger.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile);
  Future<String> uploadProfilePicture(String userId, File imageFile);
  Future<void> deleteProfilePicture(String userId);
  Future<void> deleteUserAccount(String userId);
  Future<void> updatePassword(String currentPassword, String newPassword);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<void> updateEmail(String newEmail, String password);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage firebaseStorage;

  ProfileRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.firebaseStorage,
  });

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      AppLogger.logNetwork(
        'GET Firestore - Get User Profile',
        url: 'users/$userId',
      );

      final doc = await firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        // Create a default profile if it doesn't exist
        final user = firebaseAuth.currentUser;
        if (user == null) {
          throw ServerException('User not authenticated');
        }

        final now = DateTime.now();
        final defaultProfile = UserProfileModel(
          id: userId,
          email: user.email ?? '',
          displayName: user.displayName,
          createdAt: now,
          updatedAt: now,
          isEmailVerified: user.emailVerified,
        );

        await firestore.collection('users').doc(userId).set(defaultProfile.toFirestore());

        AppLogger.logNetwork(
          'POST Firestore - Create Default User Profile',
          url: 'users/$userId',
          statusCode: 201,
          responseData: {
            'userId': userId,
            'email': defaultProfile.email,
            'displayName': defaultProfile.displayName,
          },
        );

        return defaultProfile;
      }

      final profile = UserProfileModel.fromFirestore(doc);

      AppLogger.logNetwork(
        'GET Firestore - Get User Profile',
        url: 'users/$userId',
        statusCode: 200,
        responseData: {
          'userId': profile.id,
          'email': profile.email,
          'displayName': profile.displayName,
          'hasProfilePicture': profile.hasProfilePicture,
        },
      );

      return profile;
    } catch (e) {
      AppLogger.logNetwork(
        'GET Firestore - Get User Profile',
        url: 'users/$userId',
        error: e.toString(),
      );
      throw ServerException('Failed to get user profile: ${e.toString()}');
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    try {
      AppLogger.logNetwork(
        'PUT Firestore - Update User Profile',
        url: 'users/${profile.id}',
        requestData: {
          'displayName': profile.displayName,
          'bio': profile.bio,
          'phoneNumber': profile.phoneNumber,
        },
      );

      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());
      
      await firestore
          .collection('users')
          .doc(profile.id)
          .update(updatedProfile.toFirestore());

      AppLogger.logNetwork(
        'PUT Firestore - Update User Profile',
        url: 'users/${profile.id}',
        statusCode: 200,
        responseData: {
          'userId': updatedProfile.id,
          'displayName': updatedProfile.displayName,
          'bio': updatedProfile.bio,
        },
      );

      return updatedProfile;
    } catch (e) {
      AppLogger.logNetwork(
        'PUT Firestore - Update User Profile',
        url: 'users/${profile.id}',
        error: e.toString(),
      );
      throw ServerException('Failed to update user profile: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    try {
      AppLogger.logNetwork(
        'POST Firebase Storage - Upload Profile Picture',
        url: 'profile_pictures/$userId',
        requestData: {
          'fileSize': imageFile.lengthSync(),
          'fileName': imageFile.path.split('/').last,
        },
      );

      final ref = firebaseStorage.ref().child('profile_pictures/$userId');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update the profile with the new picture URL
      await firestore.collection('users').doc(userId).update({
        'profilePictureUrl': downloadUrl,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      AppLogger.logNetwork(
        'POST Firebase Storage - Upload Profile Picture',
        url: 'profile_pictures/$userId',
        statusCode: 200,
        responseData: {
          'userId': userId,
          'downloadUrl': downloadUrl,
        },
      );

      return downloadUrl;
    } catch (e) {
      AppLogger.logNetwork(
        'POST Firebase Storage - Upload Profile Picture',
        url: 'profile_pictures/$userId',
        error: e.toString(),
      );
      throw ServerException('Failed to upload profile picture: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProfilePicture(String userId) async {
    try {
      AppLogger.logNetwork(
        'DELETE Firebase Storage - Delete Profile Picture',
        url: 'profile_pictures/$userId',
      );

      final ref = firebaseStorage.ref().child('profile_pictures/$userId');
      await ref.delete();

      // Update the profile to remove the picture URL
      await firestore.collection('users').doc(userId).update({
        'profilePictureUrl': FieldValue.delete(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      AppLogger.logNetwork(
        'DELETE Firebase Storage - Delete Profile Picture',
        url: 'profile_pictures/$userId',
        statusCode: 200,
      );
    } catch (e) {
      AppLogger.logNetwork(
        'DELETE Firebase Storage - Delete Profile Picture',
        url: 'profile_pictures/$userId',
        error: e.toString(),
      );
      throw ServerException('Failed to delete profile picture: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUserAccount(String userId) async {
    try {
      AppLogger.logNetwork(
        'DELETE Firebase Auth - Delete User Account',
        url: 'auth/users/$userId',
      );

      final user = firebaseAuth.currentUser;
      if (user == null || user.uid != userId) {
        throw ServerException('User not authenticated or unauthorized');
      }

      // Delete user data from Firestore
      await firestore.collection('users').doc(userId).delete();
      
      // Delete profile picture if exists
      try {
        await deleteProfilePicture(userId);
      } catch (e) {
        // Ignore if profile picture doesn't exist
      }

      // Delete user account
      await user.delete();

      AppLogger.logNetwork(
        'DELETE Firebase Auth - Delete User Account',
        url: 'auth/users/$userId',
        statusCode: 200,
      );
    } catch (e) {
      AppLogger.logNetwork(
        'DELETE Firebase Auth - Delete User Account',
        url: 'auth/users/$userId',
        error: e.toString(),
      );
      throw ServerException('Failed to delete user account: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      AppLogger.logNetwork(
        'PUT Firebase Auth - Update Password',
        url: 'auth/password',
      );

      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      AppLogger.logNetwork(
        'PUT Firebase Auth - Update Password',
        url: 'auth/password',
        statusCode: 200,
      );
    } catch (e) {
      AppLogger.logNetwork(
        'PUT Firebase Auth - Update Password',
        url: 'auth/password',
        error: e.toString(),
      );
      throw ServerException('Failed to update password: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      AppLogger.logNetwork(
        'POST Firebase Auth - Send Password Reset Email',
        url: 'auth/password-reset',
        requestData: {'email': email},
      );

      await firebaseAuth.sendPasswordResetEmail(email: email);

      AppLogger.logNetwork(
        'POST Firebase Auth - Send Password Reset Email',
        url: 'auth/password-reset',
        statusCode: 200,
      );
    } catch (e) {
      AppLogger.logNetwork(
        'POST Firebase Auth - Send Password Reset Email',
        url: 'auth/password-reset',
        error: e.toString(),
      );
      throw ServerException('Failed to send password reset email: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      AppLogger.logNetwork(
        'POST Firebase Auth - Send Email Verification',
        url: 'auth/email-verification',
      );

      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      await user.sendEmailVerification();

      AppLogger.logNetwork(
        'POST Firebase Auth - Send Email Verification',
        url: 'auth/email-verification',
        statusCode: 200,
      );
    } catch (e) {
      AppLogger.logNetwork(
        'POST Firebase Auth - Send Email Verification',
        url: 'auth/email-verification',
        error: e.toString(),
      );
      throw ServerException('Failed to send email verification: ${e.toString()}');
    }
  }

  @override
  Future<void> updateEmail(String newEmail, String password) async {
    try {
      AppLogger.logNetwork(
        'PUT Firebase Auth - Update Email',
        url: 'auth/email',
        requestData: {'newEmail': newEmail},
      );

      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('User not authenticated');
      }

      // Re-authenticate user with password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Update email
      await user.updateEmail(newEmail);

      // Update email in Firestore profile
      await firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
        'isEmailVerified': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Send verification email for new email
      await user.sendEmailVerification();

      AppLogger.logNetwork(
        'PUT Firebase Auth - Update Email',
        url: 'auth/email',
        statusCode: 200,
      );
    } catch (e) {
      AppLogger.logNetwork(
        'PUT Firebase Auth - Update Email',
        url: 'auth/email',
        error: e.toString(),
      );
      throw ServerException('Failed to update email: ${e.toString()}');
    }
  }
}
