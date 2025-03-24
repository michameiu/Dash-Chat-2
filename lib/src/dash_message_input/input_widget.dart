import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'input_controller.dart';

class MessageInputWidget extends StatelessWidget {
  final ChatMessageInput input;
  final Function(List<String>) onConfirm;

  const MessageInputWidget({
    Key? key,
    required this.input,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InputController());
    final theme = Theme.of(context);

    return Obx(() {
      if (controller.isConfirmed.value) {
        return Text(
          controller.selectedOptions.join(', '),
          style: theme.textTheme.bodyMedium,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (input.type == ChatMessageInputType.checkbox) ...[
            ...input.options.map((option) => CheckboxListTile(
                  title: Text(option),
                  value: controller.selectedOptions.contains(option),
                  onChanged: (value) => controller.toggleOption(option),
                )),
          ] else if (input.type == ChatMessageInputType.scale) ...[
            Text('${input.min} - ${input.max}'),
            Slider(
              value: controller.scaleValue.value.toDouble(),
              min: input.min?.toDouble() ?? 0,
              max: input.max?.toDouble() ?? 100,
              divisions: (input.max ?? 100) - (input.min ?? 0),
              label: controller.scaleValue.value.toString(),
              onChanged: (value) => controller.setScaleValue(value.round()),
            ),
          ],
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (input.type == ChatMessageInputType.checkbox) {
                onConfirm(controller.selectedOptions);
              } else {
                onConfirm([controller.scaleValue.value.toString()]);
              }
              controller.confirmInput();
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    });
  }
}
