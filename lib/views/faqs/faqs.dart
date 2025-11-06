import 'package:flutter/material.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

class FaqsPage extends StatelessWidget {
  const FaqsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.faqsTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 20.0,
          children: [
            Text(
              localizations.faqsDescription,
              style: TextStyle(fontSize: 16),
              textAlign:
                  TextAlign.justify, // Justificado como text-wrap: pretty
              softWrap: true, // Habilitar salto de línea suave
              overflow: TextOverflow.visible, // Evitar el truncamiento
              strutStyle: StrutStyle(
                fontSize: 16,
                height: 1.0,
                leading: 0.5, // Espaciado adicional entre líneas
              ),
            ),
            // Lista de preguntas frecuentes
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 7, // 7 preguntas
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) =>
                  _buildFaqItem(context, index, localizations),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context,
    int index,
    AppLocalizations localizations,
  ) {
    final Map<int, Map<String, String>> faqMap = {
      0: {
        'question': localizations.faqsQuestion1,
        'answer': localizations.faqsAnswer1,
      },
      1: {
        'question': localizations.faqsQuestion2,
        'answer': localizations.faqsAnswer2,
      },
      2: {
        'question': localizations.faqsQuestion3,
        'answer': localizations.faqsAnswer3,
      },
      3: {
        'question': localizations.faqsQuestion4,
        'answer': localizations.faqsAnswer4,
      },
      4: {
        'question': localizations.faqsQuestion5,
        'answer': localizations.faqsAnswer5,
      },
      5: {
        'question': localizations.faqsQuestion6,
        'answer': localizations.faqsAnswer6,
      },
      6: {
        'question': localizations.faqsQuestion7,
        'answer': localizations.faqsAnswer7,
      },
    };

    final faq = faqMap[index]!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // Elimina la línea divisoria
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          childrenPadding: const EdgeInsets.all(0),
          iconColor: Colors.grey[600],
          title: Text(
            faq['question']!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Text(
                faq['answer']!,
                style: TextStyle(fontSize: 14),
                textAlign:
                    TextAlign.justify, // Justificado como text-wrap: pretty
                softWrap: true, // Habilitar salto de línea suave
                overflow: TextOverflow.visible, // Evitar el truncamiento
                strutStyle: StrutStyle(
                  fontSize: 16,
                  height: 0.5,
                  leading: 0.5, // Espaciado adicional entre líneas
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
