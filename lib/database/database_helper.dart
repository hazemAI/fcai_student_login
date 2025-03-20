import 'dart:async';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Box<Map>? _userBox;
  static Box<List<dynamic>>? _metadataBox;
  static const String _userBoxName = 'users';
  static const String _metadataBoxName = 'metadata';
  static const String _emailsKey = 'user_emails';
  static const String _studentIdsKey = 'user_studentIds';

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<void> initDatabase() async {
    // Initialize Hive with platform-specific path
    if (Platform.isWindows) {
      final appDocDir = await getApplicationDocumentsDirectory();
      final hivePath = '${appDocDir.path}/fcai_student_login_hive';
      await Directory(hivePath).create(recursive: true);
      await Hive.initFlutter(hivePath);
    } else {
      // Android
      await Hive.initFlutter();
    }

    // Open boxes
    _userBox = await Hive.openBox<Map>(_userBoxName);
    _metadataBox = await Hive.openBox<List<dynamic>>(_metadataBoxName);

    // Initialize metadata if needed
    if (_metadataBox!.get(_emailsKey) == null) {
      await _metadataBox!.put(_emailsKey, <String>[]);
    }

    if (_metadataBox!.get(_studentIdsKey) == null) {
      await _metadataBox!.put(_studentIdsKey, <String>[]);
    }
  }

  // Helper method to get the next user ID
  int _getNextUserId() {
    final List<User> users =
        _userBox!.values
            .map((map) => User.fromMap(Map<String, dynamic>.from(map)))
            .where((user) => user.id != null)
            .toList();

    if (users.isEmpty) return 1;
    return users
            .map((user) => user.id!)
            .reduce((max, id) => id > max ? id : max) +
        1;
  }

  Future<int> insertUser(User user) async {
    // Check if email already exists
    final List<String> emails = List<String>.from(
      _metadataBox!.get(_emailsKey) ?? [],
    );
    if (emails.contains(user.email)) {
      return -1; // Email already exists
    }

    // Check if student ID already exists
    final List<String> studentIds = List<String>.from(
      _metadataBox!.get(_studentIdsKey) ?? [],
    );
    if (studentIds.contains(user.studentId)) {
      return -1; // Student ID already exists
    }

    // Generate a new ID
    final id = _getNextUserId();
    final newUser = user.copyWith(id: id);

    // Store user data
    await _userBox!.put(newUser.email, newUser.toMap());

    // Update metadata
    emails.add(newUser.email);
    studentIds.add(newUser.studentId);
    await _metadataBox!.put(_emailsKey, emails);
    await _metadataBox!.put(_studentIdsKey, studentIds);

    return id;
  }

  Future<User?> getUserByEmail(String email) async {
    final userData = _userBox!.get(email);
    if (userData != null) {
      return User.fromMap(Map<String, dynamic>.from(userData));
    }
    return null;
  }

  Future<User?> getUserByStudentId(String studentId) async {
    final List<User> users =
        _userBox!.values
            .map((map) => User.fromMap(Map<String, dynamic>.from(map)))
            .toList();

    for (final user in users) {
      if (user.studentId == studentId) {
        return user;
      }
    }
    return null;
  }

  Future<User?> loginUser(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user != null && user.password == password) {
      return user;
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    if (user.id == null) return 0;

    // Get the old user to check if email or studentId changed
    final oldUser = await getUserByEmail(user.email);
    if (oldUser == null) return 0;

    // Update the user
    await _userBox!.put(user.email, user.toMap());

    return 1;
  }

  Future<int> updateUserProfilePhoto(int id, String photoPath) async {
    // Find the user with the given ID
    final List<User> users =
        _userBox!.values
            .map((map) => User.fromMap(Map<String, dynamic>.from(map)))
            .where((user) => user.id == id)
            .toList();

    if (users.isEmpty) return 0;

    final user = users.first;
    final updatedUser = user.copyWith(profilePhoto: photoPath);

    // Update the user
    await _userBox!.put(user.email, updatedUser.toMap());

    return 1;
  }

  // Method to close Hive boxes when app is closed
  Future<void> closeDatabase() async {
    await _userBox?.close();
    await _metadataBox?.close();
  }
}
