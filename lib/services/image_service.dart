import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
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
      final XFile? image = await _picker.pickImage(
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
      final List<XFile> images = await _picker.pickMultiImage(
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
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);
      
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

      final List<int> compressedBytes = img.encodeJpg(resized, quality: quality);
      
      // Save compressed image
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File compressedFile = File(path.join(tempDir.path, fileName));
      
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
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) return null;

      final img.Image resized = img.copyResize(image, width: width, height: height);
      final List<int> resizedBytes = img.encodeJpg(resized);
      
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'resized_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File resizedFile = File(path.join(tempDir.path, fileName));
      
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
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String imagePath = path.join(appDocDir.path, 'images');
      final Directory imageDir = Directory(imagePath);
      
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      
      final File savedFile = File(path.join(imagePath, fileName));
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
      if (await imageFile.exists()) {
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
      final Uint8List imageBytes = await imageFile.readAsBytes();
      return base64Encode(imageBytes);
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      return null;
    }
  }

  /// Crop image to square aspect ratio
  Future<File?> cropToSquare(File imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) return null;

      final int size = image.width < image.height ? image.width : image.height;
      final int x = (image.width - size) ~/ 2;
      final int y = (image.height - size) ~/ 2;
      
      final img.Image cropped = img.copyCrop(image, x: x, y: y, width: size, height: size);
      final List<int> croppedBytes = img.encodeJpg(cropped);
      
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File croppedFile = File(path.join(tempDir.path, fileName));
      
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
      final Directory tempDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = tempDir.listSync();
      
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
    final String extension = path.extension(file.path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp'].contains(extension);
  }

  /// Get image dimensions
  Future<Map<String, int>?> getImageDimensions(File imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);
      
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