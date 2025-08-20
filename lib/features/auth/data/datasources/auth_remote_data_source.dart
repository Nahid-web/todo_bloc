import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/logging/app_logger.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInAnonymously();
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> createUserWithEmailAndPassword(
    String email,
    String password,
  );
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl({required firebase_auth.FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  @override
  Future<UserModel> signInAnonymously() async {
    AppLogger.logNetwork(
      'POST Firebase Auth - Anonymous Sign In',
      requestData: {'method': 'signInAnonymously'},
    );

    try {
      final userCredential = await _firebaseAuth.signInAnonymously();

      if (userCredential.user == null) {
        throw Exception('Failed to sign in anonymously - user is null');
      }

      final userModel = UserModel.fromFirebaseUser(userCredential.user!);

      AppLogger.logNetwork(
        'POST Firebase Auth - Anonymous Sign In',
        statusCode: 200,
        responseData: {
          'userId': userModel.id,
          'isAnonymous': userModel.isAnonymous,
        },
      );

      return userModel;
    } catch (e) {
      AppLogger.logNetwork(
        'POST Firebase Auth - Anonymous Sign In',
        error: e.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    AppLogger.logNetwork(
      'POST Firebase Auth - Email Sign In',
      requestData: {'email': email, 'passwordLength': password.length},
    );

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to sign in with email - user is null');
      }

      final userModel = UserModel.fromFirebaseUser(userCredential.user!);

      AppLogger.logNetwork(
        'POST Firebase Auth - Email Sign In',
        statusCode: 200,
        responseData: {
          'userId': userModel.id,
          'email': userModel.email,
          'isAnonymous': userModel.isAnonymous,
        },
      );

      return userModel;
    } catch (e) {
      AppLogger.logNetwork(
        'POST Firebase Auth - Email Sign In',
        requestData: {'email': email},
        error: e.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<UserModel> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    AppLogger.logNetwork(
      'POST Firebase Auth - Create User',
      requestData: {'email': email, 'passwordLength': password.length},
    );

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user - user is null');
      }

      final userModel = UserModel.fromFirebaseUser(userCredential.user!);

      AppLogger.logNetwork(
        'POST Firebase Auth - Create User',
        statusCode: 200,
        responseData: {
          'userId': userModel.id,
          'email': userModel.email,
          'isAnonymous': userModel.isAnonymous,
        },
      );

      return userModel;
    } catch (e) {
      AppLogger.logNetwork(
        'POST Firebase Auth - Create User',
        requestData: {'email': email},
        error: e.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    AppLogger.logNetwork(
      'POST Firebase Auth - Sign Out',
      requestData: {'method': 'signOut'},
    );

    try {
      await _firebaseAuth.signOut();

      AppLogger.logNetwork('POST Firebase Auth - Sign Out', statusCode: 200);
    } catch (e) {
      AppLogger.logNetwork(
        'POST Firebase Auth - Sign Out',
        error: e.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    AppLogger.logNetwork('GET Firebase Auth - Get Current User');

    try {
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser == null) {
        AppLogger.logNetwork(
          'GET Firebase Auth - Get Current User',
          statusCode: 200,
          responseData: {'user': 'null'},
        );
        return null;
      }

      final userModel = UserModel.fromFirebaseUser(firebaseUser);

      AppLogger.logNetwork(
        'GET Firebase Auth - Get Current User',
        statusCode: 200,
        responseData: {
          'userId': userModel.id,
          'email': userModel.email,
          'isAnonymous': userModel.isAnonymous,
        },
      );

      return userModel;
    } catch (e) {
      AppLogger.logNetwork(
        'GET Firebase Auth - Get Current User',
        error: e.toString(),
      );
      rethrow;
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    AppLogger.logApp(
      'Setting up Firebase Auth state changes stream',
      category: 'AUTH_STREAM',
    );

    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        AppLogger.logApp(
          'Auth state changed: User signed out',
          category: 'AUTH_STREAM',
        );
        return null;
      }

      final userModel = UserModel.fromFirebaseUser(firebaseUser);

      AppLogger.logApp(
        'Auth state changed: User signed in',
        category: 'AUTH_STREAM',
        data: {
          'userId': userModel.id,
          'email': userModel.email,
          'isAnonymous': userModel.isAnonymous,
        },
      );

      return userModel;
    });
  }
}
