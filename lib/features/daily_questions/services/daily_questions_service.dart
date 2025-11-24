import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:genius_hormo/features/daily_questions/models/daily_question.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

class DailyQuestionsService {
  static const String _lastAnsweredKey = 'last_answered_date';
  
  // Lista de preguntas del cuestionario
  List<DailyQuestion> getQuestions(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final questions = localizations['dailyQuestions']['questions'];
    
    return [
      DailyQuestion(
        id: 'alcohol_consumption',
        title: questions['alcoholConsumption']['title'],
        subtitle: questions['alcoholConsumption']['subtitle'],
      ),
      DailyQuestion(
        id: 'drug_use',
        title: questions['drugUse']['title'],
        subtitle: questions['drugUse']['subtitle'],
      ),
      DailyQuestion(
        id: 'poor_diet',
        title: questions['poorDiet']['title'],
        subtitle: questions['poorDiet']['subtitle'],
      ),
      DailyQuestion(
        id: 'testosterone_therapy',
        title: questions['testosteroneTherapy']['title'],
        subtitle: questions['testosteroneTherapy']['subtitle'],
      ),
      DailyQuestion(
        id: 'health_conditions',
        title: questions['healthConditions']['title'],
        subtitle: questions['healthConditions']['subtitle'],
      ),
    ];
  }
  
  // Verificar si ya se respondió hoy
  Future<bool> hasAnsweredToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAnswered = prefs.getString(_lastAnsweredKey);
    
    if (lastAnswered == null) {
      print('📅 No hay registro previo de respuesta');
      return false;
    }
    
    final lastDate = DateTime.parse(lastAnswered);
    final today = DateTime.now();
    
    // Comparar solo la fecha (año, mes, día)
    final answered = lastDate.year == today.year &&
           lastDate.month == today.month &&
           lastDate.day == today.day;
    
    print('📅 Última respuesta: $lastAnswered');
    print('📅 ¿Ya respondido hoy?: $answered');
    
    return answered;
  }
  
  // Marcar como respondido hoy
  Future<void> markAsAnsweredToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastAnsweredKey, DateTime.now().toIso8601String());
  }
  
  // MÉTODO DE DEBUG: Resetear para que vuelva a aparecer
  Future<void> resetDailyQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastAnsweredKey);
    print('🔄 Cuestionario reseteado - volverá a aparecer');
  }
  
  // Función lista para enviar las respuestas al API
  // TODO: Implementar llamada al API cuando esté disponible
  Future<bool> submitAnswers({
    required String token,
    required List<DailyQuestion> questions,
  }) async {
    try {
      // Preparar datos para enviar
      final answers = questions.map((q) => q.toJson()).toList();
      
      // TODO: Hacer el llamado HTTP al endpoint
      // final response = await http.post(
      //   Uri.parse('YOUR_API_ENDPOINT/daily-questions'),
      //   headers: {
      //     'Authorization': 'Bearer $token',
      //     'Content-Type': 'application/json',
      //   },
      //   body: jsonEncode({
      //     'date': DateTime.now().toIso8601String(),
      //     'answers': answers,
      //   }),
      // );
      
      // if (response.statusCode == 200) {
      //   await markAsAnsweredToday();
      //   return true;
      // }
      
      // Por ahora, simular éxito y marcar como respondido
      await markAsAnsweredToday();
      return true;
      
    } catch (e) {
      print('Error submitting daily questions: $e');
      return false;
    }
  }
}
