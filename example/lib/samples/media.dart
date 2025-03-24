import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:examples/data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_input/chat_input.dart' as chat_input;
import '../widgets/media_preview.dart';
import '../widgets/media_selection_sheet.dart';
import 'package:dash_chat_2/src/dash_chat_media/media_controller.dart';

class Media extends StatelessWidget {
  final MediaController controller = Get.put(MediaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media example'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.currentUser.value == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return DashChat(
                messageOptions: const MessageOptions(),
                inputOptions: const InputOptions(),
                currentUser: controller.currentUser.value!,
                readOnly: true,
                onSend: (ChatMessage m) {
                  controller.addMessage(m);
                },
                messages: controller.messages.value,
              );
            }),
          ),
          MediaPreview(controller: controller),
          chat_input.InputWidget(
            onSendAudio: (audioFile, duration) {
              controller.sendAudio(audioFile.path, duration);
            },
            onSendText: (text) {
              controller.sendText(text);
            },
            onAttachmentClick: () {
              showModalBottomSheet(
                context: context,
                builder: (context) =>
                    MediaSelectionSheet(controller: controller),
              );
            },
          ),
        ],
      ),
    );
  }
}
