import 'package:mpitana/screens/profile/models/user_profile.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final BlocUserProfile profile;
  
  ProfileLoaded({required this.profile});
}

class ProfileUpdated extends ProfileState {
  final BlocUserProfile profile;
  final String message;
  
  ProfileUpdated({
    required this.profile,
    required this.message,
  });
}

class ProfileImageUpdated extends ProfileState {
  final String imagePath;
  
  ProfileImageUpdated({required this.imagePath});
}

class NotificationSettingsUpdated extends ProfileState {
  final NotificationSettings settings;
  
  NotificationSettingsUpdated({required this.settings});
}

class PasswordChanged extends ProfileState {
  final String message;
  
  PasswordChanged({required this.message});
}

class AccountDeleted extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  
  ProfileError({required this.message});
}
