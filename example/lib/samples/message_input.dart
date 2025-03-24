import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:get/get.dart';
import 'package:dash_chat_2/src/dash_chat_media/media_controller.dart';
import 'package:examples/data.dart';

class MessageInputSample extends StatelessWidget {
  final MediaController controller = Get.put(MediaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Input Example'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return DashChat(
                messageOptions: MessageOptions(
                  currentUserContainerColor: Colors.blue,
                  containerColor: Colors.grey,
                  textColor: Colors.white,
                  messageTextBuilder: (ChatMessage message,
                      ChatMessage? previousMessage, ChatMessage? nextMessage) {
                    if (message.input != null) {
                      return MessageInputWidget(
                        input: message.input!,
                        onConfirm: (selected) {
                          message.input = ChatMessageInput(
                            options: message.input!.options,
                            type: message.input!.type,
                            selected: selected,
                          );
                          controller.messages.refresh();
                        },
                      );
                    }
                    return DefaultMessageText(
                      message: message,
                      isOwnMessage:
                          message.user.id == controller.currentUser.value?.id,
                    );
                  },
                ),
                inputOptions: InputOptions(
                  inputTextStyle: const TextStyle(color: Colors.black),
                  inputDecoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  leading: [
                    const Icon(Icons.emoji_emotions, color: Colors.blue),
                    const Icon(Icons.attach_file, color: Colors.blue),
                  ],
                  trailing: [
                    const Icon(Icons.send, color: Colors.blue),
                  ],
                  alwaysShowSend: true,
                  sendOnEnter: true,
                  inputMaxLines: 5,
                ),
                currentUser: controller.currentUser.value!,
                readOnly: false,
                onSend: (ChatMessage m) {
                  m.input = ChatMessageInput(
                    options: ['leaks', 'functionality'],
                    type: ChatMessageInputType.checkbox,
                  );
                  controller.addMessage(m);
                },
                messages: controller.messages.value,
              );
            }),
          ),
        ],
      ),
    );
  }
}
