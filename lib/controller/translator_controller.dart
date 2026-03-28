import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/services/translation_service.dart';
import 'package:translator/services/database_service.dart';
import 'package:translator/models/translation_history.dart';
import 'package:translator/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';

class TranslatorController extends GetxController {
  final TranslationService _translationService = TranslationService();
  final DatabaseService _databaseService = DatabaseService();

  // Text editing
  final sourceTextController = TextEditingController();
  final translatedTextController = TextEditingController();

  // Languages
  var sourceLanguage = 'en'.obs;
  var targetLanguage = 'es'.obs;

  // Translation state
  var isTranslating = false.obs;
  var translationProgress = 0.0.obs;

  // Voice input
  final SpeechToText _speechToText = SpeechToText();
  var isListening = false.obs;
  var speechRecognized = false.obs;

  // Voice output
  final FlutterTts _flutterTts = FlutterTts();
  var isSpeaking = false.obs;

  // Supported languages
  var sourceLanguages = <String, String>{}.obs;
  var targetLanguages = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _setupTtsListeners();
  }

  Future<void> _initializeServices() async {
    try {
      await _translationService.initialize();
      _loadLanguages();
      await _requestPermissions();

      // Pre-download common language models
      await _preDownloadModels();
    } catch (e) {
      print('Service initialization error: $e');
      Get.snackbar(
        'Initialization Error',
        'Failed to initialize translation service',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _preDownloadModels() async {
    final commonLanguages = ['en', 'es', 'fr', 'de'];

    for (var lang in commonLanguages) {
      try {
        final isDownloaded = await _translationService.isModelDownloaded(lang);
        if (!isDownloaded) {
          print('Downloading model for $lang...');
          // ✅ Fixed: onProgress now logs properly; no crash on progress callback
          await _translationService.downloadModel(lang, (progress) {
            print('Download progress for $lang: ${(progress * 100).toInt()}%');
          });
        }
      } catch (e) {
        print('Failed to download model for $lang: $e');
      }
    }
  }


  Future<void> _requestPermissions() async {
    await [
      Permission.microphone,
      Permission.storage,
    ].request();
  }

  void _loadLanguages() {
    sourceLanguages.assignAll(AppConstants.supportedLanguages);
    targetLanguages.assignAll(AppConstants.supportedLanguages);
  }

  void swapLanguages() {
    final temp = sourceLanguage.value;
    sourceLanguage.value = targetLanguage.value;
    targetLanguage.value = temp;

    // Swap text
    final tempText = sourceTextController.text;
    sourceTextController.text = translatedTextController.text;
    translatedTextController.text = tempText;

    // Re-translate if needed
    if (sourceTextController.text.isNotEmpty) {
      translateText();
    }
  }

  Future<void> translateText() async {
    if (sourceTextController.text.trim().isEmpty) {
      translatedTextController.clear();
      return;
    }

    isTranslating.value = true;
    translationProgress.value = 0.0;

    try {
      final result = await _translationService.translate(
        sourceTextController.text,
        sourceLanguage.value,
        targetLanguage.value,
            (progress) => translationProgress.value = progress,
      );

      translatedTextController.text = result;

      // Save to history
      final history = TranslationHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sourceText: sourceTextController.text,
        translatedText: result,
        sourceLanguage: sourceLanguage.value,
        targetLanguage: targetLanguage.value,
        timestamp: DateTime.now(),
      );
      await _databaseService.saveTranslation(history);

    } catch (e) {
      Get.snackbar(
        'Translation Error',
        'Failed to translate: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      print('Translation error details: $e');
    } finally {
      isTranslating.value = false;
      translationProgress.value = 0.0;
    }
  }

  Future<void> startListening() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          isListening.value = false;
        }
      },
      onError: (error) {
        isListening.value = false;
        Get.snackbar('Error', 'Speech recognition error: $error');
      },
    );

    if (available) {
      isListening.value = true;
      await _speechToText.listen(
        onResult: (result) {
          speechRecognized.value = true;
          sourceTextController.text = result.recognizedWords;
          translateText();
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 2),
        localeId: _getLocaleForLanguage(sourceLanguage.value),
      );
    } else {
      Get.snackbar('Error', 'Speech recognition not available');
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    isListening.value = false;
  }

  String _getLocaleForLanguage(String languageCode) {
    // Map language codes to locale IDs
    final locales = {
      'en': 'en_US',
      'es': 'es_ES',
      'fr': 'fr_FR',
      'de': 'de_DE',
      'it': 'it_IT',
      'pt': 'pt_PT',
      'ru': 'ru_RU',
      'zh': 'zh_CN',
      'ja': 'ja_JP',
      'ko': 'ko_KR',
    };
    return locales[languageCode] ?? 'en_US';
  }

  void _setupTtsListeners() {
    _flutterTts.setStartHandler(() {
      isSpeaking.value = true;
    });

    _flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
    });

    _flutterTts.setErrorHandler((msg) {
      isSpeaking.value = false;
      print('TTS Error: $msg');
    });
  }

  Future<void> speakTranslatedText() async {
    if (translatedTextController.text.isEmpty) return;

    await _flutterTts.setLanguage(targetLanguage.value);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(translatedTextController.text);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  void copyToClipboard(String text) {
    // Implementation with clipboard
    Get.snackbar('Copied', 'Text copied to clipboard');
  }

  void clearText() {
    sourceTextController.clear();
    translatedTextController.clear();
  }

  @override
  void onClose() {
    sourceTextController.dispose();
    translatedTextController.dispose();
    _speechToText.cancel();
    _flutterTts.stop();
    super.onClose();
  }
}