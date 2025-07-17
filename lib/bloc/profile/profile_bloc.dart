import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/common/database/objectbox_db.dart';
import 'package:mpitana/screens/profile/models/user_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  BlocUserProfile? _currentProfile;
  String _currentUserId = "current_user"; // This would come from auth service in a real app

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
      // Load profile from database
      final dbProfile = await ObjectBoxDb.getUserProfileByUserId(_currentUserId);
      
      if (dbProfile != null) {
        // Convert to BLoC model
        _currentProfile = dbProfile.toBloc();
        emit(ProfileLoaded(profile: _currentProfile!));
      } else {
        // Create default profile if none exists
        final defaultProfile = UserProfile(
          userId: _currentUserId,
          name: 'John Doe',
          email: 'john.doe@example.com',
          phone: '+1234567890',
          bio: 'Love carpooling and meeting new people!',
          createdAt: DateTime.now(),
          ridesOffered: 0,
          ridesTaken: 0,
          rating: 0.0,
          rideNotifications: true,
          chatNotifications: true,
          emailNotifications: false,
        );
        
        // Save to database
        await ObjectBoxDb.saveUserProfile(defaultProfile);
        
        // Convert to BLoC model
        _currentProfile = defaultProfile.toBloc();
        emit(ProfileLoaded(profile: _currentProfile!));
      }
    } catch (e) {
      emit(ProfileError(message: 'Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    try {
      // Get current profile from database
      final dbProfile = await ObjectBoxDb.getUserProfileByUserId(_currentUserId);
      
      if (dbProfile != null) {
        // Update profile
        final updatedProfile = dbProfile.copyWith(
          name: event.name,
          email: event.email,
          phone: event.phone,
          bio: event.bio,
          profileImageUrl: event.profileImagePath,
        );
        
        // Save to database
        await ObjectBoxDb.saveUserProfile(updatedProfile);
        
        // Update current profile
        _currentProfile = updatedProfile.toBloc();
        
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
      // Get current profile from database
      final dbProfile = await ObjectBoxDb.getUserProfileByUserId(_currentUserId);
      
      if (dbProfile != null) {
        // Update profile image
        final updatedProfile = dbProfile.copyWith(
          profileImageUrl: event.imagePath,
        );
        
        // Save to database
        await ObjectBoxDb.saveUserProfile(updatedProfile);
        
        // Update current profile
        _currentProfile = updatedProfile.toBloc();
        
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
      // Get current profile from database
      final dbProfile = await ObjectBoxDb.getUserProfileByUserId(_currentUserId);
      
      if (dbProfile != null) {
        // Update notification settings
        final updatedProfile = dbProfile.copyWith(
          rideNotifications: event.rideNotifications,
          chatNotifications: event.chatNotifications,
          emailNotifications: event.emailNotifications,
        );
        
        // Save to database
        await ObjectBoxDb.saveUserProfile(updatedProfile);
        
        // Update current profile
        _currentProfile = updatedProfile.toBloc();
        
        final newSettings = NotificationSettings(
          rideNotifications: event.rideNotifications,
          chatNotifications: event.chatNotifications,
          emailNotifications: event.emailNotifications,
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
      // In a real app, this would call an authentication service
      // For now, we'll just simulate a successful password change
      await Future.delayed(const Duration(seconds: 1));
      
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
      // Delete profile from database
      await ObjectBoxDb.deleteUserProfileByUserId(_currentUserId);
      
      // In a real app, this would also delete the user from authentication service
      
      _currentProfile = null;
      emit(AccountDeleted());
    } catch (e) {
      emit(ProfileError(message: 'Failed to delete account: ${e.toString()}'));
    }
  }
}
