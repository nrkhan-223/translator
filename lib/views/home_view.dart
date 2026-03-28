import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:translator/views/widgets/language_selector.dart';
import 'package:translator/views/widgets/translation_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controller/translator_controller.dart';

class HomeView extends GetView<TranslatorController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Translator'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Get.toNamed('/history'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              LanguageSelector(
                sourceLanguage: controller.sourceLanguage,
                targetLanguage: controller.targetLanguage,
                onSwap: controller.swapLanguages,
              ),
              SizedBox(height: 20.h),
              TranslationCard(
                title: 'Source Text',
                controller: controller.sourceTextController,
                languageCode: controller.sourceLanguage.value,
                showMicButton: true,
                onMicTap: controller.isListening.value
                    ? controller.stopListening
                    : controller.startListening,
                isListening: controller.isListening.value,
                onChanged: (_) => controller.translateText(),
              ),
              SizedBox(height: 16.h),
              Obx(() => controller.isTranslating.value
                  ? Column(
                children: [
                  LinearProgressIndicator(
                    value: controller.translationProgress.value,
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Translating... ${(controller.translationProgress.value * 100).toInt()}%',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ],
              )
                  : const SizedBox()),
              SizedBox(height: 16.h),
              TranslationCard(
                title: 'Translated Text',
                controller: controller.translatedTextController,
                languageCode: controller.targetLanguage.value,
                showSpeakerButton: true,
                onSpeakerTap: controller.isSpeaking.value
                    ? controller.stopSpeaking
                    : controller.speakTranslatedText,
                isSpeaking: controller.isSpeaking.value,
                readOnly: true,
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.clearText,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => controller.copyToClipboard(
                      controller.translatedTextController.text,
                    ),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}