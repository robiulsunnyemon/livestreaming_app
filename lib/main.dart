import 'package:get_storage/get_storage.dart';
import 'app/core/theme/app_colors.dart';
import 'app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/data/services/auth_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  
  // Initialize Stripe
  try {
    Stripe.publishableKey = "pk_test_51SXuRwJO5wX3ItZ58iQpjV8215bfAk9l2lhmeDCDytNyarYkYg4owOKr2fF98I6OregNYYrdmSKWhM2Mwrf7fEOe002aOeXigu";
    await Stripe.instance.applySettings();
  } catch (e) {
    debugPrint("Stripe Initialization Error: $e");
  }

  await Get.putAsync(() => AuthService().init());
  
  runApp(
    GetMaterialApp(
      title: "InstaLive",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
      theme: ThemeData(
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color:  AppColors.secondaryPrimary,
        )
      ),
    ),
  );
}



