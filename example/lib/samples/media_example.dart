import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:dash_chat_2/src/dash_chat_media/dash_chat_media.dart';
import 'package:examples/data.dart';

class MediaExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Example'),
      ),
      body: DashChatMedia(
        currentUser: user,
        readOnly: true,
        onMessage: (ChatMessage message) {
          print('New message: ${message.text}');
          if (message.medias != null) {
            print('Media count: ${message.medias!.length}');
          }
        },
        messageOptions: const MessageOptions(
          currentUserContainerColor: Colors.blue,
          containerColor: Colors.grey,
        ),
        inputOptions: const InputOptions(
          inputTextStyle: TextStyle(color: Colors.black),
          inputDecoration: InputDecoration(
            hintText: 'Type a message...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
