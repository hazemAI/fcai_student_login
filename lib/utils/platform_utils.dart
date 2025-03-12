import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:image_picker/image_picker.dart';

class PlatformUtils {
  /// Checks if the current platform is supported (Windows or Android)
  static bool get isSupportedPlatform {
    return !kIsWeb && (Platform.isWindows || Platform.isAndroid);
  }

  /// Gets the platform-specific application documents directory
  static Future<Directory> getAppDirectory() async {
    if (Platform.isWindows) {
      final appDocDir = await getApplicationDocumentsDirectory();
      final appDir = Directory('${appDocDir.path}/fcai_student_login');
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }
      return appDir;
    } else {
      // Android
      return await getApplicationDocumentsDirectory();
    }
  }

  /// Checks if camera is available on the current platform
  static bool isCameraAvailable() {
    // Camera is reliably available only on Android
    // Windows camera support is experimental and often fails
    return Platform.isAndroid;
  }

  /// Picks an image using the appropriate method for the platform
  static Future<XFile?> pickImage(ImageSource source) async {
    final picker = ImagePicker();

    if (Platform.isWindows) {
      // On Windows, always use file_selector for gallery regardless of requested source
      // This is because camera rarely works on Windows with image_picker
      try {
        // If camera was requested but we're on Windows, we'll try it first but have a fallback
        if (source == ImageSource.camera) {
          try {
            final cameraImage = await picker.pickImage(
              source: ImageSource.camera,
              imageQuality: 70,
              preferredCameraDevice: CameraDevice.rear,
            );

            if (cameraImage != null) {
              return cameraImage;
            }
            // If we get here, camera returned null but didn't throw an exception
            // Fall through to file_selector
          } catch (e) {
            print('Camera error on Windows: $e');
            // Fall through to file_selector
          }
        }

        // Use file_selector as the primary (gallery) or fallback (camera) option
        const typeGroup = file_selector.XTypeGroup(
          label: 'Images',
          extensions: ['jpg', 'jpeg', 'png', 'gif'],
        );

        final file = await file_selector.openFile(
          acceptedTypeGroups: [typeGroup],
        );

        if (file != null) {
          return XFile(file.path);
        }
        return null;
      } catch (e) {
        print('Error picking file: $e');
        // Last resort fallback to image_picker gallery
        try {
          return await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 70,
          );
        } catch (e) {
          print('Final fallback error: $e');
          return null;
        }
      }
    } else {
      // Android - use image_picker for both gallery and camera
      return await picker.pickImage(
        source: source,
        imageQuality: 70,
        preferredCameraDevice: CameraDevice.rear,
      );
    }
  }

  /// Copies an image file to the app's storage and returns the new path
  static Future<String> saveImageToAppStorage(String sourcePath) async {
    try {
      final appDir = await getAppDirectory();
      final fileName = path.basename(sourcePath);
      final targetPath = '${appDir.path}/$fileName';

      // Copy the file to the app's storage
      final File sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        await sourceFile.copy(targetPath);
        return targetPath;
      }
      return sourcePath; // Return original path if copy fails
    } catch (e) {
      print('Error saving image: $e');
      return sourcePath; // Return original path on error
    }
  }

  /// Normalizes file paths for the current platform
  static String normalizePath(String filePath) {
    if (Platform.isWindows) {
      // Ensure Windows paths use backslashes
      return filePath.replaceAll('/', '\\');
    } else {
      // Ensure Android paths use forward slashes
      return filePath.replaceAll('\\', '/');
    }
  }
}
