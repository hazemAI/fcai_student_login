import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../utils/validators.dart';
import '../utils/platform_utils.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();

  String? _gender;
  int? _level;
  bool _isEditing = false;
  bool _isLoading = false;
  String? _profilePhotoPath;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _studentIdController.text = user.studentId;
      _gender = user.gender;
      _level = user.level;
      _profilePhotoPath = user.profilePhoto;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Use platform-specific image picker
      final pickedFile = await PlatformUtils.pickImage(source);

      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
        });

        // Save the image to app storage for persistence
        final savedImagePath = await PlatformUtils.saveImageToAppStorage(
          pickedFile.path,
        );
        final normalizedPath = PlatformUtils.normalizePath(savedImagePath);

        // Update the user profile with the saved image path
        final success = await Provider.of<UserProvider>(
          context,
          listen: false,
        ).updateProfilePhoto(normalizedPath);

        if (success) {
          setState(() {
            _profilePhotoPath = normalizedPath;
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile photo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImageSourceDialog() {
    if (Platform.isWindows) {
      // Show dialog with options for Windows
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Select Image Source'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Camera'),
                    subtitle: const Text(
                      'Not supported on most Windows systems',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // Show a message about camera limitations on Windows
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Camera may not work on Windows. If it fails, the gallery will open instead.',
                          ),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
      );
    } else {
      // On Android, show dialog with camera and gallery options
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Select Image Source'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Camera'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final currentUser =
            Provider.of<UserProvider>(context, listen: false).currentUser;
        if (currentUser != null) {
          final updatedUser = User(
            id: currentUser.id,
            name: _nameController.text,
            gender: _gender,
            email: _emailController.text,
            studentId: _studentIdController.text,
            level: _level,
            password: currentUser.password,
            profilePhoto: _profilePhotoPath,
          );

          final success = await Provider.of<UserProvider>(
            context,
            listen: false,
          ).updateProfile(updatedUser);

          if (success) {
            setState(() {
              _isEditing = false;
            });

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update profile'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _logout() {
    Provider.of<UserProvider>(context, listen: false).logout();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Widget _buildProfileImage() {
    try {
      if (_pickedImage != null) {
        return CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          backgroundImage: FileImage(File(_pickedImage!.path)),
        );
      } else if (_profilePhotoPath != null && _profilePhotoPath!.isNotEmpty) {
        final file = File(_profilePhotoPath!);
        if (file.existsSync()) {
          return CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage: FileImage(file),
          );
        } else {
          // Fallback if file doesn't exist
          return CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 60, color: Colors.grey),
          );
        }
      } else {
        return CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, size: 60, color: Colors.grey),
        );
      }
    } catch (e) {
      // Fallback on error
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.error, size: 60, color: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user logged in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _updateProfile,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _isEditing ? _showImageSourceDialog : null,
                child: Stack(
                  children: [
                    _buildProfileImage(),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),

              // Gender selection
              if (_isEditing) ...[
                const Text('Gender (Optional)', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Male'),
                        value: 'Male',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Female'),
                        value: 'Female',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                ListTile(
                  title: const Text('Gender'),
                  subtitle: Text(_gender ?? 'Not specified'),
                  leading: const Icon(Icons.person_outline),
                ),
              ],
              const SizedBox(height: 16),

              // Email field (read-only)
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                enabled: false, // Email cannot be changed
              ),
              const SizedBox(height: 16),

              // Student ID field (read-only)
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                enabled: false, // Student ID cannot be changed
              ),
              const SizedBox(height: 16),

              // Level selection
              if (_isEditing) ...[
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Level (Optional)',
                    prefixIcon: Icon(Icons.school),
                    border: OutlineInputBorder(),
                  ),
                  value: _level,
                  items:
                      [1, 2, 3, 4].map((level) {
                        return DropdownMenuItem<int>(
                          value: level,
                          child: Text('Level $level'),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _level = value;
                    });
                  },
                ),
              ] else ...[
                ListTile(
                  title: const Text('Level'),
                  subtitle: Text(
                    _level != null ? 'Level $_level' : 'Not specified',
                  ),
                  leading: const Icon(Icons.school),
                ),
              ],

              if (_isLoading) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
