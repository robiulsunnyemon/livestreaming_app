import 'package:get/get.dart';

import '../controllers/start_live_controller.dart';

class StartLiveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StartLiveController>(
      () => StartLiveController(),
    );
  }
}
