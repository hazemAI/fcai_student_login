import 'package:fcai_student_login/providers/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../database/database_helper.dart';
import 'dart:io';

class UserProvider with ChangeNotifier {
  String emailLogin;
  User? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _gender;
  int? _level;
  File? _profileImageFile;
  String? _profileImagePath;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  String? get gender => _gender;
  int? get level => _level;
  File? get profileImageFile => _profileImageFile;
  String? get profileImagePath => _profileImagePath;

  UserProvider(this.emailLogin);

  Future<void> defineUser() async {
    setLoading(true);
    try {
      if (emailLogin.isNotEmpty) {
        _currentUser = await DatabaseHelper.getUserByEmail(emailLogin);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setLoading(false);
    }
  }

  bool isAuthenticated() {
    return emailLogin.isNotEmpty;
  }

  // Setters
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void setGender(String? gender) {
    _gender = gender;
    notifyListeners();
  }

  void setLevel(int? level) {
    _level = level;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  void setProfileImage(File imageFile, String path) {
    _profileImageFile = imageFile;
    _profileImagePath = path;
    notifyListeners();
  }

  // Validate student ID with email
  String? validateStudentIdWithEmail(String studentId, String email) {
    if (studentId.isEmpty || email.isEmpty) {
      return 'Both student ID and email are required';
    }

    // Extract student ID from email (part before @)
    final emailParts = email.split('@');
    if (emailParts.length != 2) {
      return 'Invalid email format';
    }

    final emailStudentId = emailParts[0];

    if (studentId != emailStudentId) {
      return 'Student ID must match the ID in your email (part before @)';
    }

    return null;
  }

  // Login function
  Future<bool> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    setLoading(true);
    setErrorMessage('');

    try {
      final user = await DatabaseHelper.loginUser(email, password);
      if (user != null) {
        _currentUser = user;
        DatabaseHelper.setLoggedIn(email);
        emailLogin = email;
        await context.read<StoreProvider>().loadFavorites(context);
        setLoading(false);
        notifyListeners();
        return true;
      } else {
        setErrorMessage('Invalid email or password');
        setLoading(false);
        return false;
      }
    } catch (e) {
      DatabaseHelper.setLoggedOut();
      setErrorMessage('An error occurred: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // Signup function with validation
  Future<Map<String, dynamic>> signupWithValidation(
    User user,
    String studentId,
    String email,
    BuildContext context,
  ) async {
    // Validate student ID matches email
    final studentIdEmailMatch = validateStudentIdWithEmail(studentId, email);

    if (studentIdEmailMatch != null) {
      setErrorMessage(studentIdEmailMatch);
      return {'success': false, 'message': studentIdEmailMatch};
    }

    setErrorMessage('');
    return await signup(user, context);
  }

  // Original signup function
  Future<Map<String, dynamic>> signup(User user, BuildContext context) async {
    try {
      setLoading(true);
      setErrorMessage(''); // Clear previous error messages

      // Check if email already exists
      final existingUserByEmail = await DatabaseHelper.getUserByEmail(
        user.email,
      );
      if (existingUserByEmail != null) {
        setErrorMessage('Email already exists');
        return {'success': false, 'message': 'Email already exists'};
      }

      // Check if student ID already exists
      final existingUserByStudentId = await DatabaseHelper.getUserByStudentId(
        user.studentId,
      );
      if (existingUserByStudentId != null) {
        setErrorMessage('Student ID already exists');
        return {'success': false, 'message': 'Student ID already exists'};
      }

      // Create a user with the profile image path if available
      final userWithImage =
          _profileImagePath != null
              ? user.copyWith(profilePhoto: _profileImagePath)
              : user;

      // Insert user
      final id = await DatabaseHelper.insertUser(userWithImage);
      if (id > 0) {
        _currentUser = userWithImage.copyWith(id: id);
        DatabaseHelper.setLoggedIn(user.email);
        emailLogin = user.email;
        await context.read<StoreProvider>().loadFavorites(context);
        notifyListeners();
        return {'success': true, 'message': 'Signup successful'};
      } else {
        setErrorMessage('Failed to create account');
        return {'success': false, 'message': 'Failed to create account'};
      }
    } catch (e) {
      print("Signup error: $e");
      setErrorMessage('An error occurred: $e');
      DatabaseHelper.setLoggedOut();
      return {'success': false, 'message': 'An error occurred: $e'};
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updateProfile(User updatedUser) async {
    try {
      if (_currentUser == null || _currentUser!.id == null) {
        return false;
      }

      final user = updatedUser.copyWith(id: _currentUser!.id);
      final result = await DatabaseHelper.updateUser(user);

      if (result > 0) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Update profile error: $e");
      return false;
    }
  }

  Future<bool> updateProfilePhoto(String photoPath) async {
    try {
      if (_currentUser == null || _currentUser!.id == null) {
        return false;
      }

      final result = await DatabaseHelper.updateUserProfilePhoto(
        _currentUser!.id!,
        photoPath,
      );

      if (result > 0) {
        _currentUser = _currentUser!.copyWith(profilePhoto: photoPath);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Update profile photo error: $e");
      return false;
    }
  }

  void logout(BuildContext context) {
    _currentUser = null;
    DatabaseHelper.setLoggedOut();
    context.read<StoreProvider>().refresh();
    notifyListeners();
  }

  // Reset state when navigating between screens
  void resetState() {
    _isPasswordVisible = false;
    _isConfirmPasswordVisible = false;
    _gender = null;
    _level = null;
    _errorMessage = '';
    _profileImageFile = null;
    _profileImagePath = null;
    notifyListeners();
  }
}
