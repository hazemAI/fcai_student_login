import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../database/database_helper.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  User? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    try {
      final user = await _databaseHelper.loginUser(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> signup(User user) async {
    try {
      // Check if email already exists
      final existingUserByEmail = await _databaseHelper.getUserByEmail(user.email);
      if (existingUserByEmail != null) {
        return {
          'success': false,
          'message': 'Email already exists',
        };
      }

      // Check if student ID already exists
      final existingUserByStudentId = await _databaseHelper.getUserByStudentId(user.studentId);
      if (existingUserByStudentId != null) {
        return {
          'success': false,
          'message': 'Student ID already exists',
        };
      }

      // Insert user
      final id = await _databaseHelper.insertUser(user);
      if (id > 0) {
        _currentUser = user.copyWith(id: id);
        notifyListeners();
        return {
          'success': true,
          'message': 'Signup successful',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create account',
        };
      }
    } catch (e) {
      print("Signup error: $e");
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
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
}
