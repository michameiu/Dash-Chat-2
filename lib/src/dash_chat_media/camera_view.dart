import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'media_controller.dart';

class CameraView extends StatefulWidget {
  final MediaController controller;
  final Function() onClose;

  const CameraView({
    Key? key,
    required this.controller,
    required this.onClose,
  }) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _cameraController;
  bool _isRecording = false;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'No cameras available');
        return;
      }

      final camera = cameras.first;
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      setState(() => _isInitialized = true);
    } catch (e) {
      setState(() => _errorMessage = 'Error initializing camera: $e');
    }
  }

  Future<String> _getVideoFilePath() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String videosDir = path.join(appDir.path, 'Videos');
    await Directory(videosDir).create(recursive: true);
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return path.join(videosDir, 'VID_$timestamp.mp4');
  }

  Future<void> _toggleRecording() async {
    if (_cameraController == null || !_isInitialized) return;

    try {
      if (_isRecording) {
        final XFile video = await _cameraController!.stopVideoRecording();
        setState(() => _isRecording = false);

        if (!mounted) return;

        widget.controller.addMediaToCurrentMessage(
          ChatMedia(
            type: MediaType.video,
            url: video.path,
            fileName: path.basename(video.path),
          ),
        );
        widget.onClose();
      } else {
        final videoPath = await _getVideoFilePath();
        await _cameraController!.startVideoRecording();
        setState(() => _isRecording = true);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error recording video: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            CameraPreview(_cameraController!),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        color: _isRecording ? Colors.red : Colors.transparent,
                      ),
                    ),
                  ),
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
                onPressed: widget.onClose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
