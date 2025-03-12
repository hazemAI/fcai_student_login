# FCAI Student Login

A cross-platform Flutter application for student login and profile management, designed to work on both Windows and Android.

## Features

- User registration and login
- Profile management with photo upload
- Cross-platform support (Windows and Android)
- Persistent data storage using Hive
- Camera and gallery integration for profile photos
- Secure local data storage

## Technologies Used

- Flutter
- Hive for local data storage
- Provider for state management
- Image Picker for camera and gallery access
- File Selector for Windows file picking

## Platform-Specific Features

### Windows
- Native file picker integration
- Fallback mechanisms for camera functionality
- Windows-specific path handling

### Android
- Full camera and gallery support
- Android-specific permissions handling

## Getting Started

### Prerequisites

- Flutter SDK (3.7.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- For Windows development: Windows 10 or higher
- For Android development: Android SDK

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/hazemAI/fcai_student_login.git
   ```

2. Navigate to the project directory:
   ```
   cd fcai_student_login
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the application:
   ```
   flutter run -d windows  # For Windows
   flutter run -d android  # For Android
   ```

## Project Structure

- `lib/database`: Database helper classes
- `lib/models`: Data models
- `lib/providers`: State management
- `lib/screens`: UI screens
- `lib/utils`: Utility classes and helpers

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing cross-platform framework
- Hive for the efficient local database solution
