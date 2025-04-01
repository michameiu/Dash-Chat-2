import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:get/get.dart';
import './camera_controller.dart' as local;

class CameraView extends StatelessWidget {
  final MediaController mediaController;
  final Function() onClose;

  const CameraView({
    Key? key,
    required this.mediaController,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(local.CameraViewController(mediaController: mediaController));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
      ),
      body: Obx(() {
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(controller.errorMessage.value),
          );
        }

        if (!controller.isInitialized.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Stack(
          children: [
            CameraPreview(controller.deviceCameraController!),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Obx(() => IconButton(
                        icon: Icon(
                          controller.isRecording.value
                              ? Icons.stop
                              : Icons.fiber_manual_record,
                          color: controller.isRecording.value
                              ? Colors.red
                              : Colors.white,
                          size: 32,
                        ),
                        onPressed: controller.toggleRecording,
                      )),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
