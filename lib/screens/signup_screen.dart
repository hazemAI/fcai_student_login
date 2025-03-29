import 'dart:io';
import 'package:fcai_student_login/screens/home_screen.dart';
import 'package:fcai_student_login/screens/login_screen.dart';
import 'package:fcai_student_login/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../utils/validators.dart';
import '../utils/image_utils.dart';
import '../components/index.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studentIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset provider state when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).resetState();
    });
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  void _pickImage(UserProvider userProvider) {
    ImageUtils.showImageSourceDialog(
      context,
      (File imageFile, String path) {
        userProvider.setProfileImage(imageFile, path);
      },
    );
  }

  Future<void> _signup(UserProvider userProvider) async {
    // Validate student ID matches email before form validation
    final studentIdEmailMatch = userProvider.validateStudentIdWithEmail(
      _studentIdController.text,
      _emailController.text,
    );

    if (studentIdEmailMatch != null) {
      userProvider.setErrorMessage(studentIdEmailMatch);
      return;
    }
    userProvider.setErrorMessage('');

    if (_formKey.currentState!.validate()) {
      try {
        // Create user object
        final user = User(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          studentId: _studentIdController.text,
          gender: userProvider.gender,
          level: userProvider.level,
          profilePhoto: userProvider.profileImagePath,
        );

        // Call signup method from provider with validation
        final result = await userProvider.signupWithValidation(
          user,
          _studentIdController.text,
          _emailController.text,
          context,
        );

        if (!mounted) return;

        if (result['success']) {
          // Navigate to profile screen on success
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // Show a snackbar for immediate feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;

        // Set error message in the provider
        userProvider.setErrorMessage('Error: $e');

        // Also show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final isLoading = userProvider.isLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Sign Up')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Image Picker
                  Center(
                    child: Column(
                      children: [
                        CustomImagePicker(
                          imageFile: userProvider.profileImageFile,
                          onTap: () => _pickImage(userProvider),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Profile Photo (Optional)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  CustomTextFormField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    prefixIcon: Icons.person,
                    validator: Validators.validateName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16.0),

                  // Gender selection (optional)
                  CustomRadioGroup<String>(
                    title: 'Gender',
                    groupValue: userProvider.gender,
                    options: const {'Male': 'Male', 'Female': 'Female'},
                    onChanged: (value) => userProvider.setGender(value),
                    isOptional: true,
                  ),
                  const SizedBox(height: 16.0),

                  CustomTextFormField(
                    controller: _emailController,
                    labelText: 'Email',
                    prefixIcon: Icons.email,
                    hintText: 'studentID@stud.fci-cu.edu.eg',
                    helperText: 'Student ID must match the part before @',
                    validator: Validators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16.0),

                  CustomTextFormField(
                    controller: _studentIdController,
                    labelText: 'Student ID',
                    prefixIcon: Icons.badge,
                    hintText: 'Must match ID in email',
                    helperText: 'Must match the part before @ in your email',
                    validator: Validators.validateStudentId,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16.0),

                  // Level selection (optional)
                  CustomDropdown<int>(
                    labelText: 'Level (Optional)',
                    prefixIcon: Icons.school,
                    value: userProvider.level,
                    hintText: 'Select your level',
                    items: [1, 2, 3, 4].map((level) {
                      return DropdownMenuItem<int>(
                        value: level,
                        child: Text('Level $level'),
                      );
                    }).toList(),
                    onChanged: (value) => userProvider.setLevel(value),
                  ),
                  const SizedBox(height: 16.0),

                  CustomPasswordField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'At least 8 characters with 1 number',
                    isVisible: userProvider.isPasswordVisible,
                    toggleVisibility: () => userProvider.togglePasswordVisibility(),
                    validator: Validators.validatePassword,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16.0),

                  CustomPasswordField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    isVisible: userProvider.isConfirmPasswordVisible,
                    toggleVisibility: () => userProvider.toggleConfirmPasswordVisibility(),
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24.0),

                  if (userProvider.errorMessage.isNotEmpty)
                    ErrorText(errorMessage: userProvider.errorMessage),

                  CustomButton(
                    text: 'Sign Up',
                    onPressed: () => _signup(userProvider),
                    isLoading: isLoading,
                  ),

                  const SizedBox(height: 16.0),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
