import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ImageUtils {
  static Future<void> showImageSourceDialog(
    BuildContext context,
    Function(File, String) onImageSelected,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, onImageSelected);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, onImageSelected);
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _pickImage(
    ImageSource source,
    Function(File, String) onImageSelected,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final savedPath = await _saveImageToAppDirectory(imageFile);
        onImageSelected(File(savedPath), savedPath);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  static Future<String> _saveImageToAppDirectory(File imageFile) async {
    try {
      // Get the app's documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}${path.extension(imageFile.path)}';
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      return imageFile.path; // Return original path if saving fails
    }
  }
} 