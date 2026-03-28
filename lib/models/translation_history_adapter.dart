import 'package:hive/hive.dart';
import 'translation_history.dart';

class TranslationHistoryAdapter extends TypeAdapter<TranslationHistory> {
  @override
  final int typeId = 0;

  @override
  TranslationHistory read(BinaryReader reader) {
    return TranslationHistory(
      id: reader.readString(),
      sourceText: reader.readString(),
      translatedText: reader.readString(),
      sourceLanguage: reader.readString(),
      targetLanguage: reader.readString(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isStarred: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, TranslationHistory obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.sourceText);
    writer.writeString(obj.translatedText);
    writer.writeString(obj.sourceLanguage);
    writer.writeString(obj.targetLanguage);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeBool(obj.isStarred);
  }
}