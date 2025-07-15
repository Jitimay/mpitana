import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeInitial()) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SystemThemeEvent>(_onSystemTheme);
  }

  void _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) {
    emit(ThemeChanged(themeMode: event.themeMode));
  }

  void _onSystemTheme(SystemThemeEvent event, Emitter<ThemeState> emit) {
    emit(const ThemeChanged(themeMode: ThemeMode.system));
  }
}
