import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

import 'app/data/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => AuthService().init());
  
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AuthService.to.isLoggedIn ? Routes.HOME : Routes.LOGIN,
      getPages: AppPages.routes,
    ),
  );
}



