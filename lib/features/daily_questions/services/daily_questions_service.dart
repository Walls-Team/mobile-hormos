import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:genius_hormo/features/daily_questions/models/daily_question.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:genius_hormo/core/config/app_config.dart';
import 'package:http/http.dart' as http;

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
  
  // Enviar las respuestas al API de Spike FAQ
  Future<bool> submitAnswers({
    required String token,
    required List<DailyQuestion> questions,
  }) async {
    try {
      // Mapear las preguntas a los campos esperados por el API
      final Map<String, bool> faqData = {
        'alcohol': false,
        'drugs': false,
        'poor_diet': false,
        'attendance': false,
        'others': false,
      };
      
      // Mapear cada pregunta a su campo correspondiente
      for (final question in questions) {
        if (question.answer == null) continue;
        
        switch (question.id) {
          case 'alcohol_consumption':
            faqData['alcohol'] = question.answer!;
            break;
          case 'drug_use':
            faqData['drugs'] = question.answer!;
            break;
          case 'poor_diet':
            faqData['poor_diet'] = question.answer!;
            break;
          case 'testosterone_therapy':
            faqData['attendance'] = question.answer!;
            break;
          case 'health_conditions':
            faqData['others'] = question.answer!;
            break;
        }
      }
      
      print('📤 Enviando FAQ data: $faqData');
      
      // Hacer la llamada PATCH al endpoint
      final url = AppConfig.getApiUrl('spike/faq/');
      print('🌐 URL: $url');
      
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(faqData),
      );
      
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ FAQ actualizado exitosamente');
        await markAsAnsweredToday();
        return true;
      } else {
        print('❌ Error al actualizar FAQ: ${response.statusCode}');
        return false;
      }
      
    } catch (e) {
      print('❌ Error submitting daily questions: $e');
      return false;
    }
  }
}
