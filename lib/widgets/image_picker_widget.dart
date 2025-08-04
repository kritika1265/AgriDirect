import 'package:flutter/material.dart';
import 'dart:io';

/// A reusable widget for picking images from camera or gallery
class ImagePickerWidget extends StatelessWidget {
  /// The currently selected image file
  final File? selectedImage;
  
  /// Callback when camera button is pressed
  final VoidCallback onCameraPressed;
  
  /// Callback when gallery button is pressed
  final VoidCallback onGalleryPressed;
  
  /// Optional callback when remove button is pressed
  final VoidCallback? onRemovePressed;
  
  /// Placeholder text when no image is selected
  final String? placeholder;
  
  /// Height of the image container
  final double? height;
  
  /// Width of the image container
  final double? width;

  /// Creates an ImagePickerWidget
  const ImagePickerWidget({
    super.key,
    this.selectedImage,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    this.onRemovePressed,
    this.placeholder,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: height ?? 200,
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: selectedImage != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        selectedImage!,
                        height: height ?? 200,
                        width: width ?? double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (onRemovePressed != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: onRemovePressed,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      placeholder ?? 'No image selected',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onCameraPressed,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('Camera', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onGalleryPressed,
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text('Gallery', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}