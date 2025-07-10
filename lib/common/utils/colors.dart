
import 'package:flutter/material.dart';

// Light color scheme
const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Colors.red, // Changed to red
  onPrimary: Colors.white,
  secondary: Color(0xFF03DAC6), // A teal color for secondary actions
  onSecondary: Colors.black,
  error: Color(0xFFB00020),
  onError: Colors.white,
  background: Colors.white,
  onBackground: Colors.black,
  surface: Colors.white,
  onSurface: Colors.black,
);

// Dark color scheme
const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Colors.redAccent, // Changed to redAccent for dark mode
  onPrimary: Colors.black,
  secondary: Color(0xFF03DAC6), // Same teal for consistency
  onSecondary: Colors.black,
  error: Color(0xFFCF6679),
  onError: Colors.black,
  background: Color(0xFF121212), // Dark background
  onBackground: Colors.white,
  surface: Color(0xFF1E1E1E), // Darker surface
  onSurface: Colors.white,
); 