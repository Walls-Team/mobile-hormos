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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallDevice = screenWidth < 400;
    
    return Container(
      margin: EdgeInsets.only(bottom: isSmallDevice ? 12 : 16),
      padding: EdgeInsets.all(isSmallDevice ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texto de la pregunta
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.title,
                style: TextStyle(
                  fontSize: isSmallDevice ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                question.subtitle,
                style: TextStyle(
                  fontSize: isSmallDevice ? 12 : 14,
                  color: const Color(0xFFE2E8F0),
                ),
              ),
            ],
          ),
          
          SizedBox(height: isSmallDevice ? 12 : 16),
          
          // Botones de respuesta
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Botón Check
              GestureDetector(
                onTap: () => onAnswer(true),
                child: Container(
                  width: isSmallDevice ? 48 : 52,
                  height: isSmallDevice ? 48 : 52,
                  decoration: BoxDecoration(
                    color: question.answer == true
                        ? const Color(0xFF9AE6B4)
                        : const Color(0xFF718096),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check,
                    size: isSmallDevice ? 24 : 28,
                    color: question.answer == true
                        ? const Color(0xFF22543D)
                        : Colors.white,
                  ),
                ),
              ),
              SizedBox(width: isSmallDevice ? 12 : 16),
              // Botón X
              GestureDetector(
                onTap: () => onAnswer(false),
                child: Container(
                  width: isSmallDevice ? 48 : 52,
                  height: isSmallDevice ? 48 : 52,
                  decoration: BoxDecoration(
                    color: question.answer == false
                        ? const Color(0xFFFEB2B2)
                        : const Color(0xFF718096),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.close,
                    size: isSmallDevice ? 24 : 28,
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
