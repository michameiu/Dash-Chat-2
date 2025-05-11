import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:get/get.dart';

class MediaUploaderController extends GetxController {
  Rx<ChatMedia?> selectedMedia = Rx<ChatMedia?>(null);

  void setMedia(ChatMedia media) {
    selectedMedia.value = media;
  }
}

class MediaUploaderExample extends StatelessWidget {
  final MediaUploaderController controller = Get.put(MediaUploaderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MediaUploader Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MediaUploader(
              onMediaSelected: controller.setMedia,
            ),
            const SizedBox(height: 24),
            Obx(() {
              final media = controller.selectedMedia.value;
              if (media == null) {
                return const Text('No media selected.');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type: 	${media.type}'),
                  Text('File: ${media.fileName}'),
                  Text('Path: ${media.url}'),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
