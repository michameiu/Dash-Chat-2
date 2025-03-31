part of '../../dash_chat_2.dart';

class MessageInputWidget extends StatelessWidget {
  final ChatMessage message;
  final Function(List<String>) onConfirm;

  MessageInputWidget({
    Key? key,
    required this.message,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InputController(), tag: message.uuid);
    final theme = Theme.of(context);

    return Obx(() {
      return Column(
        children: [
          Text(
            message.text ?? '',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          if (controller.isConfirmed.value)
            Text(
              controller.selectedOptions.join(', '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          if (!controller.isConfirmed.value)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.input?.type == ChatMessageInputType.checkbox) ...[
                  ...message.input!.options.map((option) => CheckboxListTile(
                        title: Text(
                          option,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        // checkColor: Theme.of(context).colorScheme.onPrimary,
                        value: controller.selectedOptions.contains(option),
                        onChanged: (value) => controller.toggleOption(option),
                      )),
                ] else if (message.input?.type ==
                    ChatMessageInputType.scale) ...[
                  Text('${message.input?.min} - ${message.input?.max}'),
                  Slider(
                    value: controller.scaleValue.value.toDouble(),
                    min: message.input?.min?.toDouble() ?? 0,
                    max: message.input?.max?.toDouble() ?? 100,
                    divisions:
                        (message.input?.max ?? 100) - (message.input?.min ?? 0),
                    label: controller.scaleValue.value.toString(),
                    onChanged: (value) =>
                        controller.setScaleValue(value.round()),
                  ),
                ],
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    if (message.input?.type == ChatMessageInputType.checkbox) {
                      onConfirm(controller.selectedOptions);
                    } else {
                      onConfirm([controller.scaleValue.value.toString()]);
                    }
                    controller.confirmInput();
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ),
        ],
      );
    });
  }
}
