import 'package:flutter/material.dart';
import 'package:genius_hormo/features/daily_questions/models/daily_question.dart';

class QuestionItem extends StatelessWidget {
  final DailyQuestion question;
  final Function(bool) onAnswer;

  const QuestionItem({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              // Botón Check
              GestureDetector(
                onTap: () => onAnswer(true),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: question.answer == true
                        ? const Color(0xFF9AE6B4)
                        : const Color(0xFF718096),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.check,
                    color: question.answer == true
                        ? const Color(0xFF22543D)
                        : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Botón X
              GestureDetector(
                onTap: () => onAnswer(false),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: question.answer == false
                        ? const Color(0xFFFEB2B2)
                        : const Color(0xFF718096),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.close,
                    color: question.answer == false
                        ? const Color(0xFF742A2A)
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
