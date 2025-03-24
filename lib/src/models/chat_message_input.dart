part of '../../dash_chat_2.dart';

enum ChatMessageInputType {
  checkbox,
  scale,
}

class ChatMessageInput {
  final List<String> options;
  final List<String> selected;
  final ChatMessageInputType type;
  final int? min;
  final int? max;
  final int? value;
  bool isConfirmed;
  late final String uuid;

  ChatMessageInput({
    required this.options,
    this.selected = const [],
    required this.type,
    this.min,
    this.max,
    this.isConfirmed = false,
    this.value,
    String? uuid,
  }) {
    this.uuid = uuid ?? Uuid().v4();
  }

  Map<String, dynamic> toJson() {
    return {
      'options': options,
      'selected': selected,
      'type': type.toString(),
      'min': min,
      'max': max,
      'value': value,
      'isConfirmed': isConfirmed,
      'uuid': uuid,
    };
  }

  factory ChatMessageInput.fromJson(Map<String, dynamic> json) {
    return ChatMessageInput(
      options: (json['options'] as List).map((e) => e as String).toList(),
      selected:
          (json['selected'] as List?)?.map((e) => e as String).toList() ?? [],
      type: ChatMessageInputType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      min: json['min'] as int?,
      max: json['max'] as int?,
      uuid: json['uuid'] as String,
      isConfirmed: json['isConfirmed'] as bool ?? false,
      value: json['value'] as int?,
    );
  }
}
