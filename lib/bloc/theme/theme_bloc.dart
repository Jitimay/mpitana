import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/common/services/preferences_service.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeInitial()) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SystemThemeEvent>(_onSystemTheme);
    on<InitThemeEvent>(_onInitTheme);
    
    // Initialize theme from preferences
    add(InitThemeEvent());
  }

  void _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    // Save theme preference
    await PreferencesService.saveThemeMode(event.themeMode);
    emit(ThemeChanged(themeMode: event.themeMode));
  }

  void _onSystemTheme(SystemThemeEvent event, Emitter<ThemeState> emit) async {
    // Save system theme preference
    await PreferencesService.saveThemeMode(ThemeMode.system);
    emit(const ThemeChanged(themeMode: ThemeMode.system));
  }
  
  void _onInitTheme(InitThemeEvent event, Emitter<ThemeState> emit) async {
    // Load saved theme preference
    final themeMode = await PreferencesService.getThemeMode();
    emit(ThemeChanged(themeMode: themeMode));
  }
}
