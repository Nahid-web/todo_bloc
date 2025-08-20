import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/logging/app_logger.dart';

// Events
abstract class ThemeEvent {}

class ThemeChanged extends ThemeEvent {
  final ThemeMode themeMode;
  ThemeChanged(this.themeMode);
}

class ThemeInitialized extends ThemeEvent {}

// States
class ThemeState {
  final ThemeMode themeMode;
  final bool isLoading;

  const ThemeState({
    required this.themeMode,
    this.isLoading = false,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isLoading,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences sharedPreferences;
  static const String _themeKey = 'theme_mode';

  ThemeBloc({required this.sharedPreferences})
      : super(const ThemeState(themeMode: ThemeMode.system)) {
    AppLogger.logBloc('ThemeBloc', 'Initializing ThemeBloc');

    on<ThemeInitialized>(_onThemeInitialized);
    on<ThemeChanged>(_onThemeChanged);

    add(ThemeInitialized());
  }

  Future<void> _onThemeInitialized(
    ThemeInitialized event,
    Emitter<ThemeState> emit,
  ) async {
    AppLogger.logBloc(
      'ThemeBloc',
      'ThemeInitialized',
      previousState: state.themeMode.name,
    );

    try {
      final savedTheme = sharedPreferences.getString(_themeKey);
      ThemeMode themeMode = ThemeMode.system;

      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            themeMode = ThemeMode.light;
            break;
          case 'dark':
            themeMode = ThemeMode.dark;
            break;
          case 'system':
            themeMode = ThemeMode.system;
            break;
        }
      }

      AppLogger.logBloc(
        'ThemeBloc',
        'ThemeInitialized',
        newState: themeMode.name,
        eventData: {'savedTheme': savedTheme ?? 'none'},
      );

      emit(state.copyWith(themeMode: themeMode));
    } catch (e) {
      AppLogger.logBloc(
        'ThemeBloc',
        'ThemeInitialized',
        error: e.toString(),
      );
    }
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    AppLogger.logBloc(
      'ThemeBloc',
      'ThemeChanged',
      previousState: state.themeMode.name,
      newState: event.themeMode.name,
    );

    try {
      emit(state.copyWith(isLoading: true));

      await sharedPreferences.setString(_themeKey, event.themeMode.name);

      AppLogger.logApp(
        'Theme changed and saved to preferences',
        category: 'THEME',
        data: {
          'previousTheme': state.themeMode.name,
          'newTheme': event.themeMode.name,
        },
      );

      emit(state.copyWith(
        themeMode: event.themeMode,
        isLoading: false,
      ));
    } catch (e) {
      AppLogger.logBloc(
        'ThemeBloc',
        'ThemeChanged',
        error: e.toString(),
      );

      emit(state.copyWith(isLoading: false));
    }
  }
}
