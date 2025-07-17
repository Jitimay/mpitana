import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/bloc/profile/profile_bloc.dart';
import 'package:mpitana/bloc/ride/ride_bloc.dart';
import 'package:mpitana/common/database/objectbox_db.dart';
import 'package:mpitana/common/utils/colors.dart';
import 'package:mpitana/screens/auth/login_screen.dart';
import 'package:mpitana/bloc/app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize ObjectBox
  await ObjectBoxDb.instance;
  
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<RideBloc>(
          create: (context) => RideBloc(),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(),
        ),
        // Add other BlocProviders here as needed
      ],
      child: MaterialApp(
        home: LoginPage(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: lightColorScheme,
        ), // Light theme
        darkTheme: ThemeData(
          colorScheme: darkColorScheme,
        ), // Dark theme
        themeMode: _themeMode, // Use the current theme mode
      ),
    );
  }
  
  @override
  void dispose() {
    // Close ObjectBox when app is terminated
    ObjectBoxDb.close();
    super.dispose();
  }
}
