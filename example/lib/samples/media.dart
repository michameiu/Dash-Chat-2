import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:examples/data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_input/chat_input.dart';
import '../controllers/media_controller.dart';

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
            child: Obx(() => DashChat(
                  messageOptions: const MessageOptions(),
                  inputOptions: const InputOptions(),
                  currentUser: controller.currentUser.value,
                  readOnly: true,
                  onSend: (ChatMessage m) {
                    controller.addMessage(m);
                  },
                  messages: controller.messages,
                )),
          ),
          InputWidget(
            onSendAudio: (audioFile, duration) {
              controller.sendAudio(audioFile.path, duration);
            },
            onSendText: (text) {
              controller.sendText(text);
            },
            onAttachmentClick: () async {
              final ImagePicker picker = ImagePicker();
              // Handle image picking here
            },
          ),
        ],
      ),
    );
  }
}
