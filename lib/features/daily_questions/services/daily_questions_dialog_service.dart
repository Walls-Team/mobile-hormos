import 'package:flutter/material.dart';
import 'package:genius_hormo/features/daily_questions/pages/daily_questions_screen.dart';
import 'package:genius_hormo/features/daily_questions/services/daily_questions_service.dart';

class DailyQuestionsDialogService {
  final DailyQuestionsService _questionsService = DailyQuestionsService();
  
  // Método para verificar y mostrar el cuestionario si es necesario
  Future<void> checkAndShowDailyQuestions(BuildContext context) async {
    debugPrint('🔍 Verificando si ya se respondió el cuestionario hoy...');
    final hasAnswered = await _questionsService.hasAnsweredToday();
    debugPrint('📊 ¿Ya respondido hoy?: $hasAnswered');
    
    if (!hasAnswered && context.mounted) {
      debugPrint('📝 Mostrando cuestionario diario...');
      // Esperar un poco para que la app termine de cargar
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false, // No permitir cerrar tocando fuera
          builder: (context) => const DailyQuestionsScreen(),
        );
      }
    }
  }
}
