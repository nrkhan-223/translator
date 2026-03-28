import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
//
// part 'translation_history.g.dart';

@HiveType(typeId: 0)
class TranslationHistory {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sourceText;

  @HiveField(2)
  final String translatedText;

  @HiveField(3)
  final String sourceLanguage;

  @HiveField(4)
  final String targetLanguage;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final bool isStarred;

  TranslationHistory({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    this.isStarred = false,
  });

  String get formattedDate => DateFormat('MMM dd, yyyy - HH:mm').format(timestamp);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'timestamp': timestamp.toIso8601String(),
      'isStarred': isStarred,
    };
  }

  factory TranslationHistory.fromJson(Map<String, dynamic> json) {
    return TranslationHistory(
      id: json['id'],
      sourceText: json['sourceText'],
      translatedText: json['translatedText'],
      sourceLanguage: json['sourceLanguage'],
      targetLanguage: json['targetLanguage'],
      timestamp: DateTime.parse(json['timestamp']),
      isStarred: json['isStarred'] ?? false,
    );
  }

  TranslationHistory copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? timestamp,
    bool? isStarred,
  }) {
    return TranslationHistory(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      timestamp: timestamp ?? this.timestamp,
      isStarred: isStarred ?? this.isStarred,
    );
  }
}