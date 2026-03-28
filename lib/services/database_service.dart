import 'package:hive/hive.dart';
import 'package:translator/models/translation_history.dart';
import 'package:translator/utils/constants.dart';

class DatabaseService {
  late Box<TranslationHistory> _historyBox;

  DatabaseService() {
    _initBox();
  }

  Future<void> _initBox() async {
    _historyBox = Hive.box<TranslationHistory>(AppConstants.historyBox);
  }

  Future<void> saveTranslation(TranslationHistory translation) async {
    await _historyBox.put(translation.id, translation);
  }

  Future<List<TranslationHistory>> getAllTranslations() async {
    final items = _historyBox.values.toList();
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  Future<void> updateTranslation(TranslationHistory translation) async {
    await _historyBox.put(translation.id, translation);
  }

  Future<void> deleteTranslation(String id) async {
    await _historyBox.delete(id);
  }

  Future<void> clearAllHistory() async {
    await _historyBox.clear();
  }

  Future<List<TranslationHistory>> searchTranslations(String query) async {
    final allTranslations = await getAllTranslations();
    return allTranslations.where((item) {
      return item.sourceText.toLowerCase().contains(query.toLowerCase()) ||
          item.translatedText.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}