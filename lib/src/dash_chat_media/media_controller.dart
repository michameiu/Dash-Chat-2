part of '../../dash_chat_2.dart';

class MediaController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final currentUser = Rxn<ChatUser>();
  final currentChatMessage = Rxn<ChatMessage>();
  final isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    isInitialized.value = true;
    currentUser.value = ChatUser(
      id: '1',
      firstName: 'John Doe',
    );
  }

  void addFinalMessage(ChatMessage message) {
    messages.insert(0, message);
  }

  void addMessage(ChatMessage message,
      {Function(ChatMessage mess)? onSendMessage}) {
    if (onSendMessage != null) {
      onSendMessage(message);
    } else {
      print('onSendMessage: $onSendMessage');
      // print('addMessage: $message');
      messages.insert(0, message);
    }
  }

  void addMediaToCurrentMessage(ChatMedia media) {
    if (currentUser.value == null) return;

    if (currentChatMessage.value == null) {
      currentChatMessage.value = ChatMessage(
        user: currentUser.value!,
        createdAt: DateTime.now(),
        medias: [media].obs,
      );
    } else {
      currentChatMessage.value!.medias?.add(media);
      currentChatMessage.refresh();
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
    addMediaToCurrentMessage(media);
  }

  void sendText(String text, {dynamic Function(ChatMessage)? onSendMessage}) {
    if (!isInitialized.value || currentUser.value == null) return;

    if (currentChatMessage.value != null) {
      final message = currentChatMessage.value!;
      message.text = text;
      addMessage(message, onSendMessage: onSendMessage);
      currentChatMessage.value = null;
    } else {
      addMessage(
          ChatMessage(
            text: text,
            user: currentUser.value!,
            createdAt: DateTime.now(),
          ),
          onSendMessage: onSendMessage);
    }
  }

  void removeMedia(int index) {
    if (currentChatMessage.value?.medias != null) {
      currentChatMessage.value!.medias!.removeAt(index);
      if (currentChatMessage.value!.medias!.isEmpty) {
        currentChatMessage.value = null;
      } else {
        currentChatMessage.refresh();
      }
    }
  }

  void clearMedia() {
    currentChatMessage.value = null;
  }
}
