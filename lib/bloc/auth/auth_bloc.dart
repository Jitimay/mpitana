import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<SignUpEvent>(_onSignUp);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Replace with actual authentication logic
      if (event.email.isNotEmpty && event.password.isNotEmpty) {
        emit(AuthAuthenticated(
          userId: '123',
          email: event.email,
          name: 'User Name', // This should come from your backend
        ));
      } else {
        emit(AuthError(message: 'Please fill in all fields'));
      }
    } catch (e) {
      emit(AuthError(message: 'Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Replace with actual sign up logic
      if (event.email.isNotEmpty && 
          event.password.isNotEmpty && 
          event.name.isNotEmpty && 
          event.phone.isNotEmpty) {
        emit(AuthAuthenticated(
          userId: '123',
          email: event.email,
          name: event.name,
        ));
      } else {
        emit(AuthError(message: 'Please fill in all fields'));
      }
    } catch (e) {
      emit(AuthError(message: 'Sign up failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      // TODO: Clear stored tokens/data
      await Future.delayed(const Duration(seconds: 1));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Logout failed: ${e.toString()}'));
    }
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      // TODO: Check if user is already logged in (check stored tokens)
      await Future.delayed(const Duration(seconds: 1));
      
      // For now, assume user is not authenticated
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Failed to check auth status'));
    }
  }
}
