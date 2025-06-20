import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:examples/samples/avatar.dart';
import 'package:examples/samples/basic.dart';
import 'package:examples/samples/media.dart';
import 'package:examples/samples/media_example.dart';
import 'package:examples/samples/mention.dart';
import 'package:examples/samples/quick_replies_sample.dart';
import 'package:examples/samples/send_on_enter.dart';
import 'package:examples/samples/theming.dart';
import 'package:examples/samples/message_input.dart';
import 'package:examples/samples/typing_users_sample.dart';
import 'package:examples/samples/media_uploader_example.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.lazyPut(() => MediaController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dash Chat Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dash Chat Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => push(Basic()),
              child: const Text('Basic'),
            ),
            ElevatedButton(
              onPressed: () => push(Media()),
              child: const Text('Chat media (old)'),
            ),
            ElevatedButton(
              onPressed: () => push(MediaExample()),
              child: const Text('Chat media (new)'),
            ),
            ElevatedButton(
              onPressed: () => push(AvatarSample()),
              child: const Text('All user possibilities'),
            ),
            ElevatedButton(
              onPressed: () => push(QuickRepliesSample()),
              child: const Text('Quick replies'),
            ),
            ElevatedButton(
              onPressed: () => push(TypingUsersSample()),
              child: const Text('Typing users'),
            ),
            ElevatedButton(
              onPressed: () => push(MessageInputSample()),
              child: const Text('Input Samples'),
            ),
            ElevatedButton(
              onPressed: () => push(SendOnEnter()),
              child: const Text('Send on enter'),
            ),
            ElevatedButton(
              onPressed: () => push(MentionSample()),
              child: const Text('Mention'),
            ),
            ElevatedButton(
              onPressed: () => push(ThemeSample()),
              child: const Text('Theming'),
            ),
            ElevatedButton(
              onPressed: () => push(MediaUploaderExample()),
              child: const Text('Media Uploader'),
            ),
          ],
        ),
      ),
    );
  }

  void push(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }
}
