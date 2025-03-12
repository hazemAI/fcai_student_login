import 'package:email_validator/email_validator.dart';

class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email';
    }
    
    // FCI Email validation (studentID@stud.fci-cu.edu.eg)
    final RegExp fciEmailRegex = RegExp(r'^[a-zA-Z0-9]+@stud\.fci-cu\.edu\.eg$');
    if (!fciEmailRegex.hasMatch(value)) {
      return 'Email must follow the format: studentID@stud.fci-cu.edu.eg';
    }
    
    return null;
  }

  static String? validateStudentId(String? value, String? email) {
    if (value == null || value.isEmpty) {
      return 'Student ID is required';
    }
    
    // Check if student ID matches the one in email
    if (email != null && email.isNotEmpty) {
      final emailParts = email.split('@');
      if (emailParts.length > 1 && emailParts[0] != value) {
        return 'Student ID must match the ID in your email';
      }
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least 1 number';
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  static String? validateLevel(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Level is optional
    }
    
    final level = int.tryParse(value);
    if (level == null || level < 1 || level > 4) {
      return 'Level must be between 1 and 4';
    }
    
    return null;
  }
}
