
import 'package:flutter/material.dart';

// Light color scheme
const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Colors.red, // Primary color
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFFFDAD6), // Light red for containers
  onPrimaryContainer: Color(0xFF410002), // Dark text on light red
  secondary: Color(0xFF03DAC6), // A teal color for secondary actions
  onSecondary: Colors.black,
  secondaryContainer: Color(0xFFCEFAF5), // Light teal for containers
  onSecondaryContainer: Color(0xFF002021), // Dark text on light teal
  error: Color(0xFFB00020),
  onError: Colors.white,
  background: Colors.white,
  onBackground: Colors.black,
  surface: Colors.white,
  onSurface: Colors.black,
  surfaceVariant: Color(0xFFF5F5F5), // Light gray for surface variants
  onSurfaceVariant: Color(0xFF49454F), // Dark gray for text on surface variants
  outline: Color(0xFF79747E), // Gray for outlines
);

// Dark color scheme
const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Colors.redAccent, // Brighter red for dark mode
  onPrimary: Colors.black,
  primaryContainer: Color(0xFF930006), // Darker red for containers
  onPrimaryContainer: Color(0xFFFFDAD6), // Light text on dark red
  secondary: Color(0xFF03DAC6), // Same teal for consistency
  onSecondary: Colors.black,
  secondaryContainer: Color(0xFF004F4F), // Darker teal for containers
  onSecondaryContainer: Color(0xFFCEFAF5), // Light text on dark teal
  error: Color(0xFFCF6679),
  onError: Colors.black,
  background: Color(0xFF121212), // Dark background
  onBackground: Colors.white,
  surface: Color(0xFF1E1E1E), // Darker surface
  onSurface: Colors.white,
  surfaceVariant: Color(0xFF2C2C2C), // Dark gray for surface variants
  onSurfaceVariant: Color(0xFFCAC4D0), // Light gray for text on surface variants
  outline: Color(0xFF938F99), // Light gray for outlines
); 