import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  UserProfile? _currentProfile;

  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdateProfileImageEvent>(_onUpdateProfileImage);
    on<UpdateNotificationSettingsEvent>(_onUpdateNotificationSettings);
    on<ChangePasswordEvent>(_onChangePassword);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onLoadProfile(LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: Replace with actual API call to load user profile
      if (_currentProfile == null) {
        _currentProfile = UserProfile(
          id: '123',
          name: 'John Doe',
          email: 'john.doe@example.com',
          phone: '+1234567890',
          bio: 'Love carpooling and meeting new people!',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          ridesOffered: 15,
          ridesTaken: 8,
          rating: 4.5,
          notificationSettings: NotificationSettings(
            rideNotifications: true,
            chatNotifications: true,
            emailNotifications: false,
          ),
        );
      }
      
      emit(ProfileLoaded(profile: _currentProfile!));
    } catch (e) {
      emit(ProfileError(message: 'Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Replace with actual API call to update profile
      if (_currentProfile != null) {
        _currentProfile = _currentProfile!.copyWith(
          name: event.name,
          email: event.email,
          phone: event.phone,
          bio: event.bio,
          profileImageUrl: event.profileImagePath,
        );
        
        emit(ProfileUpdated(
          profile: _currentProfile!,
          message: 'Profile updated successfully!',
        ));
      } else {
        emit(ProfileError(message: 'No profile found to update'));
      }
    } catch (e) {
      emit(ProfileError(message: 'Failed to update profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfileImage(UpdateProfileImageEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: Replace with actual API call to upload image
      if (_currentProfile != null) {
        _currentProfile = _currentProfile!.copyWith(
          profileImageUrl: event.imagePath,
        );
        
        emit(ProfileImageUpdated(imagePath: event.imagePath));
        emit(ProfileLoaded(profile: _currentProfile!));
      } else {
        emit(ProfileError(message: 'No profile found to update'));
      }
    } catch (e) {
      emit(ProfileError(message: 'Failed to update profile image: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettingsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: Replace with actual API call to update notification settings
      if (_currentProfile != null) {
        final newSettings = NotificationSettings(
          rideNotifications: event.rideNotifications,
          chatNotifications: event.chatNotifications,
          emailNotifications: event.emailNotifications,
        );
        
        _currentProfile = _currentProfile!.copyWith(
          notificationSettings: newSettings,
        );
        
        emit(NotificationSettingsUpdated(settings: newSettings));
        emit(ProfileLoaded(profile: _currentProfile!));
      } else {
        emit(ProfileError(message: 'No profile found to update'));
      }
    } catch (e) {
      emit(ProfileError(message: 'Failed to update notification settings: ${e.toString()}'));
    }
  }

  Future<void> _onChangePassword(ChangePasswordEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Replace with actual API call to change password
      // Validate current password and update with new password
      
      emit(PasswordChanged(message: 'Password changed successfully!'));
      
      if (_currentProfile != null) {
        emit(ProfileLoaded(profile: _currentProfile!));
      }
    } catch (e) {
      emit(ProfileError(message: 'Failed to change password: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteAccount(DeleteAccountEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Replace with actual API call to delete account
      // This should also clear all user data
      
      _currentProfile = null;
      emit(AccountDeleted());
    } catch (e) {
      emit(ProfileError(message: 'Failed to delete account: ${e.toString()}'));
    }
  }
}
