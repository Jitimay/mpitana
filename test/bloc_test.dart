import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mpitana/bloc/auth/auth_bloc.dart';
import 'package:mpitana/bloc/auth/auth_event.dart';
import 'package:mpitana/bloc/auth/auth_state.dart';
import 'package:mpitana/bloc/theme/theme_bloc.dart';
import 'package:mpitana/bloc/theme/theme_event.dart';
import 'package:mpitana/bloc/theme/theme_state.dart';
import 'package:flutter/material.dart';

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;

    setUp(() {
      authBloc = AuthBloc();
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () => authBloc,
      act: (bloc) => bloc.add(LoginEvent(email: 'test@test.com', password: 'password')),
      wait: const Duration(seconds: 3), // Wait for async operation
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails with empty credentials',
      build: () => authBloc,
      act: (bloc) => bloc.add(LoginEvent(email: '', password: '')),
      wait: const Duration(seconds: 3), // Wait for async operation
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when logout is called',
      build: () => authBloc,
      act: (bloc) => bloc.add(LogoutEvent()),
      wait: const Duration(seconds: 2), // Wait for async operation
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );
  });

  group('ThemeBloc', () {
    late ThemeBloc themeBloc;

    setUp(() {
      themeBloc = ThemeBloc();
    });

    tearDown(() {
      themeBloc.close();
    });

    test('initial state is ThemeInitial', () {
      expect(themeBloc.state, isA<ThemeInitial>());
    });

    blocTest<ThemeBloc, ThemeState>(
      'emits [ThemeChanged] when theme is toggled to dark',
      build: () => themeBloc,
      act: (bloc) => bloc.add(ToggleThemeEvent(themeMode: ThemeMode.dark)),
      expect: () => [
        isA<ThemeChanged>().having((state) => state.themeMode, 'themeMode', ThemeMode.dark),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'emits [ThemeChanged] when theme is toggled to light',
      build: () => themeBloc,
      act: (bloc) => bloc.add(ToggleThemeEvent(themeMode: ThemeMode.light)),
      expect: () => [
        isA<ThemeChanged>().having((state) => state.themeMode, 'themeMode', ThemeMode.light),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'emits [ThemeChanged] when theme is set to system',
      build: () => themeBloc,
      act: (bloc) => bloc.add(SystemThemeEvent()),
      expect: () => [
        isA<ThemeChanged>().having((state) => state.themeMode, 'themeMode', ThemeMode.system),
      ],
    );
  });
}
