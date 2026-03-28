import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  OnDeviceTranslator? _translator;

  static final Map<String, TranslateLanguage> _languages = {
    'en': TranslateLanguage.english,
    'es': TranslateLanguage.spanish,
    'fr': TranslateLanguage.french,
    'de': TranslateLanguage.german,
    'it': TranslateLanguage.italian,
    'pt': TranslateLanguage.portuguese,
    'ru': TranslateLanguage.russian,
    'zh': TranslateLanguage.chinese,
    'ja': TranslateLanguage.japanese,
    'ko': TranslateLanguage.korean,
    'ar': TranslateLanguage.arabic,
    'hi': TranslateLanguage.hindi,
    'bn': TranslateLanguage.bengali,
  };

  // ✅ Added missing initialize() method
  Future<void> initialize() async {
    // No-op for ML Kit — models are downloaded on demand.
    // Add any one-time setup here if needed in the future.
  }

  Future<String> translate(
      String text,
      String sourceLang,
      String targetLang,
      Function(double) onProgress,
      ) async {
    try {
      final source = _languages[sourceLang];
      final target = _languages[targetLang];

      if (source == null || target == null) {
        throw Exception('Unsupported language pair: $sourceLang → $targetLang');
      }

      _translator = OnDeviceTranslator(
        sourceLanguage: source,
        targetLanguage: target,
      );

      onProgress(0.3);
      await Future.delayed(const Duration(milliseconds: 100));

      final result = await _translator!.translateText(text);
      onProgress(0.8);
      await Future.delayed(const Duration(milliseconds: 50));

      onProgress(1.0);
      return result;
    } catch (e) {
      print('Translation error: $e');
      rethrow;
    } finally {
      _translator?.close();
      _translator = null;
    }
  }

  // ✅ Fixed: added onProgress callback to match controller call
  Future<void> downloadModel(
      String languageCode,
      Function(double) onProgress,
      ) async {
    final language = _languages[languageCode];
    if (language == null) return;

    final modelManager = OnDeviceTranslatorModelManager();
    // ✅ Use .bcpCode (String) instead of the enum directly
    final alreadyDownloaded = await modelManager.isModelDownloaded(language.bcpCode);

    if (!alreadyDownloaded) {
      onProgress(0.0);
      await modelManager.downloadModel(language.bcpCode);
      onProgress(1.0);
    }
  }

  Future<bool> isModelDownloaded(String languageCode) async {
    final language = _languages[languageCode];
    if (language == null) return false;

    final modelManager = OnDeviceTranslatorModelManager();
    // ✅ Same fix here
    return await modelManager.isModelDownloaded(language.bcpCode);
  }

  void dispose() {
    _translator?.close();
  }
}