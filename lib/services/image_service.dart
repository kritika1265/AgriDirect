// All imports should be at the top
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Service class for handling image operations
class ImageService {
  /// Constructor
  const ImageService();
  
  /// Camera image source
  static const String camera = 'camera';
  
  /// Gallery image source
  static const String gallery = 'gallery';
  
  /// JPEG format
  static const String jpeg = 'jpeg';
  
  /// PNG format
  static const String png = 'png';
  
  /// High image quality setting
  static const int highQuality = 100;
  
  /// Medium image quality setting
  static const int mediumQuality = 70;
  
  /// Low image quality setting
  static const int lowQuality = 30;
  
  /// Maximum allowed file size in bytes
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  
  /// Default image width for resizing
  static const int defaultWidth = 800;
  
  /// Default image height for resizing
  static const int defaultHeight = 600;

  /// Convert map to JSON string with proper type casting
  String toJson(Map<String, dynamic> data) => jsonEncode({
    'id': data['id']?.toString() ?? '',
    'name': data['name']?.toString() ?? '',
    'path': data['path']?.toString() ?? '',
    'description': data['description']?.toString() ?? '',
    'category': data['category']?.toString(),
    'location': data['location']?.toString(),
    'tags': (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    'uploadDate': data['uploadDate']?.toString(),
    'modifiedDate': data['modifiedDate']?.toString(),
    'isPrivate': data['isPrivate'] == true,
  });

  /// Create ImageData from JSON with proper type casting
  static ImageData fromJson(Map<String, dynamic> json) => ImageData(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    path: json['path']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    category: json['category']?.toString(),
    location: json['location']?.toString(),
    tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    uploadDate: json['uploadDate']?.toString(),
    modifiedDate: json['modifiedDate']?.toString(),
    isPrivate: json['isPrivate'] == true,
  );
}

/// Image data model
class ImageData {
  /// Constructor
  const ImageData({
    required this.id,
    required this.name,
    required this.path,
    required this.description,
    this.category,
    this.location,
    this.tags = const [],
    this.uploadDate,
    this.modifiedDate,
    this.isPrivate = false,
  });

  /// Unique identifier for the image
  final String id;
  
  /// Name of the image
  final String name;
  
  /// File path of the image
  final String path;
  
  /// Description of the image
  final String description;
  
  /// Category of the image
  final String? category;
  
  /// Location where image was taken
  final String? location;
  
  /// Tags associated with the image
  final List<String> tags;
  
  /// Date when image was uploaded
  final String? uploadDate;
  
  /// Date when image was last modified
  final String? modifiedDate;
  
  /// Whether the image is private
  final bool isPrivate;

  /// Create ImageData with updated values
  ImageData copyWith({
    String? id,
    String? name,
    String? path,
    String? description,
    String? category,
    String? location,
    List<String>? tags,
    String? uploadDate,
    String? modifiedDate,
    bool? isPrivate,
  }) => ImageData(
    id: id ?? this.id,
    name: name ?? this.name,
    path: path ?? this.path,
    description: description ?? this.description,
    category: category ?? this.category,
    location: location ?? this.location,
    tags: tags ?? this.tags,
    uploadDate: uploadDate ?? this.uploadDate,
    modifiedDate: modifiedDate ?? this.modifiedDate,
    isPrivate: isPrivate ?? this.isPrivate,
  );
}

/// Image picker service
class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();
  
  /// Pick image from camera
  static Future<XFile?> pickFromCamera() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return await _picker.pickImage(source: ImageSource.camera);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking from camera: $e');
      }
      return null;
    }
  }

  /// Pick image from gallery
  static Future<XFile?> pickFromGallery() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking from gallery: $e');
      }
      return null;
    }
  }

  /// Pick multiple images
  static Future<List<XFile>?> pickMultiple() async {
    try {
      return await _picker.pickMultipleMedia();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking multiple images: $e');
      }
      return null;
    }
  }
}

/// Response model for image operations
class ImageResponse {
  /// Constructor
  const ImageResponse({
    required this.success,
    required this.statusCode,
    this.data,
    this.error,
    this.metadata,
  });

  /// Whether the operation was successful
  final bool success;
  
  /// HTTP status code
  final int statusCode;
  
  /// Image data if operation was successful
  final ImageData? data;
  
  /// Error message if operation failed
  final String? error;
  
  /// Additional response data
  final Map<String, dynamic>? metadata;

  /// Create successful response
  factory ImageResponse.success({
    required ImageData data,
    int statusCode = 200,
    Map<String, dynamic>? metadata,
  }) => ImageResponse(
    success: true,
    statusCode: statusCode,
    data: data,
    metadata: metadata,
  );

