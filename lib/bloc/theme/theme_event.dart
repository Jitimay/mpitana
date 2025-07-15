import 'package:flutter/material.dart';

abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {
  final ThemeMode themeMode;
  
  ToggleThemeEvent({required this.themeMode});
}

class SystemThemeEvent extends ThemeEvent {}
