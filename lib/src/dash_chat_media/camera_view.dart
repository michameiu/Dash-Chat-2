part of '../../dash_chat_2.dart';

// Data class to pass recording data between isolates
class RecordingData {
  final String videoPath;
  final bool success;

  RecordingData(this.videoPath, this.success);
}

// Isolate function for handling video recording
Future<RecordingData> _handleVideoRecordingInIsolate(String videoPath) async {
  try {
    final file = File(videoPath);
    if (await file.exists()) {
      // Add any video processing here if needed
      await Future.delayed(
          const Duration(milliseconds: 500)); // Ensure file is written
      return RecordingData(videoPath, true);
    }
    return RecordingData(videoPath, false);
  } catch (e) {
    print('Error in recording isolate: $e');
    return RecordingData(videoPath, false);
  }
}

class CameraView extends StatefulWidget {
  final MediaController mediaController;
  final void Function([String? videoPath]) onClose;

  const CameraView({
    Key? key,
    required this.mediaController,
    required this.onClose,
  }) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late final CameraViewController cameraController;

  @override
  void initState() {
    super.initState();
    cameraController = CameraViewController(
      mediaController: widget.mediaController,
      closeCallback: widget.onClose,
      context: context,
    );
    Get.put(cameraController);
  }

  @override
  void dispose() {
    Get.delete<CameraViewController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Obx(() {
            if (cameraController.errorMessage.isNotEmpty) {
              return Center(
                child: Text(
                  cameraController.errorMessage.value,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            if (!cameraController.isInitialized.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Stack(
              children: [
                RepaintBoundary(
                  child: CameraPreview(
                    cameraController.cameraController.value!,
                    key: const ValueKey('camera_preview'),
                  ),
                ),
                _buildControls(),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => GestureDetector(
                    onTap: cameraController.toggleRecording,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        color: cameraController.isRecording.value
                            ? Colors.red
                            : Colors.transparent,
                      ),
                    ),
                  )),
            ],
          ),
        ),
        Positioned(
          top: 24,
          right: 24,
          child: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => widget.onClose(null),
          ),
        ),
      ],
    );
  }
}

class CameraViewController extends GetxController {
  final MediaController mediaController;
  final void Function([String? videoPath]) closeCallback;
  final BuildContext context;

  final Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  final RxBool isRecording = false.obs;
  final RxBool isInitialized = false.obs;
  final RxString errorMessage = RxString('');
  String? _currentVideoPath;
  bool _isDisposing = false;

  CameraViewController({
    required this.mediaController,
    required this.closeCallback,
    required this.context,
  });

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
  }

  Future<void> _disposeCurrentCamera() async {
    if (_isDisposing) return;
    _isDisposing = true;

    try {
      final currentController = cameraController.value;
      if (currentController != null) {
        if (isRecording.value) {
          try {
            isRecording.value = false;
            await currentController.stopVideoRecording();
          } catch (e) {
            print('Error stopping recording during disposal: $e');
          }
          // Add delay after stopping recording
          await Future.delayed(const Duration(milliseconds: 300));
        }

        // Remove listener before disposal
        currentController.removeListener(_onCameraError);

        // Add delay before disposal
        await Future.delayed(const Duration(milliseconds: 300));
        await currentController.dispose();
        cameraController.value = null;
        isInitialized.value = false;
      }
    } catch (e) {
      print('Error disposing camera: $e');
    } finally {
      _isDisposing = false;
    }
  }

  void _onCameraError() {
    final controller = cameraController.value;
    if (controller != null && controller.value.hasError) {
      errorMessage.value = 'Camera error: ${controller.value.errorDescription}';
      _handleCameraError();
    }
  }

  Future<void> _handleCameraError() async {
    // Reset recording state
    isRecording.value = false;

    // Try to reinitialize the camera
    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Ensure any existing camera is properly disposed
      await _disposeCurrentCamera();
      await Future.delayed(const Duration(milliseconds: 500));

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        errorMessage.value = 'No cameras available';
        return;
      }

      final camera = cameras.first;
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Listen for camera errors
      controller.addListener(_onCameraError);

      try {
        await controller.initialize();
        // Add a small delay after initialization
        await Future.delayed(const Duration(milliseconds: 500));
        cameraController.value = controller;
        isInitialized.value = true;
      } catch (e) {
        await controller.dispose();
        errorMessage.value = 'Failed to initialize camera: $e';
      }
    } catch (e) {
      errorMessage.value = 'Error initializing camera: $e';
    }
  }

  Future<String> _getVideoFilePath() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String videosDir = path.join(appDir.path, 'Videos');
    await Directory(videosDir).create(recursive: true);
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return path.join(videosDir, 'VID_$timestamp.mp4');
  }

  Future<void> toggleRecording() async {
    if (cameraController.value == null || !isInitialized.value || _isDisposing)
      return;

    try {
      if (isRecording.value) {
        // Add a small delay before stopping recording
        await Future.delayed(const Duration(milliseconds: 200));

        final XFile video = await cameraController.value!.stopVideoRecording();
        isRecording.value = false;

        // Add a delay after stopping recording
        await Future.delayed(const Duration(milliseconds: 500));

        if (_currentVideoPath != null) {
          // Process recording in isolate
          final result = await compute(
            _handleVideoRecordingInIsolate,
            video.path,
          );

          if (result.success) {
            mediaController.addMediaToCurrentMessage(
              ChatMedia(
                type: MediaType.video,
                url: result.videoPath,
                fileName: path.basename(result.videoPath),
              ),
            );
            Navigator.of(context).pop(result.videoPath);
            closeCallback(result.videoPath);
          } else {
            errorMessage.value = 'Failed to process video recording';
          }
        }
      } else {
        _currentVideoPath = await _getVideoFilePath();
        // Add a small delay before starting recording
        await Future.delayed(const Duration(milliseconds: 200));
        await cameraController.value!.startVideoRecording();
        isRecording.value = true;
      }
    } catch (e) {
      errorMessage.value = 'Error recording video: $e';
      isRecording.value = false;
      // Try to reinitialize camera on error
      await _handleCameraError();
    }
  }

  @override
  void onClose() {
    _disposeCurrentCamera();
    super.onClose();
  }
}
