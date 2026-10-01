import 'package:get/get.dart';

class AppShellController extends GetxController {
  final selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final argument = Get.arguments;
    if (argument is int && argument >= 0 && argument <= 3) {
      selectedIndex.value = argument;
    }
  }

  void selectTab(int index) {
    if (selectedIndex.value == index) {
      return;
    }
    selectedIndex.value = index;
  }
}
