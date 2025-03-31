import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

class InputExample extends StatefulWidget {
  const InputExample({Key? key}) : super(key: key);

  @override
  State<InputExample> createState() => _InputExampleState();
}

class _InputExampleState extends State<InputExample> {
  final ChatUser _user = ChatUser(
    id: '1',
    firstName: 'User',
  );

  final ChatUser _bot = ChatUser(
    id: '2',
    firstName: 'Bot',
  );

  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _addInitialMessages();
  }

  void _addInitialMessages() {
    _messages.add(
      ChatMessage(
        text: 'Please select your preferences:',
        user: _bot,
        createdAt: DateTime.now(),
        input: ChatMessageInput(
          type: ChatMessageInputType.checkbox,
          options: ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
        ),
      ),
    );

    _messages.add(
      ChatMessage(
        text: 'Rate your experience (1-5):',
        user: _bot,
        createdAt: DateTime.now(),
        input: ChatMessageInput(
          type: ChatMessageInputType.scale,
          options: ['1', '2', '3', '4', '5'],
          min: 1,
          max: 5,
        ),
      ),
    );
  }

  void _handleInputConfirm(ChatMessage message, List<String> selected) {
    setState(() {
      message.input = ChatMessageInput(
        type: message.input!.type,
        options: message.input!.options,
        selected: selected,
        min: message.input!.min,
        max: message.input!.max,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Example'),
      ),
      body: DashChat(
        currentUser: _user,
        messages: _messages,
        onSend: (ChatMessage message) {
          setState(() {
            _messages.add(message);
          });
        },
        messageOptions: MessageOptions(
          messageTextBuilder: (ChatMessage message,
              ChatMessage? previousMessage, ChatMessage? nextMessage) {
            // if (message.input != null) {
            //   return MessageInputWidget(
            //     input: message.input!,
            //     onConfirm: (selected) => _handleInputConfirm(message, selected),
            //   );
            // }
            return DefaultMessageText(
              message: message,
              isOwnMessage: message.user.id == _user.id,
            );
          },
        ),
      ),
    );
  }
}
