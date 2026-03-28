import 'package:get/get.dart';
import '../../controller/translator_controller.dart';
import '../../controller/history_controller.dart';


class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(TranslatorController(), permanent: true);
    Get.put(HistoryController(), permanent: true);
  }
}