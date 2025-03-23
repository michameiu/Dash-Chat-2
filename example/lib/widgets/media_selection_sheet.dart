import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import '../controllers/media_controller.dart';

class MediaSelectionSheet extends StatelessWidget {
  final MediaController controller;

  const MediaSelectionSheet({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              Navigator.pop(context);
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
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
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a Photo'),
            onTap: () async {
              Navigator.pop(context);
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
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Choose Video'),
            onTap: () async {
              Navigator.pop(context);
              final ImagePicker picker = ImagePicker();
              final XFile? video = await picker.pickVideo(
                source: ImageSource.gallery,
              );
              if (video != null) {
                controller.addMediaToCurrentMessage(
                  ChatMedia(
                    type: MediaType.video,
                    url: video.path,
                    fileName: video.name,
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Record Video'),
            onTap: () async {
              Navigator.pop(context);
              final ImagePicker picker = ImagePicker();
              final XFile? video = await picker.pickVideo(
                source: ImageSource.camera,
              );
              if (video != null) {
                controller.addMediaToCurrentMessage(
                  ChatMedia(
                    type: MediaType.video,
                    url: video.path,
                    fileName: video.name,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
