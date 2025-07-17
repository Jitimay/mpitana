import 'package:objectbox/objectbox.dart';

@Entity()
class UserProfile {
  @Id()
  int id;
  
  String userId;
  String name;
  String email;
  String phone;
  String bio;
  String? profileImageUrl;
  int createdAtTimestamp; // Store as timestamp for ObjectBox
  int ridesOffered;
  int ridesTaken;
  double rating;
  
  // Notification settings
  bool rideNotifications;
  bool chatNotifications;
  bool emailNotifications;

  UserProfile({
    this.id = 0,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.bio = '',
    this.profileImageUrl,
    DateTime? createdAt,
    this.ridesOffered = 0,
    this.ridesTaken = 0,
    this.rating = 0.0,
    this.rideNotifications = true,
    this.chatNotifications = true,
    this.emailNotifications = false,
  }) : createdAtTimestamp = (createdAt ?? DateTime.now()).millisecondsSinceEpoch;

  // Convert timestamp to DateTime
  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtTimestamp);

  // Helper method to create a copy with updated fields
  UserProfile copyWith({
    int? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? profileImageUrl,
    DateTime? createdAt,
    int? ridesOffered,
    int? ridesTaken,
    double? rating,
    bool? rideNotifications,
    bool? chatNotifications,
    bool? emailNotifications,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      ridesOffered: ridesOffered ?? this.ridesOffered,
      ridesTaken: ridesTaken ?? this.ridesTaken,
      rating: rating ?? this.rating,
      rideNotifications: rideNotifications ?? this.rideNotifications,
      chatNotifications: chatNotifications ?? this.chatNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
    );
  }

  // Convert to the UserProfile class used in the BLoC
  toBloc() {
    return BlocUserProfile(
      id: userId,
      name: name,
      email: email,
      phone: phone,
      bio: bio,
      profileImageUrl: profileImageUrl,
      createdAt: createdAt,
      ridesOffered: ridesOffered,
      ridesTaken: ridesTaken,
      rating: rating,
      notificationSettings: NotificationSettings(
        rideNotifications: rideNotifications,
        chatNotifications: chatNotifications,
        emailNotifications: emailNotifications,
      ),
    );
  }

  // Create from the BLoC UserProfile
  static UserProfile fromBloc(BlocUserProfile profile) {
    return UserProfile(
      userId: profile.id,
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
      bio: profile.bio,
      profileImageUrl: profile.profileImageUrl,
      createdAt: profile.createdAt,
      ridesOffered: profile.ridesOffered,
      ridesTaken: profile.ridesTaken,
      rating: profile.rating,
      rideNotifications: profile.notificationSettings.rideNotifications,
      chatNotifications: profile.notificationSettings.chatNotifications,
      emailNotifications: profile.notificationSettings.emailNotifications,
    );
  }
}

// These classes are used to maintain compatibility with the existing BLoC implementation
class BlocUserProfile {
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

  BlocUserProfile({
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

  BlocUserProfile copyWith({
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
    return BlocUserProfile(
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
