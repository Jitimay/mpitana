import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/bloc/profile/profile_bloc.dart';
import 'package:mpitana/bloc/profile/profile_event.dart';
import 'package:mpitana/bloc/profile/profile_state.dart';
import 'package:mpitana/bloc/theme/theme_bloc.dart';
import 'package:mpitana/bloc/theme/theme_event.dart';
import 'package:mpitana/bloc/theme/theme_state.dart';
import 'package:mpitana/screens/profile/models/user_profile.dart';
import 'package:mpitana/screens/profile/edit_profile_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLocationEnabled = false;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    
    // Load profile data when screen initializes
    context.read<ProfileBloc>().add(LoadProfileEvent());
  }

  Future<void> _checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      setState(() {
        _isLocationEnabled = status == PermissionStatus.granted;
        _isCheckingPermission = false;
      });
    } catch (e) {
      setState(() {
        _isCheckingPermission = false;
      });
      debugPrint("Error checking location permission: $e");
    }
  }

  Future<void> _toggleLocationPermission(bool value) async {
    if (value) {
      // Request permission
      final status = await Permission.location.request();
      
      setState(() {
        _isLocationEnabled = status == PermissionStatus.granted;
      });

      if (status == PermissionStatus.granted) {
        _showSnackBar('Location permission granted!', Colors.green);
      } else {
        if (status == PermissionStatus.permanentlyDenied) {
          _showPermissionDeniedDialog();
        } else {
          _showSnackBar('Location permission denied', Colors.red);
        }
      }
    } else {
      // Can't revoke permission programmatically, show dialog
      _showRevokePermissionDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Location permission is permanently denied. Please enable it in app settings to use location features.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showRevokePermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Revoke Location Permission'),
          content: const Text(
            'To disable location access, please go to your device settings and revoke the location permission for this app.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToEditProfile(BlocUserProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: profile),
      ),
    ).then((_) {
      // Reload profile when returning from edit screen
      context.read<ProfileBloc>().add(LoadProfileEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToEditProfile(state.profile),
                  tooltip: 'Edit Profile',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            _showSnackBar(state.message, Colors.red);
          } else if (state is ProfileUpdated) {
            _showSnackBar(state.message, Colors.green);
          } else if (state is PasswordChanged) {
            _showSnackBar(state.message, Colors.green);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            return _buildProfileContent(state.profile);
          } else if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(LoadProfileEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          // Initial state or other states
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildProfileContent(BlocUserProfile profile) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Image
                  _buildProfileImage(profile.profileImageUrl),
                  const SizedBox(height: 16),
                  Text(
                    profile.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Rides Offered', profile.ridesOffered.toString()),
                      _buildStatItem('Rides Taken', profile.ridesTaken.toString()),
                      _buildStatItem('Rating', profile.rating.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Bio
                  if (profile.bio.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.bio,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Settings Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Location Permission Toggle
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: _isLocationEnabled 
                              ? Theme.of(context).colorScheme.primary 
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location Access',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isLocationEnabled
                                    ? 'Allow app to access your location'
                                    : 'Location access is disabled',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isCheckingPermission)
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        else
                          Switch(
                            value: _isLocationEnabled,
                            onChanged: _toggleLocationPermission,
                            activeColor: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Notification Settings
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notification Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildNotificationToggle(
                          'Ride Updates',
                          profile.notificationSettings.rideNotifications,
                          (value) {
                            context.read<ProfileBloc>().add(
                              UpdateNotificationSettingsEvent(
                                rideNotifications: value,
                                chatNotifications: profile.notificationSettings.chatNotifications,
                                emailNotifications: profile.notificationSettings.emailNotifications,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildNotificationToggle(
                          'Chat Messages',
                          profile.notificationSettings.chatNotifications,
                          (value) {
                            context.read<ProfileBloc>().add(
                              UpdateNotificationSettingsEvent(
                                rideNotifications: profile.notificationSettings.rideNotifications,
                                chatNotifications: value,
                                emailNotifications: profile.notificationSettings.emailNotifications,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildNotificationToggle(
                          'Email Notifications',
                          profile.notificationSettings.emailNotifications,
                          (value) {
                            context.read<ProfileBloc>().add(
                              UpdateNotificationSettingsEvent(
                                rideNotifications: profile.notificationSettings.rideNotifications,
                                chatNotifications: profile.notificationSettings.chatNotifications,
                                emailNotifications: value,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Theme Mode Settings
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.palette,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Theme Mode',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<ThemeBloc, ThemeState>(
                          builder: (context, state) {
                            return Column(
                              children: [
                                _buildThemeOption(
                                  context: context,
                                  title: 'Light Mode',
                                  icon: Icons.light_mode,
                                  iconColor: Colors.orange,
                                  isSelected: state.themeMode == ThemeMode.light,
                                  onTap: () {
                                    context.read<ThemeBloc>().add(
                                      ToggleThemeEvent(themeMode: ThemeMode.light),
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                _buildThemeOption(
                                  context: context,
                                  title: 'Dark Mode',
                                  icon: Icons.dark_mode,
                                  iconColor: Colors.amber,
                                  isSelected: state.themeMode == ThemeMode.dark,
                                  onTap: () {
                                    context.read<ThemeBloc>().add(
                                      ToggleThemeEvent(themeMode: ThemeMode.dark),
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                _buildThemeOption(
                                  context: context,
                                  title: 'System Default',
                                  icon: Icons.settings_suggest,
                                  iconColor: Theme.of(context).colorScheme.primary,
                                  isSelected: state.themeMode == ThemeMode.system,
                                  onTap: () {
                                    context.read<ThemeBloc>().add(
                                      SystemThemeEvent(),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Account Settings
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Change Password
                  _buildSettingItem(
                    context,
                    Icons.lock,
                    'Change Password',
                    () => _showChangePasswordDialog(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Delete Account
                  _buildSettingItem(
                    context,
                    Icons.delete_forever,
                    'Delete Account',
                    () => _showDeleteAccountDialog(),
                    textColor: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationToggle(String title, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
    {Color? textColor} // Optional text color
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
  
  ImageProvider _getProfileImage(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else {
      try {
        final file = File(path);
        if (file.existsSync()) {
          return FileImage(file);
        } else {
          // Fallback to a default image if file doesn't exist
          throw Exception('File does not exist');
        }
      } catch (e) {
        debugPrint('Error loading profile image: $e');
        // Return a default network image as fallback
        throw Exception('Could not load image');
      }
    }
  }
  
  Widget _buildProfileImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.person,
          size: 50,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 100,
        height: 100,
        child: imageUrl.startsWith('http')
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / 
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              )
            : Builder(
                builder: (context) {
                  try {
                    final file = File(imageUrl);
                    if (file.existsSync()) {
                      return Image.file(
                        file,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          );
                        },
                      );
                    } else {
                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      );
                    }
                  } catch (e) {
                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? iconColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newPasswordController.text != confirmPasswordController.text) {
                  _showSnackBar('New passwords do not match', Colors.red);
                  return;
                }
                
                if (newPasswordController.text.length < 6) {
                  _showSnackBar('Password must be at least 6 characters', Colors.red);
                  return;
                }
                
                context.read<ProfileBloc>().add(
                  ChangePasswordEvent(
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                  ),
                );
                
                Navigator.of(context).pop();
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<ProfileBloc>().add(DeleteAccountEvent());
                Navigator.of(context).pop();
                // In a real app, you would navigate to login screen after account deletion
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
