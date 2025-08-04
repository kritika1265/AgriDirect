import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Service class for handling image operations including picking, compression,
/// resizing, and other image manipulations.
class ImageService {
  ImageService._internal();
  
  /// Singleton instance
  factory ImageService() => _instance;
  static final ImageService _instance = ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  Future<List<File>> pickMultipleImages() async {
    try {
      final images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  /// Compress image to reduce file size
  Future<File?> compressImage(File imageFile, {int quality = 85}) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;

      // Resize if image is too large
      img.Image resized = image;
      if (image.width > 1024 || image.height > 1024) {
        resized = img.copyResize(
          image,
          width: image.width > image.height ? 1024 : null,
          height: image.height > image.width ? 1024 : null,
        );
      }

      final compressedBytes = img.encodeJpg(resized, quality: quality);
      
      // Save compressed image
      final tempDir = await getTemporaryDirectory();
      final fileName = 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = File(path.join(tempDir.path, fileName));
      
      await compressedFile.writeAsBytes(compressedBytes);
      return compressedFile;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Resize image to specific dimensions
  Future<File?> resizeImage(File imageFile, int width, int height) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;

      final resized = img.copyResize(image, width: width, height: height);
      final resizedBytes = img.encodeJpg(resized);
      
      final tempDir = await getTemporaryDirectory();
      final fileName = 'resized_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final resizedFile = File(path.join(tempDir.path, fileName));
      
      await resizedFile.writeAsBytes(resizedBytes);
      return resizedFile;
    } catch (e) {
      debugPrint('Error resizing image: $e');
      return null;
    }
  }

  /// Save image to app documents directory
  Future<File?> saveImageToDocuments(File imageFile, String fileName) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final imagePath = path.join(appDocDir.path, 'images');
      final imageDir = Directory(imagePath);
      
      if (!imageDir.existsSync()) {
        await imageDir.create(recursive: true);
      }
      
      final savedFile = File(path.join(imagePath, fileName));
      await imageFile.copy(savedFile.path);
      
      return savedFile;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  /// Delete image file
  Future<bool> deleteImage(File imageFile) async {
    try {
      if (imageFile.existsSync()) {
        await imageFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Get image size in bytes
  Future<int> getImageSize(File imageFile) async {
    try {
      return await imageFile.length();
    } catch (e) {
      debugPrint('Error getting image size: $e');
      return 0;
    }
  }

  /// Convert image to base64 string
  Future<String?> imageToBase64(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      return base64Encode(imageBytes);
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      return null;
    }
  }

  /// Crop image to square aspect ratio
  Future<File?> cropToSquare(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;

      final size = image.width < image.height ? image.width : image.height;
      final x = (image.width - size) ~/ 2;
      final y = (image.height - size) ~/ 2;
      
      final cropped = img.copyCrop(image, x: x, y: y, width: size, height: size);
      final croppedBytes = img.encodeJpg(cropped);
      
      final tempDir = await getTemporaryDirectory();
      final fileName = 'cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final croppedFile = File(path.join(tempDir.path, fileName));
      
      await croppedFile.writeAsBytes(croppedBytes);
      return croppedFile;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  /// Clean up temporary images
  Future<void> cleanupTempImages() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      for (final file in files) {
        if (file is File && 
            (file.path.contains('compressed_') || 
             file.path.contains('resized_') || 
             file.path.contains('cropped_'))) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error cleaning temp images: $e');
    }
  }

  /// Validate image file
  bool isValidImageFile(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp'].contains(extension);
  }

  /// Get image dimensions
  Future<Map<String, int>?> getImageDimensions(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      debugPrint('Error getting image dimensions: $e');
      return null;
    }
  }
}