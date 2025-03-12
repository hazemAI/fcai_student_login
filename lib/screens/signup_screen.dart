import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../utils/validators.dart';
import 'profile_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _gender;
  int? _level;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final user = User(
          name: _nameController.text,
          gender: _gender,
          email: _emailController.text,
          studentId: _studentIdController.text,
          level: _level,
          password: _passwordController.text,
        );

        final result = await Provider.of<UserProvider>(context, listen: false).signup(user);

        if (result['success']) {
          if (!mounted) return;
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signup successful'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to profile screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        } else {
          setState(() {
            _errorMessage = result['message'];
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.person_add,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              
              // Gender selection
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
              const SizedBox(height: 16),
              
              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  hintText: 'studentID@stud.fci-cu.edu.eg',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                onChanged: (value) {
                  // Auto-fill student ID from email
                  if (value.contains('@')) {
                    final studentId = value.split('@')[0];
                    _studentIdController.text = studentId;
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Student ID field
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID *',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => Validators.validateStudentId(value, _emailController.text),
              ),
              const SizedBox(height: 16),
              
              // Level selection
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Level (Optional)',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                value: _level,
                items: [1, 2, 3, 4].map((level) {
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
              const SizedBox(height: 16),
              
              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                  hintText: 'At least 8 characters with 1 number',
                ),
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),
              
              // Confirm Password field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password *',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => Validators.validateConfirmPassword(
                  value,
                  _passwordController.text,
                ),
              ),
              
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('SIGN UP', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
