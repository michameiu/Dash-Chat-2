import 'package:get/get.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:examples/data.dart';

class MediaController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final currentUser = user.obs;
  final currentChatMessage = Rxn<ChatMessage>();
  final isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    messages.value = media;
    isInitialized.value = true;
  }

  void addMessage(ChatMessage message) {
    messages.insert(0, message);
  }

  void _addMediaToCurrentMessage(ChatMedia media) {
    if (currentChatMessage.value == null) {
      currentChatMessage.value = ChatMessage(
        user: currentUser.value,
        createdAt: DateTime.now(),
        medias: [media],
      );
    } else {
      currentChatMessage.value!.medias?.add(media);
    }
  }

  void sendAudio(String path, Duration duration) {
    if (!isInitialized.value || currentUser.value == null) return;

    final fileName = path.split('/').last;
    final media = ChatMedia(
      type: MediaType.audio,
      url: path,
      fileName: fileName,
      customProperties: {'duration': duration.inMilliseconds},
    );
    _addMediaToCurrentMessage(media);
  }

  void sendText(String text) {
    if (!isInitialized.value || currentUser.value == null) return;

    if (currentChatMessage.value != null) {
      final message = currentChatMessage.value!;
      message.text = text;
      addMessage(message);
      currentChatMessage.value = null;
    } else {
      addMessage(ChatMessage(
        text: text,
        user: currentUser.value!,
        createdAt: DateTime.now(),
      ));
    }
  }
}
