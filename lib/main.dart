import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/bloc/profile/profile_bloc.dart';
import 'package:mpitana/bloc/ride/ride_bloc.dart';
import 'package:mpitana/bloc/theme/theme_bloc.dart';
import 'package:mpitana/bloc/theme/theme_state.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(),
        ),
        // Add other BlocProviders here as needed
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            home: LoginPage(),
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: lightColorScheme,
              useMaterial3: true,
            ), // Light theme
            darkTheme: ThemeData(
              colorScheme: darkColorScheme,
              useMaterial3: true,
            ), // Dark theme
            themeMode: themeState.themeMode, // Use the current theme mode from bloc
          );
        },
      ),
    );
  }
}
