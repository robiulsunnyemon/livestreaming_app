import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/start_live/bindings/start_live_binding.dart';
import '../modules/start_live/views/start_live_view.dart';
import '../modules/live_streaming/bindings/live_streaming_binding.dart';
import '../modules/live_streaming/views/live_streaming_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.START_LIVE;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.START_LIVE,
      page: () => const StartLiveView(),
      binding: StartLiveBinding(),
    ),
    GetPage(
      name: _Paths.LIVE_STREAMING,
      page: () => const LiveStreamingView(),
      binding: LiveStreamingBinding(),
    ),
  ];
}
