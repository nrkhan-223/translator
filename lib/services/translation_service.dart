import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  OnDeviceTranslator? _translator;
  String? _currentSourceLang;
  String? _currentTargetLang;

  static final Map<String, TranslateLanguage> _languages = {
    'bn': TranslateLanguage.bengali,
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
  };

  Future<void> initialize() async {}

  // ✅ Reuse translator if same language pair, create new only if changed
  OnDeviceTranslator _getTranslator(String sourceLang, String targetLang) {
    if (_translator != null &&
        _currentSourceLang == sourceLang &&
        _currentTargetLang == targetLang) {
      return _translator!;
    }

    // Close old one before creating new
    _translator?.close();

    final source = _languages[sourceLang]!;
    final target = _languages[targetLang]!;

    _translator = OnDeviceTranslator(
      sourceLanguage: source,
      targetLanguage: target,
    );
    _currentSourceLang = sourceLang;
    _currentTargetLang = targetLang;

    return _translator!;
  }

  Future<String> translate(
      String text,
      String sourceLang,
      String targetLang,
      Function(double) onProgress,
      ) async {
    final source = _languages[sourceLang];
    final target = _languages[targetLang];

    if (source == null || target == null) {
      throw Exception('Unsupported language pair: $sourceLang → $targetLang');
    }

    onProgress(0.3);

    // ✅ Reuse translator — don't close after each call
    final translator = _getTranslator(sourceLang, targetLang);
    final result = await translator.translateText(text);

    onProgress(1.0);
    return result;
  }

  Future<void> downloadModel(
      String languageCode,
      Function(double) onProgress,
      ) async {
    final language = _languages[languageCode];
    if (language == null) return;

    final modelManager = OnDeviceTranslatorModelManager();
    final alreadyDownloaded =
    await modelManager.isModelDownloaded(language.bcpCode);

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
    return await modelManager.isModelDownloaded(language.bcpCode);
  }

  // ✅ Call this only when truly done (controller onClose)
  void dispose() {
    _translator?.close();
    _translator = null;
  }
}