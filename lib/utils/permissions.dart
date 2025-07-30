import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Device permissions handler for AgriDirect app
class AppPermissions {
  
  /// Check if permission is granted
  static Future<bool> isPermissionGranted(Permission permission) async {
    final status = await permission.status;
    return status == PermissionStatus.granted;
  }

  /// Request single permission
  static Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }

  /// Request multiple permissions
  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  /// Check and request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;
    
    if (status == PermissionStatus.granted) {
      return true;
    }
    
    if (status == PermissionStatus.denied) {
      final result = await Permission.camera.request();
      return result == PermissionStatus.granted;
    }
    
    return false;
  }

  /// Check and request photo library permission
  static Future<bool> requestPhotosPermission() async {
    Permission permission;
    
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        permission = Permission.photos;
      } else {
        permission = Permission.storage;
      }
    } else {
      permission = Permission.photos;
    }
    
    final status = await permission.status;
    
    if (status == PermissionStatus.granted) {
      return true;
    }
    
    if (status == PermissionStatus.denied) {
      final result = await permission.request();
      return result == PermissionStatus.granted;
    }
    
    return false;
  }

  /// Check and request location permission
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.status;
    
    if (status == PermissionStatus.granted) {
      return true;
    }
    
    if (status == PermissionStatus.denied) {
      final result = await Permission.location.request();
      return result == PermissionStatus.granted;
    }
    
    return false;
  }

  /// Check and request location always permission
  static Future<bool> requestLocationAlwaysPermission() async {
    final status = await Permission.locationAlways.status;
    
    if (status == PermissionStatus.granted) {
      return true;
    }
    
    if (status == PermissionStatus.denied) {
      final result = await Permission.locationAlways.request();
      return result == PermissionStatus.granted;
    }
    
    return false;
  }

  /// Check and request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    
    if (status == PermissionStatus.granted) {
      return true;
    }
    
    if (status == PermissionStatus.denied) {
      final result = await Permission.microphone.request();
      return result == PermissionStatus.granted;
    }
    
    return false;
  }

  /// Check and request notification permission
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    
    if (status == PermissionStatus.granted) {
      return true;
    }
    
    if (status == PermissionStatus.denied) {
      final result = await Permission.notification.request();
      return result == PermissionStatus.granted;
    }
    
    return false;
  }

  /// Check and request phone permission
  static Future<bool> requestPhonePermission() async {
    final status = await Permission.phone.status;
    
    if (status == PermissionStatus.granted) {
      return true;
    }
    
    if (status == PermissionStatus.denied) {
      final result = await Permission.phone.request();
      return result == PermissionStatus.granted;
    }
    
    return false;
  }

  /// Check and request contacts permission
  static Future<bool> requestContactsPermission() async {
    final status = await Permission.contacts.status;
    
    if (status == PermissionStatus.granted) {
      return true;
    }
    
    if (status == PermissionStatus.denied) {
      final result = await Permission.contacts.request();
      return result == PermissionStatus.granted;
    }
    
    return false;
  }

  /// Check and request storage permission
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      
      // Android 13+ uses granular permissions
      if (androidInfo.version.sdkInt >= 33) {
        final permissions = [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ];
        
        final statuses = await permissions.request();
        return statuses.values.every((status) => 
            status == PermissionStatus.granted || 
            status == PermissionStatus.limited);
      } else {
        // Android 12 and below
        final status = await Permission.storage.status;
        
        if (status == PermissionStatus.granted) {
          return true;
        }
        
        if (status == PermissionStatus.denied) {
          final result = await Permission.storage.request();
          return result == PermissionStatus.granted;
        }
      }
    } else {
      // iOS
      final status = await Permission.photos.status;
      
      if (status == PermissionStatus.granted || status == PermissionStatus.limited) {
        return true;
      }
      
      if (status == PermissionStatus.denied) {
        final result = await Permission.photos.request();
        return result == PermissionStatus.granted || result == PermissionStatus.limited;
      }
    }
    
    return false;
  }

  /// Request all essential permissions for the app
  static Future<PermissionResults> requestEssentialPermissions() async {
    final permissions = <Permission>[];
    
    // Always needed permissions
    permissions.addAll([
      Permission.camera,
      Permission.location,
      Permission.notification,
    ]);
    
    // Platform-specific permissions
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        permissions.add(Permission.photos);
      } else {
        permissions.add(Permission.storage);
      }
    } else {
      permissions.add(Permission.photos);
    }
    
    final results = await permissions.request();
    
    return PermissionResults(
      camera: results[Permission.camera] ?? PermissionStatus.denied,
      photos: results[Permission.photos] ?? results[Permission.storage] ?? PermissionStatus.denied,
      location: results[Permission.location] ?? PermissionStatus.denied,
      notification: results[Permission.notification] ?? PermissionStatus.denied,
    );
  }

  /// Show permission rationale dialog
  static Future<bool?> showPermissionRationale(
    BuildContext context, {
    required String title,
    required String message,
    required String permission,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Text(
              'To grant $permission permission:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('1. Go to Settings > Apps > AgriDirect'),
            const Text('2. Tap on Permissions'),
            const Text('3. Enable the required permission'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Check if permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status == PermissionStatus.permanentlyDenied;
  }

  /// Get permission status string
  static String getPermissionStatusString(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return 'Limited';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.provisional:
        return 'Provisional';
    }
  }

  /// Check all app permissions status
  static Future<Map<String, PermissionStatus>> checkAllPermissions() async {
    final permissions = <Permission, String>{
      Permission.camera: 'Camera',
      Permission.microphone: 'Microphone',
      Permission.location: 'Location',
      Permission.notification: 'Notification',
      Permission.contacts: 'Contacts',
      Permission.phone: 'Phone',
    };
    
    // Add platform-specific permissions
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        permissions[Permission.photos] = 'Photos';
        permissions[Permission.videos] = 'Videos';
        permissions[Permission.audio] = 'Audio';
      } else {
        permissions[Permission.storage] = 'Storage';
      }
    } else {
      permissions[Permission.photos] = 'Photos';
    }
    
    final results = <String, PermissionStatus>{};
    
    for (final entry in permissions.entries) {
      final status = await entry.key.status;
      results[entry.value] = status;
    }
    
    return results;
  }

  /// Request permission with custom rationale
  static Future<bool> requestPermissionWithRationale(
    BuildContext context,
    Permission permission, {
    required String title,
    required String message,
    required String permissionName,
  }) async {
    final status = await permission.status;
    
    if (status == PermissionStatus.granted) {
      return true;
    }
    
    if (status == PermissionStatus.denied) {
      // Show rationale first
      final shouldRequest = await showPermissionRationale(
        context,
        title: title,
        message: message,
        permission: permissionName,
      );
      
      if (shouldRequest == true) {
        final result = await permission.request();
        return result == PermissionStatus.granted;
      }
    }
    
    if (status == PermissionStatus.permanentlyDenied) {
      final shouldOpenSettings = await showPermissionRationale(
        context,
        title: 'Permission Required',
        message: 'This permission has been permanently denied. Please enable it from app settings.',
        permission: permissionName,
      );
      
      if (shouldOpenSettings == true) {
        return await openAppSettings();
      }
    }
    
    return false;
  }

  /// Check if location service is enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Permission.location.serviceStatus.isEnabled;
  }

  /// Request to enable location service
  static Future<bool> requestLocationService() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      // This will open location settings
      return await Permission.location.request() == PermissionStatus.granted;
    }
    return true;
  }
}

/// Permission results data class
class PermissionResults {
  final PermissionStatus camera;
  final PermissionStatus photos;
  final PermissionStatus location;
  final PermissionStatus notification;

  PermissionResults({
    required this.camera,
    required this.photos,
    required this.location,
    required this.notification,
  });

  bool get allGranted => 
      camera == PermissionStatus.granted &&
      (photos == PermissionStatus.granted || photos == PermissionStatus.limited) &&
      location == PermissionStatus.granted &&
      notification == PermissionStatus.granted;

  bool get hasEssentialPermissions =>
      camera == PermissionStatus.granted &&
      location == PermissionStatus.granted;

  @override
  String toString() {
    return 'PermissionResults(camera: $camera, photos: $photos, location: $location, notification: $notification)';
  }
}