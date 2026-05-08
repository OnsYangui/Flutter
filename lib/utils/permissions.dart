import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // Vérifier et demander la permission caméra
  static Future<bool> checkCameraPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.camera.status;
      if (status.isGranted) return true;
      if (status.isDenied) {
        final result = await Permission.camera.request();
        return result.isGranted;
      }
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
    } else {
      final status = await Permission.camera.request();
      return status.isGranted;
    }
    return false;
  }

  // Vérifier et demander la permission galerie
  static Future<bool> checkGalleryPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.status;
      if (status.isGranted) return true;
      if (status.isDenied) {
        final result = await Permission.photos.request();
        return result.isGranted;
      }
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
    } else {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return false;
  }

  // Vérifier et demander la permission notifications
  static Future<bool> checkNotificationPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.notification.status;
      if (status.isGranted) return true;
      final result = await Permission.notification.request();
      return result.isGranted;
    }
    return true; // Android: notifications accordées par défaut
  }

  // Vérifier et demander la permission localisation
  static Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await Permission.location.request();
      if (result.isGranted) return true;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  // Vérifier toutes les permissions nécessaires
  static Future<Map<String, bool>> checkAllPermissions() async {
    final permissions = {
      'camera': await checkCameraPermission(),
      'gallery': await checkGalleryPermission(),
      'notifications': await checkNotificationPermission(),
      'location': await checkLocationPermission(),
    };
    return permissions;
  }

  // Afficher un dialogue pour demander une permission
  static Future<bool> showPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
    required Future<bool> Function() permissionRequest,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Refuser'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Autoriser'),
          ),
        ],
      ),
    );

    if (result == true) {
      return await permissionRequest();
    }
    return false;
  }
}