  /// Create error response
  factory ImageResponse.error({
    required String error,
    int statusCode = 400,
    Map<String, dynamic>? metadata,
  }) => ImageResponse(
    success: false,
    statusCode: statusCode,
    error: error,
    metadata: metadata,
  );
}

/// Network service for image operations
class NetworkService {
  /// Upload image to server
  static Future<ImageResponse> uploadImage({
    required File imageFile,
    String? description,
    Map<String, String>? headers,
  }) async {
    try {
      // Simulate network delay
      await Future<void>.delayed(const Duration(seconds: 1));
      
      // Mock successful upload
      return ImageResponse.success(
        data: ImageData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: imageFile.path.split('/').last,
          path: imageFile.path,
          description: description ?? '',
          uploadDate: DateTime.now().toIso8601String(),
        ),
      );
    } catch (e) {
      return ImageResponse.error(
        error: 'Upload failed: $e',
        statusCode: 500,
      );
    }
  }
}

/// Constants for image operations
class ImageConstants {
  /// Maximum image width
  static const double maxWidth = 1920;
  
  /// Maximum image height
  static const double maxHeight = 1080;
  
  /// Default compression quality
  static const double compressionQuality = 0.8;
  
  /// Supported image formats
  static const List<String> supportedFormats = ['jpg', 'jpeg', 'png', 'gif'];
  
  /// Maximum file size in MB
  static const double maxFileSizeMB = 10;
  
  /// Cache directory name
  static const String cacheDirectory = 'image_cache';
  
  /// Thumbnail directory name
  static const String thumbnailDirectory = 'thumbnails';
  
  /// Upload timeout in seconds
  static const int uploadTimeoutSeconds = 30;
  
  /// Default image quality
  static const int defaultQuality = 85;
  
  /// Thumbnail size
  static const int thumbnailSize = 150;
}

/// Image upload widget
class ImageUploadWidget extends StatelessWidget {
  /// Constructor
  const ImageUploadWidget({
    super.key,
    this.onImageSelected,
    this.showProgress = false,
  });

  /// Callback when image is selected
  final void Function(ImageData)? onImageSelected;
  
  /// Whether to show upload progress
  final bool showProgress;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _pickImage(context),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Select Image'),
        ),
        if (showProgress) const LinearProgressIndicator(),
      ],
    ),
  );

  Future<void> _pickImage(BuildContext context) async {
    final image = await ImagePickerService.pickFromGallery();
    if (image != null) {
      final imageData = ImageData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: image.name,
        path: image.path,
        description: '',
      );
      onImageSelected?.call(imageData);
    }
  }
}

/// Image cache service
class ImageCacheService {
  /// Cache an image file
  static Future<String?> cacheImage(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/${ImageConstants.cacheDirectory}');
      
      if (!cacheDir.existsSync()) {
        cacheDir.createSync(recursive: true);
      }
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.uri.pathSegments.last}';
      final cachedFile = File('${cacheDir.path}/$fileName');
      
      await imageFile.copy(cachedFile.path);
      return cachedFile.path;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error caching image: $e');
      }
      return null;
    }
  }

  /// Clear image cache
  static Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/${ImageConstants.cacheDirectory}');
      
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing cache: $e');
      }
    }
  }
}

/// Image validation utility
class ImageValidator {
  /// Validate image file
  static Future<bool> validateImage(File imageFile) async {
    try {
      // Check if file exists
      if (!imageFile.existsSync()) {
        return false;
      }
      
      // Check file size
      final fileStat = imageFile.statSync();
      if (fileStat.size > ImageConstants.maxFileSizeMB * 1024 * 1024) {
        return false;
      }
      
      // Check file extension
      final extension = imageFile.path.split('.').last.toLowerCase();
      return ImageConstants.supportedFormats.contains(extension);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error validating image: $e');
      }
      return false;
    }
  }

  /// Get image file size in MB
  static Future<double> getFileSizeMB(File file) async {
    try {
      final fileStat = file.statSync();
      return fileStat.size / (1024 * 1024);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting file size: $e');
      }
      return 0;
    }
  }
}

/// Progress callback widget
class ProgressCallback extends StatefulWidget {
  /// Constructor
  const ProgressCallback({super.key});

  @override
  State<ProgressCallback> createState() => _ProgressCallbackState();
}

class _ProgressCallbackState extends State<ProgressCallback> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      LinearProgressIndicator(value: _progress),
      Text('Progress: ${(_progress * 100).toStringAsFixed(1)}%'),
    ],
  );

  /// Update progress
  void updateProgress(double progress) {
    if (mounted) {
      setState(() {
        _progress = progress;
      });
    }
  }
}