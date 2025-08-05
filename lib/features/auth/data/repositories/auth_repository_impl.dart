import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, domain.User>> signInAnonymously() async {
    AppLogger.logApp(
      'AuthRepository - Starting anonymous sign in',
      category: 'REPOSITORY',
    );

    try {
      final user = await remoteDataSource.signInAnonymously();
      await localDataSource.cacheUser(user);
      
      AppLogger.logApp(
        'AuthRepository - Anonymous sign in successful',
        category: 'REPOSITORY',
        data: {
          'userId': user.id,
          'isAnonymous': user.isAnonymous,
        },
      );

      return Right(user);
    } on FirebaseAuthException catch (e) {
      final message = _getFirebaseErrorMessage(e);
      
      AppLogger.logApp(
        'AuthRepository - Anonymous sign in failed (Firebase)',
        category: 'REPOSITORY',
        data: {
          'errorCode': e.code,
          'errorMessage': message,
        },
        level: LogLevel.error,
      );

      return Left(UnexpectedFailure(message));
    } catch (e) {
      AppLogger.logApp(
        'AuthRepository - Anonymous sign in failed (Unexpected)',
        category: 'REPOSITORY',
        data: {'error': e.toString()},
        level: LogLevel.error,
      );

      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    AppLogger.logApp(
      'AuthRepository - Starting email sign in',
      category: 'REPOSITORY',
      data: {
        'email': email,
        'passwordLength': password.length,
      },
    );

    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(email, password);
      await localDataSource.cacheUser(user);
      
      AppLogger.logApp(
        'AuthRepository - Email sign in successful',
        category: 'REPOSITORY',
        data: {
          'userId': user.id,
          'email': user.email,
          'isAnonymous': user.isAnonymous,
        },
      );

      return Right(user);
    } on FirebaseAuthException catch (e) {
      final message = _getFirebaseErrorMessage(e);
      
      AppLogger.logApp(
        'AuthRepository - Email sign in failed (Firebase)',
        category: 'REPOSITORY',
        data: {
          'email': email,
          'errorCode': e.code,
          'errorMessage': message,
        },
        level: LogLevel.error,
      );

      return Left(UnexpectedFailure(message));
    } catch (e) {
      AppLogger.logApp(
        'AuthRepository - Email sign in failed (Unexpected)',
        category: 'REPOSITORY',
        data: {
          'email': email,
          'error': e.toString(),
        },
        level: LogLevel.error,
      );

      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.User>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    AppLogger.logApp(
      'AuthRepository - Starting user creation',
      category: 'REPOSITORY',
      data: {
        'email': email,
        'passwordLength': password.length,
      },
    );

    try {
      final user = await remoteDataSource.createUserWithEmailAndPassword(email, password);
      await localDataSource.cacheUser(user);
      
      AppLogger.logApp(
        'AuthRepository - User creation successful',
        category: 'REPOSITORY',
        data: {
          'userId': user.id,
          'email': user.email,
          'isAnonymous': user.isAnonymous,
        },
      );

      return Right(user);
    } on FirebaseAuthException catch (e) {
      final message = _getFirebaseErrorMessage(e);
      
      AppLogger.logApp(
        'AuthRepository - User creation failed (Firebase)',
        category: 'REPOSITORY',
        data: {
          'email': email,
          'errorCode': e.code,
          'errorMessage': message,
        },
        level: LogLevel.error,
      );

      return Left(UnexpectedFailure(message));
    } catch (e) {
      AppLogger.logApp(
        'AuthRepository - User creation failed (Unexpected)',
        category: 'REPOSITORY',
        data: {
          'email': email,
          'error': e.toString(),
        },
        level: LogLevel.error,
      );

      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    AppLogger.logApp(
      'AuthRepository - Starting sign out',
      category: 'REPOSITORY',
    );

    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCachedUser();
      
      AppLogger.logApp(
        'AuthRepository - Sign out successful',
        category: 'REPOSITORY',
      );

      return const Right(null);
    } catch (e) {
      AppLogger.logApp(
        'AuthRepository - Sign out failed',
        category: 'REPOSITORY',
        data: {'error': e.toString()},
        level: LogLevel.error,
      );

      return Left(UnexpectedFailure('Failed to sign out: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.User?>> getCurrentUser() async {
    AppLogger.logApp(
      'AuthRepository - Getting current user',
      category: 'REPOSITORY',
    );

    try {
      // Try to get from remote first
      final remoteUser = await remoteDataSource.getCurrentUser();
      
      if (remoteUser != null) {
        await localDataSource.cacheUser(remoteUser);
        
        AppLogger.logApp(
          'AuthRepository - Current user retrieved from remote',
          category: 'REPOSITORY',
          data: {
            'userId': remoteUser.id,
            'email': remoteUser.email,
            'isAnonymous': remoteUser.isAnonymous,
          },
        );

        return Right(remoteUser);
      }

      // Fallback to cached user
      final cachedUser = await localDataSource.getCachedUser();
      
      AppLogger.logApp(
        'AuthRepository - Current user retrieved from cache',
        category: 'REPOSITORY',
        data: cachedUser != null ? {
          'userId': cachedUser.id,
          'email': cachedUser.email,
          'isAnonymous': cachedUser.isAnonymous,
        } : {'user': 'null'},
      );

      return Right(cachedUser);
    } catch (e) {
      AppLogger.logApp(
        'AuthRepository - Get current user failed',
        category: 'REPOSITORY',
        data: {'error': e.toString()},
        level: LogLevel.error,
      );

      return Left(UnexpectedFailure('Failed to get current user: $e'));
    }
  }

  @override
  Stream<domain.User?> get authStateChanges {
    AppLogger.logApp(
      'AuthRepository - Setting up auth state changes stream',
      category: 'REPOSITORY',
    );

    return remoteDataSource.authStateChanges.asyncMap((user) async {
      if (user != null) {
        await localDataSource.cacheUser(user);
      } else {
        await localDataSource.clearCachedUser();
      }
      return user;
    });
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled. Please enable it in Firebase Console.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'weak-password':
        return 'The password provided is too weak';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
