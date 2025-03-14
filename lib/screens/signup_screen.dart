import 'package:fcai_student_login/screens/login_screen.dart';
import 'package:fcai_student_login/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../utils/validators.dart';

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
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
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
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.validateName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16.0),

                  // Gender selection (optional)
                  const Text(
                    'Gender (Optional)',
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Male'),
                          value: 'Male',
                          groupValue: userProvider.gender,
                          onChanged: (value) => userProvider.setGender(value),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Female'),
                          value: 'Female',
                          groupValue: userProvider.gender,
                          onChanged: (value) => userProvider.setGender(value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                      hintText: 'studentID@stud.fci-cu.edu.eg',
                      helperText: 'Student ID must match the part before @',
                    ),
                    validator: Validators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16.0),

                  TextFormField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Student ID',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                      hintText: 'Must match ID in email',
                      helperText: 'Must match the part before @ in your email',
                    ),
                    validator: Validators.validateStudentId,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16.0),

                  // Level selection (optional)
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Level (Optional)',
                      prefixIcon: Icon(Icons.school),
                      border: OutlineInputBorder(),
                    ),
                    value: userProvider.level,
                    hint: const Text('Select your level'),
                    items:
                        [1, 2, 3, 4].map((level) {
                          return DropdownMenuItem<int>(
                            value: level,
                            child: Text('Level $level'),
                          );
                        }).toList(),
                    onChanged: (value) => userProvider.setLevel(value),
                  ),
                  const SizedBox(height: 16.0),

                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      hintText: 'At least 8 characters with 1 number',
                      suffixIcon: IconButton(
                        icon: Icon(
                          userProvider.isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            () => userProvider.togglePasswordVisibility(),
                      ),
                    ),
                    obscureText: !userProvider.isPasswordVisible,
                    validator: Validators.validatePassword,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16.0),

                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          userProvider.isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            () =>
                                userProvider.toggleConfirmPasswordVisibility(),
                      ),
                    ),
                    obscureText: !userProvider.isConfirmPasswordVisible,
                    validator:
                        (value) => Validators.validateConfirmPassword(
                          value,
                          _passwordController.text,
                        ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24.0),

                  if (userProvider.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        userProvider.errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  ElevatedButton(
                    onPressed: isLoading ? null : () => _signup(userProvider),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 16.0),
                            ),
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
