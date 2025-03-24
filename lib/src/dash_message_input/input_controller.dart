import 'package:get/get.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

class InputController extends GetxController {
  final RxList<String> selectedOptions = <String>[].obs;
  final RxInt scaleValue = 0.obs;
  final RxBool isConfirmed = false.obs;

  void toggleOption(String option) {
    if (selectedOptions.contains(option)) {
      selectedOptions.remove(option);
    } else {
      selectedOptions.add(option);
    }
  }

  void setScaleValue(int value) {
    scaleValue.value = value;
  }

  void confirmInput() {
    print("DONEONEONOEN");
    isConfirmed.value = true;
  }

  void reset() {
    selectedOptions.clear();
    scaleValue.value = 0;
    isConfirmed.value = false;
  }
}
