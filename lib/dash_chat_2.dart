library dash_chat_2;

import 'dart:math';
import 'dart:io';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:intl/intl.dart' as intl;
import 'package:video_player/video_player.dart' as vp;
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_input/chat_input.dart' as chat_input;
import 'package:record/record.dart';
import 'dart:async';

import 'src/helpers/link_helper.dart';
import 'src/widgets/image_provider/image_provider.dart';

export 'package:flutter_parsed_text/flutter_parsed_text.dart';
export 'src/dash_message_input/dash_message_input.dart';

part 'src/dash_chat.dart';
part 'src/models/chat_media.dart';
part 'src/models/chat_message.dart';
part 'src/models/chat_message_input.dart';
part 'src/models/chat_user.dart';
part 'src/models/cursor_style.dart';
part 'src/models/input_options.dart';
part 'src/models/mention.dart';
part 'src/models/message_list_options.dart';
part 'src/models/message_options.dart';
part 'src/models/quick_reply.dart';
part 'src/models/quick_reply_options.dart';
part 'src/models/scroll_to_bottom_options.dart';
part 'src/widgets/input_toolbar/default_input_decoration.dart';
part 'src/widgets/input_toolbar/default_send_button.dart';
part 'src/widgets/input_toolbar/input_toolbar.dart';
part 'src/widgets/message_list/default_date_separator.dart';
part 'src/widgets/message_list/default_scroll_to_bottom.dart';
part 'src/widgets/message_list/message_list.dart';
part 'src/widgets/message_row/audio_player.dart';
part 'src/widgets/message_row/default_avatar.dart';
part 'src/widgets/message_row/default_message_decoration.dart';
part 'src/widgets/message_row/default_message_text.dart';
part 'src/widgets/message_row/default_parse_patterns.dart';
part 'src/widgets/message_row/default_user_name.dart';
part 'src/widgets/message_row/media_container.dart';
part 'src/widgets/message_row/message_row.dart';
part 'src/widgets/message_row/text_container.dart';
part 'src/widgets/message_row/video_player.dart';
part 'src/widgets/quick_replies/default_quick_reply.dart';
part 'src/widgets/quick_replies/quick_replies.dart';
part 'src/widgets/typing_users/default_typing_builder.dart';
part 'src/widgets/typing_users/typing_indicator.dart';
part 'src/dash_message_input/input_controller.dart';
part 'src/dash_message_input/input_widget.dart';
part 'src/dash_chat_media/media_controller.dart';
part 'src/dash_chat_media/dash_chat_media.dart';
part 'src/dash_chat_media/media_preview.dart';
part 'src/dash_chat_media/media_selection_sheet.dart';
part 'src/dash_chat_media/camera_view.dart';
part 'src/widgets/media_uploader.dart';

class _AudioRecorderController extends GetxController {
  final isRecording = false.obs;
  final timer = 0.obs;
  String? filePath;
  AudioRecorder? _recorder;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _recorder = AudioRecorder();
  }

  Future<void> startRecording() async {
    if (await _recorder!.hasPermission()) {
      final dir = await getTemporaryDirectory();
      filePath =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder!.start(const RecordConfig(), path: filePath!);
      isRecording.value = true;
      timer.value = 0;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => timer.value++);
    }
  }

  Future<String?> stopRecording() async {
    _timer?.cancel();
    isRecording.value = false;
    final path = await _recorder!.stop();
    return path;
  }

  void cancelRecording() async {
    _timer?.cancel();
    isRecording.value = false;
    _recorder?.cancel();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _recorder?.dispose();
    super.onClose();
  }
}

String _formatDuration(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
