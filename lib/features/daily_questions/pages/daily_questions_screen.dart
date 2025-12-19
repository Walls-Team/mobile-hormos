import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/daily_questions/models/daily_question.dart';
import 'package:genius_hormo/features/daily_questions/services/daily_questions_service.dart';
import 'package:genius_hormo/features/daily_questions/widgets/question_item.dart';
import 'package:get_it/get_it.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

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
    // Note: We'll get questions after the widget builds to access context
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_questions.isEmpty) {
      _questions = _questionsService.getQuestions(context);
    }
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
      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations['dailyQuestions']['answerAll']),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final token = await _userStorageService.getJWTToken();
      
      final localizations = AppLocalizations.of(context)!;
      if (token == null) {
        throw Exception(localizations['dailyQuestions']['noToken']);
      }

      final success = await _questionsService.submitAnswers(
        token: token,
        questions: _questions,
      );

      if (success && mounted) {
        // ✅ Marcar como respondido hoy para que no vuelva a aparecer
        await _questionsService.markAsAnsweredToday();
        
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${localizations['dailyQuestions']['saveSuccess']}'),
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
        final localizations = AppLocalizations.of(context)!;
        throw Exception(localizations['dailyQuestions']['saveFailed']);
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${localizations['dailyQuestions']['error']}: $e'),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallDevice = screenWidth < 400 || screenHeight < 700;
    
    return WillPopScope(
      onWillPop: () async {
        // Prevent closing with back button if not all answered
        if (!_allQuestionsAnswered()) {
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations['dailyQuestions']['answerAll']),
              backgroundColor: Colors.orange,
            ),
          );
          return false;
        }
        return true;
      },
      child: Dialog(
        backgroundColor: const Color(0xFF2D3748),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: isSmallDevice ? 16 : 40,
          vertical: isSmallDevice ? 24 : 40,
        ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: screenHeight * 0.85, // Max 85% del alto de pantalla
        ),
        padding: EdgeInsets.all(isSmallDevice ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: _allQuestionsAnswered() ? Colors.white : Colors.grey,
                    size: isSmallDevice ? 20 : 24,
                  ),
                  onPressed: _allQuestionsAnswered()
                    ? () => Navigator.of(context).pop()
                    : () {
                        final localizations = AppLocalizations.of(context)!;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(localizations['dailyQuestions']['answerAll']),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!['dailyQuestions']['title'],
                    style: TextStyle(
                      fontSize: isSmallDevice ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: isSmallDevice ? 40 : 48), // Balance para centrar el título
              ],
            ),
            SizedBox(height: isSmallDevice ? 16 : 24),
            
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
            
            SizedBox(height: isSmallDevice ? 16 : 24),
            
            // Botón Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9AE6B4),
                  foregroundColor: const Color(0xFF22543D),
                  padding: EdgeInsets.symmetric(vertical: isSmallDevice ? 12 : 16),
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
                    : Text(
                        AppLocalizations.of(context)!['dailyQuestions']['save'],
                        style: TextStyle(
                          fontSize: isSmallDevice ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
