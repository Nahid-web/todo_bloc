import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/error/failures.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  late StreamSubscription<User?> _authSubscription;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<SignInAnonymously>(_onSignInAnonymously);
    on<SignInWithEmailAndPassword>(_onSignInWithEmailAndPassword);
    on<CreateUserWithEmailAndPassword>(_onCreateUserWithEmailAndPassword);
    on<SignOut>(_onSignOut);

    // Listen to auth state changes
    _authSubscription = authService.authStateChanges.listen((user) {
      if (user != null) {
        add(AuthStarted()); // Trigger state update through event
      } else {
        add(AuthStarted()); // Trigger state update through event
      }
    });
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    final user = authService.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignInAnonymously(
    SignInAnonymously event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authService.signInAnonymously();
    result.fold(
      (failure) => emit(AuthError(_getErrorMessage(failure))),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignInWithEmailAndPassword(
    SignInWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authService.signInWithEmailAndPassword(
      event.email,
      event.password,
    );
    result.fold(
      (failure) => emit(AuthError(_getErrorMessage(failure))),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onCreateUserWithEmailAndPassword(
    CreateUserWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authService.createUserWithEmailAndPassword(
      event.email,
      event.password,
    );
    result.fold(
      (failure) => emit(AuthError(_getErrorMessage(failure))),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authService.signOut();
    result.fold(
      (failure) => emit(AuthError(_getErrorMessage(failure))),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  String _getErrorMessage(failure) {
    if (failure is UnexpectedFailure) {
      return failure.message;
    }
    return failure.toString();
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
