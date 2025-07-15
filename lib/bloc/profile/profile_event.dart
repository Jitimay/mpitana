abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String? profileImagePath;
  
  UpdateProfileEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    this.profileImagePath,
  });
}

class UpdateProfileImageEvent extends ProfileEvent {
  final String imagePath;
  
  UpdateProfileImageEvent({required this.imagePath});
}

class UpdateNotificationSettingsEvent extends ProfileEvent {
  final bool rideNotifications;
  final bool chatNotifications;
  final bool emailNotifications;
  
  UpdateNotificationSettingsEvent({
    required this.rideNotifications,
    required this.chatNotifications,
    required this.emailNotifications,
  });
}

class DeleteAccountEvent extends ProfileEvent {}

class ChangePasswordEvent extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  
  ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });
}
