import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/bloc/theme/theme_bloc.dart';
import 'package:mpitana/screens/profile/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen should build without errors', (WidgetTester tester) async {
    // Build the ProfileScreen wrapped with necessary BLoC providers
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(),
          child: const ProfileScreen(),
        ),
      ),
    );

    // Verify that the ProfileScreen builds without throwing any errors
    expect(find.byType(ProfileScreen), findsOneWidget);
    
    // Verify that the theme switch is present
    expect(find.byType(Switch), findsWidgets);
  });

  testWidgets('ProfileScreen theme switch should work', (WidgetTester tester) async {
    final themeBloc = ThemeBloc();
    
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ThemeBloc>.value(
          value: themeBloc,
          child: const ProfileScreen(),
        ),
      ),
    );

    // Find the theme switch
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsAtLeastNWidgets(1));

    // Tap the switch (this should trigger the ThemeBloc event)
    await tester.tap(switchFinder.first);
    await tester.pump();

    // The test passes if no exceptions are thrown
    expect(find.byType(ProfileScreen), findsOneWidget);
    
    themeBloc.close();
  });
}
