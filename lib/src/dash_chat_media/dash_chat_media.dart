part of '../../dash_chat_2.dart';

class DashChatMedia extends StatelessWidget {
  final Function(ChatMessage) onMessage;
  final Function(ChatMessage)? onConfirmInput;
  final ChatUser currentUser;
  final bool readOnly;
  final MessageOptions? messageOptions;
  final InputOptions? inputOptions;
  final List<ChatUser>? typingUsers;
  final QuickReplyOptions quickReplyOptions;
  final MessageListOptions messageListOptions;
  final String inputHintText;

  const DashChatMedia({
    Key? key,
    required this.onMessage,
    this.quickReplyOptions = const QuickReplyOptions(),
    required this.currentUser,
    this.readOnly = false,
    this.messageOptions,
    this.inputOptions,
    this.onConfirmInput,
    this.inputHintText = 'Flag an issue',
    this.messageListOptions = const MessageListOptions(),
    this.typingUsers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaController controller = Get.find();
    controller.currentUser.value = currentUser;

    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.currentUser.value == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return DashChat(
              typingUsers: typingUsers,
              quickReplyOptions: quickReplyOptions,
              messageOptions: MessageOptions(
                showCurrentUserAvatar:
                    messageOptions?.showCurrentUserAvatar ?? false,
                showOtherUsersAvatar:
                    messageOptions?.showOtherUsersAvatar ?? true,
                showOtherUsersName: messageOptions?.showOtherUsersName ?? true,
                userNameBuilder: messageOptions?.userNameBuilder,
                avatarBuilder: messageOptions?.avatarBuilder,
                onPressAvatar: messageOptions?.onPressAvatar,
                onLongPressAvatar: messageOptions?.onLongPressAvatar,
                onLongPressMessage: messageOptions?.onLongPressMessage,
                onPressMessage: messageOptions?.onPressMessage,
                onPressMention: messageOptions?.onPressMention,
                containerColor:
                    messageOptions?.containerColor ?? const Color(0xFFF5F5F5),
                textColor: messageOptions?.textColor ?? Colors.black,
                messagePadding:
                    messageOptions?.messagePadding ?? const EdgeInsets.all(11),
                maxWidth: messageOptions?.maxWidth,
                messageDecorationBuilder:
                    messageOptions?.messageDecorationBuilder,
                top: messageOptions?.top,
                bottom: messageOptions?.bottom,
                messageRowBuilder: messageOptions?.messageRowBuilder,
                messageTextBuilder: (ChatMessage message,
                    ChatMessage? previousMessage, ChatMessage? nextMessage) {
                  if (message.input != null) {
                    // return Text(message.text ?? '');
                    return MessageInputWidget(
                      message: message,
                      onConfirm: (selected) {
                        message.input = ChatMessageInput(
                          options: message.input!.options,
                          type: message.input!.type,
                          selected: selected,
                          isConfirmed: true,
                        );
                        var inputController =
                            Get.find<InputController>(tag: message.uuid);
                        // inputController.confirmInput();
                        print('message: ${message.toJson()}');
                        controller.messages.refresh();
                        if (onConfirmInput != null) {
                          onConfirmInput!(message);
                        }
                      },
                    );
                  }
                  return messageOptions?.messageTextBuilder
                          ?.call(message, previousMessage, nextMessage) ??
                      DefaultMessageText(
                        message: message,
                        isOwnMessage:
                            message.user.id == controller.currentUser.value?.id,
                      );
                },
                parsePatterns: messageOptions?.parsePatterns,
                textBeforeMedia: messageOptions?.textBeforeMedia ?? true,
                onTapMedia: messageOptions?.onTapMedia,
                showTime: messageOptions?.showTime ?? false,
                timeFormat: messageOptions?.timeFormat,
                messageTimeBuilder: messageOptions?.messageTimeBuilder,
                messageMediaBuilder: messageOptions?.messageMediaBuilder,
                borderRadius: messageOptions?.borderRadius ?? 18.0,
                marginDifferentAuthor: messageOptions?.marginDifferentAuthor ??
                    const EdgeInsets.only(top: 15),
                marginSameAuthor: messageOptions?.marginSameAuthor ??
                    const EdgeInsets.only(top: 2),
                spaceWhenAvatarIsHidden:
                    messageOptions?.spaceWhenAvatarIsHidden ?? 10.0,
                timeFontSize: messageOptions?.timeFontSize ?? 10.0,
                timePadding: messageOptions?.timePadding ??
                    const EdgeInsets.only(top: 5),
                markdownStyleSheet: messageOptions?.markdownStyleSheet,
              ),
              inputOptions: inputOptions ?? const InputOptions(),
              currentUser: controller.currentUser.value!,
              readOnly: readOnly,
              messageListOptions: messageListOptions,
              onSend: (ChatMessage m) {
                print('onSend11: $onMessage');
                // controller.addMessage(m, onSendMessage: onMessage);
              },
              messages: controller.messages.value,
            );
          }),
        ),
        MediaPreview(controller: controller),
        Obx(() => chat_input.InputWidget(
              hintText: inputHintText,
              showMicOverride:
                  controller.currentChatMessage.value?.medias?.isEmpty ?? true,
              onSendAudio: (audioFile, duration) {
                controller.sendAudio(audioFile.path, duration);
              },
              onSendText: (text) {
                controller.sendText(text, onSendMessage: onMessage);
              },
              onAttachmentClick: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) =>
                      MediaSelectionSheet(controller: controller),
                );
              },
            )),
      ],
    );
  }
}
