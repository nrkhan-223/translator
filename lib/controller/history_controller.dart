import 'package:get/get.dart';
import 'package:translator/controller/translator_controller.dart';
import 'package:translator/models/translation_history.dart';
import 'package:translator/services/database_service.dart';

class HistoryController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();

  var historyItems = <TranslationHistory>[].obs;
  var isLoading = false.obs;
  var filterStarredOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      final items = await _databaseService.getAllTranslations();
      historyItems.assignAll(items);
    } finally {
      isLoading.value = false;
    }
  }

  List<TranslationHistory> get filteredHistory {
    if (filterStarredOnly.value) {
      return historyItems.where((item) => item.isStarred).toList();
    }
    return historyItems;
  }

  Future<void> toggleStarred(TranslationHistory item) async {
    final updatedItem = TranslationHistory(
      id: item.id,
      sourceText: item.sourceText,
      translatedText: item.translatedText,
      sourceLanguage: item.sourceLanguage,
      targetLanguage: item.targetLanguage,
      timestamp: item.timestamp,
      isStarred: !item.isStarred,
    );
    await _databaseService.updateTranslation(updatedItem);
    await loadHistory();
  }

  Future<void> deleteTranslation(String id) async {
    await _databaseService.deleteTranslation(id);
    await loadHistory();
    Get.snackbar('Deleted', 'Translation removed from history');
  }

  Future<void> clearAllHistory() async {
    await _databaseService.clearAllHistory();
    await loadHistory();
    Get.snackbar('Cleared', 'All history cleared');
  }

  void useTranslation(TranslationHistory item) {
    Get.back();
    final translatorController = Get.find<TranslatorController>();
    translatorController.sourceTextController.text = item.sourceText;
    translatorController.translatedTextController.text = item.translatedText;
    translatorController.sourceLanguage.value = item.sourceLanguage;
    translatorController.targetLanguage.value = item.targetLanguage;
  }
}