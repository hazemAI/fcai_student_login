import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../database/database_helper.dart';
import 'dart:io';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
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
  Future<bool> login(String email, String password, BuildContext context) async {
    setLoading(true);
    setErrorMessage('');
    
    try {
      final user = await _databaseHelper.loginUser(email, password);
      if (user != null) {
        _currentUser = user;
        setLoading(false);
        notifyListeners();
        return true;
      } else {
        setErrorMessage('Invalid email or password');
        setLoading(false);
        return false;
      }
    } catch (e) {
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
      return {
        'success': false,
        'message': studentIdEmailMatch,
      };
    }
    
    setErrorMessage('');
    return await signup(user);
  }

  // Original signup function
  Future<Map<String, dynamic>> signup(User user) async {
    try {
      setLoading(true);
      setErrorMessage(''); // Clear previous error messages
      
      // Check if email already exists
      final existingUserByEmail = await _databaseHelper.getUserByEmail(user.email);
      if (existingUserByEmail != null) {
        setErrorMessage('Email already exists');
        return {
          'success': false,
          'message': 'Email already exists',
        };
      }

      // Check if student ID already exists
      final existingUserByStudentId = await _databaseHelper.getUserByStudentId(user.studentId);
      if (existingUserByStudentId != null) {
        setErrorMessage('Student ID already exists');
        return {
          'success': false,
          'message': 'Student ID already exists',
        };
      }

      // Create a user with the profile image path if available
      final userWithImage = _profileImagePath != null 
          ? user.copyWith(profilePhoto: _profileImagePath)
          : user;

      // Insert user
      final id = await _databaseHelper.insertUser(userWithImage);
      if (id > 0) {
        _currentUser = userWithImage.copyWith(id: id);
        notifyListeners();
        return {
          'success': true,
          'message': 'Signup successful',
        };
      } else {
        setErrorMessage('Failed to create account');
        return {
          'success': false,
          'message': 'Failed to create account',
        };
      }
    } catch (e) {
      print("Signup error: $e");
      setErrorMessage('An error occurred: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
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
      final result = await _databaseHelper.updateUser(user);
      
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
      
      final result = await _databaseHelper.updateUserProfilePhoto(_currentUser!.id!, photoPath);
      
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

  void logout() {
    _currentUser = null;
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
