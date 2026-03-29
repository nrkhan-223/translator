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
        child: Container(
          height: Get.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.purple.shade50],
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
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
                    ? TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: controller.translationProgress.value),
                  duration: const Duration(milliseconds: 300),
                  builder: (_, value, __) => Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.grey[200],
                          color: Colors.green.shade400,
                          minHeight: 6.h,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '${(value * 100).toInt()}%',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
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
                    OutlinedButton.icon(
                      onPressed: controller.clearText,
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('Clear'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => controller.copyToClipboard(
                        controller.translatedTextController.text,
                      ),
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}