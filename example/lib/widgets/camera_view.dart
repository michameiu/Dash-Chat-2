import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:dash_chat_2/src/dash_chat_media/media_controller.dart';

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
        appBar: AppBar(
          title: const Text('Camera'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
          ),
        ),
        body: Center(
          child: Text(_errorMessage!),
        ),
      );
    }

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose,
        ),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.fiber_manual_record,
                    color: _isRecording ? Colors.red : Colors.white,
                    size: 32,
                  ),
                  onPressed: _toggleRecording,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
