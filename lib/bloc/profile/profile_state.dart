class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String? profileImageUrl;
  final DateTime createdAt;
  final int ridesOffered;
  final int ridesTaken;
  final double rating;
  final NotificationSettings notificationSettings;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    this.profileImageUrl,
    required this.createdAt,
    this.ridesOffered = 0,
    this.ridesTaken = 0,
    this.rating = 0.0,
    required this.notificationSettings,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? profileImageUrl,
    DateTime? createdAt,
    int? ridesOffered,
    int? ridesTaken,
    double? rating,
    NotificationSettings? notificationSettings,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      ridesOffered: ridesOffered ?? this.ridesOffered,
      ridesTaken: ridesTaken ?? this.ridesTaken,
      rating: rating ?? this.rating,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
}

class NotificationSettings {
  final bool rideNotifications;
  final bool chatNotifications;
  final bool emailNotifications;

  NotificationSettings({
    required this.rideNotifications,
    required this.chatNotifications,
    required this.emailNotifications,
  });

  NotificationSettings copyWith({
    bool? rideNotifications,
    bool? chatNotifications,
    bool? emailNotifications,
  }) {
    return NotificationSettings(
      rideNotifications: rideNotifications ?? this.rideNotifications,
      chatNotifications: chatNotifications ?? this.chatNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
    );
  }
}

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  
  ProfileLoaded({required this.profile});
}

class ProfileUpdated extends ProfileState {
  final UserProfile profile;
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
