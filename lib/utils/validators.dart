import 'package:email_validator/email_validator.dart';

class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    
    // FCI Email structure validation (studentID@stud.fci-cu.edu.eg)
    final fciEmailRegex = RegExp(r'^[0-9]+@stud\.fci-cu\.edu\.eg$');
    if (!fciEmailRegex.hasMatch(value)) {
      return 'Please enter a valid FCI email (studentID@stud.fci-cu.edu.eg)';
    }
    
    return null;
  }

  static String? validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your student ID';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Student ID must contain only numbers';
    }
    return null;
  }

  static String? validateStudentIdWithEmail(String? studentId, String? email) {
    if (studentId == null || email == null || studentId.isEmpty || email.isEmpty) {
      return 'Both student ID and email are required';
    }
    
    // Extract student ID from email
    final emailParts = email.split('@');
    if (emailParts.length != 2) {
      return 'Invalid email format';
    }
    
    final emailStudentId = emailParts[0];
    
    if (studentId != emailStudentId) {
      return 'Student ID must match the ID in your email';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    // Check for at least 1 number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least 1 number';
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    
    if (value.length < 8) {
      return 'Confirm password must be at least 8 characters';
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
