import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/create_user_with_email_and_password.dart'
    as create_user_usecase;
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_anonymously.dart' as sign_in_anon_usecase;
import '../../domain/usecases/sign_in_with_email_and_password.dart'
    as sign_in_email_usecase;
import '../../domain/usecases/sign_out.dart' as sign_out_usecase;
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final sign_in_anon_usecase.SignInAnonymously signInAnonymouslyUseCase;
  final sign_in_email_usecase.SignInWithEmailAndPassword
  signInWithEmailAndPasswordUseCase;
  final create_user_usecase.CreateUserWithEmailAndPassword
  createUserWithEmailAndPasswordUseCase;
  final sign_out_usecase.SignOut signOutUseCase;
  final GetCurrentUser getCurrentUserUseCase;
  final AuthRepository authRepository;
  late StreamSubscription<User?> _authSubscription;

  AuthBloc({
    required this.signInAnonymouslyUseCase,
    required this.signInWithEmailAndPasswordUseCase,
    required this.createUserWithEmailAndPasswordUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    AppLogger.logBloc('AuthBloc', 'Initializing AuthBloc');

    on<AuthStarted>(_onAuthStarted);
    on<SignInAnonymously>(_onSignInAnonymously);
    on<SignInWithEmailAndPassword>(_onSignInWithEmailAndPassword);
    on<CreateUserWithEmailAndPassword>(_onCreateUserWithEmailAndPassword);
    on<SignOut>(_onSignOut);

    // Listen to auth state changes
    _authSubscription = authRepository.authStateChanges.listen((user) {
      AppLogger.logBloc(
        'AuthBloc',
        'Auth state changed',
        eventData: {
          'hasUser': user != null,
          'userId': user?.id,
          'isAnonymous': user?.isAnonymous,
        },
      );

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
    AppLogger.logBloc(
      'AuthBloc',
      'AuthStarted',
      previousState: state.toString(),
    );

    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (failure) {
        AppLogger.logBloc(
          'AuthBloc',
          'AuthStarted',
          newState: 'AuthUnauthenticated',
          error: failure.toString(),
        );
        emit(AuthUnauthenticated());
      },
      (user) {
        if (user != null) {
          AppLogger.logBloc(
            'AuthBloc',
            'AuthStarted',
            newState: 'AuthAuthenticated',
            eventData: {
              'userId': user.id,
              'email': user.email,
              'isAnonymous': user.isAnonymous,
            },
          );
          emit(AuthAuthenticated(user));
        } else {
          AppLogger.logBloc(
            'AuthBloc',
            'AuthStarted',
            newState: 'AuthUnauthenticated',
          );
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onSignInAnonymously(
    SignInAnonymously event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.logBloc(
      'AuthBloc',
      'SignInAnonymously',
      previousState: state.toString(),
    );

    emit(AuthLoading());
    final result = await signInAnonymouslyUseCase(NoParams());
    result.fold(
      (failure) {
        AppLogger.logBloc(
          'AuthBloc',
          'SignInAnonymously',
          newState: 'AuthError',
          error: _getErrorMessage(failure),
        );
        emit(AuthError(_getErrorMessage(failure)));
      },
      (user) {
        AppLogger.logBloc(
          'AuthBloc',
          'SignInAnonymously',
          newState: 'AuthAuthenticated',
          eventData: {'userId': user.id, 'isAnonymous': user.isAnonymous},
        );
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onSignInWithEmailAndPassword(
    SignInWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.logBloc(
      'AuthBloc',
      'SignInWithEmailAndPassword',
      previousState: state.toString(),
      eventData: {
        'email': event.email,
        'passwordLength': event.password.length,
      },
    );

    emit(AuthLoading());
    final result = await signInWithEmailAndPasswordUseCase(
      sign_in_email_usecase.SignInWithEmailAndPasswordParams(
        email: event.email,
        password: event.password,
      ),
    );
    result.fold(
      (failure) {
        AppLogger.logBloc(
          'AuthBloc',
          'SignInWithEmailAndPassword',
          newState: 'AuthError',
          eventData: {'email': event.email},
          error: _getErrorMessage(failure),
        );
        emit(AuthError(_getErrorMessage(failure)));
      },
      (user) {
        AppLogger.logBloc(
          'AuthBloc',
          'SignInWithEmailAndPassword',
          newState: 'AuthAuthenticated',
          eventData: {
            'userId': user.id,
            'email': user.email,
            'isAnonymous': user.isAnonymous,
          },
        );
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onCreateUserWithEmailAndPassword(
    CreateUserWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.logBloc(
      'AuthBloc',
      'CreateUserWithEmailAndPassword',
      previousState: state.toString(),
      eventData: {
        'email': event.email,
        'passwordLength': event.password.length,
      },
    );

    emit(AuthLoading());
    final result = await createUserWithEmailAndPasswordUseCase(
      create_user_usecase.CreateUserWithEmailAndPasswordParams(
        email: event.email,
        password: event.password,
      ),
    );
    result.fold(
      (failure) {
        AppLogger.logBloc(
          'AuthBloc',
          'CreateUserWithEmailAndPassword',
          newState: 'AuthError',
          eventData: {'email': event.email},
          error: _getErrorMessage(failure),
        );
        emit(AuthError(_getErrorMessage(failure)));
      },
      (user) {
        AppLogger.logBloc(
          'AuthBloc',
          'CreateUserWithEmailAndPassword',
          newState: 'AuthAuthenticated',
          eventData: {
            'userId': user.id,
            'email': user.email,
            'isAnonymous': user.isAnonymous,
          },
        );
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    AppLogger.logBloc('AuthBloc', 'SignOut', previousState: state.toString());

    emit(AuthLoading());
    final result = await signOutUseCase(NoParams());
    result.fold(
      (failure) {
        AppLogger.logBloc(
          'AuthBloc',
          'SignOut',
          newState: 'AuthError',
          error: _getErrorMessage(failure),
        );
        emit(AuthError(_getErrorMessage(failure)));
      },
      (_) {
        AppLogger.logBloc(
          'AuthBloc',
          'SignOut',
          newState: 'AuthUnauthenticated',
        );
        emit(AuthUnauthenticated());
      },
    );
  }

  String _getErrorMessage(failure) {
    // Extract message from failure object
    final failureString = failure.toString();
    if (failureString.contains('UnexpectedFailure(') &&
        failureString.contains(')')) {
      // Extract message from UnexpectedFailure(message) format
      final start = failureString.indexOf('(') + 1;
      final end = failureString.lastIndexOf(')');
      if (start < end) {
        return failureString.substring(start, end);
      }
    }
    return failureString;
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
