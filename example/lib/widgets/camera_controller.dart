import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraViewController extends GetxController {
  final MediaController mediaController;
  CameraController? deviceCameraController;
  final RxBool isRecording = false.obs;
  final RxBool isInitialized = false.obs;
  final RxString errorMessage = RxString('');

  CameraViewController({required this.mediaController});

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        errorMessage.value = 'No cameras available';
        return;
      }

      final camera = cameras.first;
      deviceCameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await deviceCameraController!.initialize();
      isInitialized.value = true;
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
    if (deviceCameraController == null || !isInitialized.value) return;

    try {
      if (isRecording.value) {
        final XFile video = await deviceCameraController!.stopVideoRecording();
        isRecording.value = false;

        mediaController.addMediaToCurrentMessage(
          ChatMedia(
            type: MediaType.video,
            url: video.path,
            fileName: path.basename(video.path),
          ),
        );
        Get.back();
      } else {
        final videoPath = await _getVideoFilePath();
        await deviceCameraController!.startVideoRecording();
        isRecording.value = true;
      }
    } catch (e) {
      errorMessage.value = 'Error recording video: $e';
    }
  }

  @override
  void onClose() {
    deviceCameraController?.dispose();
    super.onClose();
  }
}
