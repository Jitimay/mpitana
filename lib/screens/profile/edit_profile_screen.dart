import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/bloc/profile/profile_bloc.dart';
import 'package:mpitana/bloc/profile/profile_event.dart';
import 'package:mpitana/screens/profile/models/user_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final BlocUserProfile profile;
  
  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  
  String? _profileImagePath;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _bioController = TextEditingController(text: widget.profile.bio);
    _profileImagePath = widget.profile.profileImageUrl;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    try {
      // Simple approach with two buttons
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select Image Source'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  _getImageFromSource(ImageSource.camera);
                },
                child: const Row(
                  children: [
                    Icon(Icons.camera_alt),
                    SizedBox(width: 10),
                    Text('Camera'),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  _getImageFromSource(ImageSource.gallery);
                },
                child: const Row(
                  children: [
                    Icon(Icons.photo_library),
                    SizedBox(width: 10),
                    Text('Gallery'),
                  ],
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showSnackBar('Failed to show image picker: $e', Colors.red);
    }
  }
  
  Future<void> _getImageFromSource(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 600,
      );
      
      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
        });
        
        context.read<ProfileBloc>().add(
          UpdateProfileImageEvent(imagePath: image.path),
        );
        
        _showSnackBar('Profile image updated', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      context.read<ProfileBloc>().add(
        UpdateProfileEvent(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          bio: _bioController.text,
          profileImagePath: _profileImagePath,
        ),
      );
      
      setState(() {
        _isLoading = false;
      });
      
      Navigator.pop(context);
    }
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Image
                Center(
                  child: Stack(
                    children: [
                      _buildProfileImage(_profileImagePath),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            color: Theme.of(context).colorScheme.onPrimary,
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Bio Field
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  maxLength: 200,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileImage(String? imageUrl) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: imageUrl == null || imageUrl.isEmpty
            ? Icon(
                Icons.person,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              )
            : imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
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
                              return Icon(
                                Icons.person,
                                size: 60,
                                color: Theme.of(context).colorScheme.primary,
                              );
                            },
                          );
                        } else {
                          return Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).colorScheme.primary,
                          );
                        }
                      } catch (e) {
                        return Icon(
                          Icons.person,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        );
                      }
                    },
                  ),
      ),
    );
  }
}
