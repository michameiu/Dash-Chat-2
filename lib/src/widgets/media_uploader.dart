part of '../../dash_chat_2.dart';

class MediaUploader extends StatelessWidget {
  final void Function(ChatMedia media) onMediaSelected;
  final Widget? cameraIcon;
  final Widget? micIcon;
  final Widget? videoIcon;
  final Widget? fileIcon;
  final bool cameraEnabled;
  final bool micEnabled;
  final bool videoEnabled;
  final bool fileEnabled;
  final double spacing;

  const MediaUploader({
    Key? key,
    required this.onMediaSelected,
    this.cameraIcon,
    this.micIcon,
    this.videoIcon,
    this.fileIcon,
    this.cameraEnabled = true,
    this.micEnabled = true,
    this.videoEnabled = true,
    this.fileEnabled = true,
    this.spacing = 0,
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
    Map<Permission, PermissionStatus> statuses = {};
    for (var permission in permissions) {
      statuses[permission] = await permission.status;
    }
    if (statuses.values.every((status) => status.isGranted)) {
      return true;
    }
    final results = await permissions.request();
    statuses.addAll(results);
    bool isPermanentlyDenied =
        statuses.values.any((status) => status.isPermanentlyDenied);
    if (isPermanentlyDenied && context.mounted) {
      final bool shouldOpenSettings = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permissions Required'),
              content: const Text(
                  'Some permissions are permanently denied. Please enable them in app settings.'),
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

  Future<void> _pickImage(BuildContext context) async {
    if (await _checkAndRequestPermissions(context)) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (image != null) {
        onMediaSelected(ChatMedia(
          type: MediaType.image,
          url: image.path,
          fileName: image.name,
        ));
      }
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    if (await _checkAndRequestPermissions(context)) {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
      );
      if (video != null) {
        onMediaSelected(ChatMedia(
          type: MediaType.video,
          url: video.path,
          fileName: video.name,
        ));
      }
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    if (await _checkAndRequestPermissions(context)) {
      final FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        onMediaSelected(ChatMedia(
          type: MediaType.file,
          url: result.files.single.path!,
          fileName: result.files.single.name,
        ));
      }
    }
  }

  // Placeholder for mic/audio recording
  void _onMicPressed(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audio recording not implemented.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = Theme.of(context).colorScheme.primary;
    final List<Widget> buttons = [];
    if (cameraEnabled) {
      buttons.add(IconButton(
        icon: cameraIcon ?? Icon(Icons.camera_alt, color: iconColor, size: 36),
        onPressed: () => _pickImage(context),
      ));
    }
    if (micEnabled) {
      if (buttons.isNotEmpty && spacing > 0) {
        buttons.add(SizedBox(width: spacing));
      }
      buttons.add(IconButton(
        icon: micIcon ?? Icon(Icons.mic, color: iconColor, size: 36),
        onPressed: () => _onMicPressed(context),
      ));
    }
    if (videoEnabled) {
      if (buttons.isNotEmpty && spacing > 0) {
        buttons.add(SizedBox(width: spacing));
      }
      buttons.add(IconButton(
        icon: videoIcon ?? Icon(Icons.videocam, color: iconColor, size: 36),
        onPressed: () => _pickVideo(context),
      ));
    }
    if (fileEnabled) {
      if (buttons.isNotEmpty && spacing > 0) {
        buttons.add(SizedBox(width: spacing));
      }
      buttons.add(IconButton(
        icon: fileIcon ?? Icon(Icons.attach_file, color: iconColor, size: 36),
        onPressed: () => _pickFile(context),
      ));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: buttons,
    );
  }
}
