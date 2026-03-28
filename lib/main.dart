import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:translator/app/bindings/app_bindings.dart';
import 'package:translator/app/routes/app_pages.dart';
import 'package:translator/models/translation_history.dart';
import 'package:translator/utils/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'models/translation_history_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapter - this will work after running build_runner
  Hive.registerAdapter(TranslationHistoryAdapter());

  // Open box
  await Hive.openBox<TranslationHistory>(AppConstants.historyBox);

  runApp(const VoiceTranslatorApp());
}



class VoiceTranslatorApp extends StatelessWidget {
  const VoiceTranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Voice Translator',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          initialBinding: AppBindings(),
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}