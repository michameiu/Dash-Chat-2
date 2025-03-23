import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import '../controllers/media_controller.dart';
import 'camera_view.dart';

class MediaSelectionSheet extends StatelessWidget {
  final MediaController controller;

  const MediaSelectionSheet({
    Key? key,
    required this.controller,
  }) : super(key: key);

  Future<List<Permission>> _getRequiredPermissions() async {
    List<Permission> permissions = [Permission.camera, Permission.microphone];

    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;

      if (sdkInt >= 33) {
        permissions.addAll([
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ]);
      } else {
        permissions.add(Permission.storage);
      }
    } else if (Platform.isIOS) {
      permissions.add(Permission.photos);
    }

    return permissions;
  }

  Future<bool> _checkAndRequestPermissions(BuildContext context) async {
    final permissions = await _getRequiredPermissions();

    // Check current status of all permissions
    Map<Permission, PermissionStatus> statuses = {};
    for (var permission in permissions) {
      statuses[permission] = await permission.status;
    }

    // If all permissions are granted, return true
    if (statuses.values.every((status) => status.isGranted)) {
      return true;
    }

    // Request permissions that aren't granted
    final permissionsToRequest = permissions
        .where((permission) => !statuses[permission]!.isGranted)
        .toList();

    final results = await permissions.request();
    statuses.addAll(results);

    // Check if any permission is permanently denied
    bool isPermanentlyDenied =
        statuses.values.any((status) => status.isPermanentlyDenied);
    if (isPermanentlyDenied && context.mounted) {
      // Show dialog to direct user to app settings
      final bool shouldOpenSettings = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permissions Required'),
              content: const Text(
                  'Some permissions are permanently denied. Please enable them in app settings to record video.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          ) ??
          false;

      if (shouldOpenSettings) {
        await openAppSettings();
      }
      return false;
    }

    return statuses.values.every((status) => status.isGranted);
  }

  void _handleVideoRecording(BuildContext context) async {
    final hasPermissions = await _checkAndRequestPermissions(context);
    if (!hasPermissions) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All permissions must be granted to record video'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CameraView(
            controller: controller,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a Photo'),
            onTap: () async {
              Navigator.pop(context);
              if (await _checkAndRequestPermissions(context)) {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 70,
                );
                if (image != null) {
                  controller.addMediaToCurrentMessage(
                    ChatMedia(
                      type: MediaType.image,
                      url: image.path,
                      fileName: image.name,
                    ),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Record Video'),
            onTap: () {
              Navigator.pop(context);
              _handleVideoRecording(context);
            },
          ),
        ],
      ),
    );
  }
}
