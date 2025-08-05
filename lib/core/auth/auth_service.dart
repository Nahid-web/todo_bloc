import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';

import '../error/failures.dart';

abstract class AuthService {
  Future<Either<Failure, User>> signInAnonymously();
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Either<Failure, User>> createUserWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Either<Failure, void>> signOut();
  User? getCurrentUser();
  Stream<User?> get authStateChanges;
}

class AuthServiceImpl implements AuthService {
  final FirebaseAuth _auth;

  AuthServiceImpl(this._auth);

  @override
  Future<Either<Failure, User>> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      if (userCredential.user != null) {
        return Right(userCredential.user!);
      } else {
        return Left(UnexpectedFailure('Failed to sign in anonymously'));
      }
    } on FirebaseAuthException catch (e) {
      return Left(UnexpectedFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        return Right(userCredential.user!);
      } else {
        return Left(UnexpectedFailure('Failed to sign in'));
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Authentication failed';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'wrong-password':
          message = 'Wrong password provided';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled';
          break;
        case 'operation-not-allowed':
          message =
              'Email/password authentication is not enabled. Please enable it in Firebase Console.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        default:
          message = e.message ?? 'Authentication failed';
      }
      return Left(UnexpectedFailure(message));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        return Right(userCredential.user!);
      } else {
        return Left(UnexpectedFailure('Failed to create user'));
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to create account';
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with this email';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          message =
              'Email/password authentication is not enabled. Please enable it in Firebase Console.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        default:
          message = e.message ?? 'Failed to create account';
      }
      return Left(UnexpectedFailure(message));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to sign out: $e'));
    }
  }

  @override
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
