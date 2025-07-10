import 'package:flutter/material.dart';
import 'package:mpitana/screens/home/home_screen.dart';
import 'package:mpitana/common/utils/colors.dart'; // Import the new colors file

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // Initial theme mode

  void toggleTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: lightColorScheme,
      ), // Light theme
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
      ), // Dark theme
      themeMode: _themeMode, // Use the current theme mode
    );
  }
}