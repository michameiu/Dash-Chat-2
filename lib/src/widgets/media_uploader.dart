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
      final mediaController = Get.find<MediaController>();
      final videoPath = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (context) => CameraView(
            mediaController: mediaController,
            onClose: ([String? _]) {
              // Navigator.of(context).pop(_);
            },
          ),
        ),
      );
      if (videoPath != null && videoPath.isNotEmpty) {
        onMediaSelected(ChatMedia(
          type: MediaType.video,
          url: videoPath,
          fileName: videoPath.split('/').last,
        ));
      }
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    if (await _checkAndRequestPermissions(context)) {
      final FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final String fileName = result.files.single.name;
        final String extension = fileName.split('.').last.toLowerCase();

        // Define allowed extensions
        const List<String> imageExtensions = [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'bmp',
          'webp'
        ];
        const List<String> videoExtensions = [
          'mp4',
          'mov',
          'avi',
          'mkv',
          'wmv',
          'flv',
          '3gp'
        ];
        const List<String> audioExtensions = [
          'mp3',
          'wav',
          'aac',
          'm4a',
          'ogg',
          'flac'
        ];

        MediaType? mediaType;
        if (imageExtensions.contains(extension)) {
          mediaType = MediaType.image;
        } else if (videoExtensions.contains(extension)) {
          mediaType = MediaType.video;
        } else if (audioExtensions.contains(extension)) {
          mediaType = MediaType.audio;
        }

        if (mediaType != null) {
          onMediaSelected(ChatMedia(
            type: mediaType,
            url: result.files.single.path!,
            fileName: fileName,
          ));
        } else {
          // Show error dialog for unsupported file types
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Unsupported File Type'),
                content:
                    const Text('Please select an image, video, or audio file.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      }
    }
  }

  void _onMicPressed(BuildContext context) {
    final audioController = Get.put(_AudioRecorderController());
    if (!audioController.isRecording.value) {
      audioController.startRecording();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return Obx(() => AlertDialog(
                title: const Text('Recording...'),
                content: Row(
                  children: [
                    const Icon(Icons.mic, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(_formatDuration(audioController.timer.value)),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      audioController.cancelRecording();
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final path = await audioController.stopRecording();
                      if (path != null) {
                        onMediaSelected(ChatMedia(
                          type: MediaType.audio,
                          url: path,
                          fileName: path.split('/').last,
                        ));
                      }
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Send'),
                  ),
                ],
              ));
        },
      );
    }
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
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
