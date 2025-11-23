import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/daily_questions/models/daily_question.dart';
import 'package:genius_hormo/features/daily_questions/services/daily_questions_service.dart';
import 'package:genius_hormo/features/daily_questions/widgets/question_item.dart';
import 'package:get_it/get_it.dart';

class DailyQuestionsScreen extends StatefulWidget {
  const DailyQuestionsScreen({super.key});

  @override
  State<DailyQuestionsScreen> createState() => _DailyQuestionsScreenState();
}

class _DailyQuestionsScreenState extends State<DailyQuestionsScreen> {
  final DailyQuestionsService _questionsService = DailyQuestionsService();
  final UserStorageService _userStorageService = GetIt.instance<UserStorageService>();
  
  List<DailyQuestion> _questions = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _questions = _questionsService.getQuestions();
  }

  void _updateAnswer(int index, bool answer) {
    setState(() {
      _questions[index].answer = answer;
    });
  }

  bool _allQuestionsAnswered() {
    return _questions.every((q) => q.answer != null);
  }

  Future<void> _submitAnswers() async {
    if (!_allQuestionsAnswered()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final token = await _userStorageService.getJWTToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final success = await _questionsService.submitAnswers(
        token: token,
        questions: _questions,
      );

      if (success && mounted) {
        // ✅ Marcar como respondido hoy para que no vuelva a aparecer
        await _questionsService.markAsAnsweredToday();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Answers saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Cerrar el diálogo después de guardar
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        throw Exception('Failed to save answers');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2D3748),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text(
                    'Daily Questions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance para centrar el título
              ],
            ),
            const SizedBox(height: 24),
            
            // Lista de preguntas
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(
                    _questions.length,
                    (index) => QuestionItem(
                      question: _questions[index],
                      onAnswer: (answer) => _updateAnswer(index, answer),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botón Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9AE6B4),
                  foregroundColor: const Color(0xFF22543D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: const Color(0xFF718096),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
