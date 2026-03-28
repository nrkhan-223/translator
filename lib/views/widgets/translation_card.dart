import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TranslationCard extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String languageCode;
  final bool showMicButton;
  final VoidCallback? onMicTap;
  final bool isListening;
  final bool showSpeakerButton;
  final VoidCallback? onSpeakerTap;
  final bool isSpeaking;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const TranslationCard({
    super.key,
    required this.title,
    required this.controller,
    required this.languageCode,
    this.showMicButton = false,
    this.onMicTap,
    this.isListening = false,
    this.showSpeakerButton = false,
    this.onSpeakerTap,
    this.isSpeaking = false,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              const Spacer(),
              if (showMicButton)
                _buildIconButton(
                  icon: isListening ? Icons.mic : Icons.mic_none,
                  onTap: onMicTap,
                  color: isListening ? Colors.red : Colors.grey,
                ),
              if (showSpeakerButton)
                _buildIconButton(
                  icon: isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                  onTap: onSpeakerTap,
                  color: isSpeaking ? Colors.blue : Colors.grey,
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 4,
            minLines: 2,
            readOnly: readOnly,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Enter text to translate...',
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          if (languageCode.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Language: ${languageCode.toUpperCase()}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onTap,
      constraints: const BoxConstraints(),
      padding: EdgeInsets.zero,
      iconSize: 24,
    );
  }
}