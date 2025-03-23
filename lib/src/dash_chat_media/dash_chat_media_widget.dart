export 'dash_chat_media_widget.dart';
export 'media_controller.dart';
export 'media_preview.dart';
export 'media_selection_sheet.dart';
export 'camera_view.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:chat_input/chat_input.dart';
import 'media_controller.dart';
import 'media_preview.dart';
import 'media_selection_sheet.dart';

class DashChatMedia extends StatelessWidget {
  final Function(ChatMessage) onMessage;
  final ChatUser currentUser;
  final bool readOnly;
  final MessageOptions? messageOptions;
  final InputOptions? inputOptions;

  const DashChatMedia({
    Key? key,
    required this.onMessage,
    required this.currentUser,
    this.readOnly = false,
    this.messageOptions,
    this.inputOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MediaController());
    controller.currentUser.value = currentUser;

    return Column(
      children: [
        Expanded(
          child: Obx(() {
            final user = controller.currentUser.value;
            if (user == null) return const SizedBox.shrink();

            return DashChat(
              messageOptions: messageOptions ?? const MessageOptions(),
              inputOptions: inputOptions ?? const InputOptions(),
              currentUser: user,
              readOnly: readOnly,
              onSend: (ChatMessage m) {
                controller.addMessage(m);
                onMessage(m);
              },
              messages: controller.messages.value,
            );
          }),
        ),
        MediaPreview(controller: controller),
        InputWidget(
          onSendAudio: (audioFile, duration) {
            controller.sendAudio(audioFile.path, duration);
          },
          onSendText: (text) {
            controller.sendText(text);
          },
          onAttachmentClick: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => MediaSelectionSheet(controller: controller),
            );
          },
        ),
      ],
    );
  }
}
