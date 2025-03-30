import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:get/get.dart';
import 'package:examples/data.dart';

class MessageInputSample extends StatelessWidget {
  final MediaController controller = Get.put(MediaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Input1 Example'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              // return Text("data");
              return DashChatMedia(
                messageOptions: MessageOptions(
                  currentUserContainerColor: Colors.blue,
                  containerColor: Colors.grey,
                  textColor: Colors.white,
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
                readOnly: true,
                onMessage: (ChatMessage m) {
                  print("WHello");
                  m.input = ChatMessageInput(
                    options: ['leaks', 'functionality'],
                    type: ChatMessageInputType.checkbox,
                  );
                  controller.addFinalMessage(m);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
