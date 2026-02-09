import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

class BirthDatePicker extends StatefulWidget {
  final String? initialValue; // formato: 'YYYY-MM-DD'
  final Function(String) onChanged;
  
  const BirthDatePicker({
    Key? key,
    this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<BirthDatePicker> createState() => _BirthDatePickerState();
}

class _BirthDatePickerState extends State<BirthDatePicker> {
  // Valores predeterminados
  int _selectedYear = 1990;
  int _selectedMonth = 1;
  int _selectedDay = 1;
  
  // Rangos y validación
  final int _minYear = 1900;
  int _maxYear = 2008; // 18 años atrás (se calcula en initState)
  
  // Flag para evitar que didUpdateWidget sobreescriba valores durante cambios internos
  bool _isInternalChange = false;
  
  @override
  void initState() {
    super.initState();
    
    // Calcular el año máximo (18 años atrás)
    final currentYear = DateTime.now().year;
    _maxYear = currentYear - 18;
    
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      try {
        // Parsear la fecha inicial (formato: 'YYYY-MM-DD')
        final parts = widget.initialValue!.split('-');
        if (parts.length == 3) {
          _selectedYear = int.parse(parts[0]);
          _selectedMonth = int.parse(parts[1]);
          _selectedDay = int.parse(parts[2]);
          
          // Validar los valores dentro de los rangos permitidos
          _selectedYear = _selectedYear.clamp(_minYear, _maxYear);
          _selectedMonth = _selectedMonth.clamp(1, 12);
          _selectedDay = _selectedDay.clamp(1, _getDaysInMonth(_selectedMonth, _selectedYear));
        }
      } catch (e) {
        debugPrint('Error al parsear la fecha inicial: $e');
      }
    } else {
      // Valores por defecto si no hay fecha inicial
      _selectedYear = _maxYear - 20; // 20 años antes del año máximo permitido
      _selectedMonth = 1;
      _selectedDay = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2C3B),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppLocalizations.of(context)!['settings']['birthDay'] ?? 'Fecha de Nacimiento',
              style: const TextStyle(fontSize: 14, color: Colors.white60),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Año (YEAR)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _getLocalizedText('year', 'Año'),
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    NumberPicker(
                      value: _selectedYear,
                      minValue: _minYear,
                      maxValue: _maxYear,
                      step: 1,
                      axis: Axis.vertical,
                      itemHeight: 36,
                      haptics: true,
                      textStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                      selectedTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(color: const Color(0xFFEDE954), width: 1),
                        ),
                      ),
                      onChanged: (value) {
                        _isInternalChange = true;
                        setState(() {
                          _selectedYear = value;
                          final maxDays = _getDaysInMonth(_selectedMonth, _selectedYear);
                          if (_selectedDay > maxDays) {
                            _selectedDay = maxDays;
                          }
                        });
                        _notifyChange();
                        Future.microtask(() => _isInternalChange = false);
                      },
                    ),
                  ],
                ),
              ),
              
              // Mes (MONTH)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _getLocalizedText('month', 'Mes'),
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    NumberPicker(
                      value: _selectedMonth,
                      minValue: 1,
                      maxValue: 12,
                      step: 1,
                      axis: Axis.vertical,
                      itemHeight: 36,
                      haptics: true,
                      textStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                      selectedTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(color: const Color(0xFFEDE954), width: 1),
                        ),
                      ),
                      onChanged: (value) {
                        _isInternalChange = true;
                        setState(() {
                          _selectedMonth = value;
                          final maxDays = _getDaysInMonth(_selectedMonth, _selectedYear);
                          if (_selectedDay > maxDays) {
                            _selectedDay = maxDays;
                          }
                        });
                        _notifyChange();
                        Future.microtask(() => _isInternalChange = false);
                      },
                      textMapper: (valueString) {
                        // Convertir el string a entero y luego el número del mes a su nombre corto
                        final value = int.parse(valueString);
                        return _getMonthName(value);
                      },
                    ),
                  ],
                ),
              ),
              
              // Día (DAY)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _getLocalizedText('day', 'Día'),
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    NumberPicker(
                      value: _selectedDay,
                      minValue: 1,
                      maxValue: _getDaysInMonth(_selectedMonth, _selectedYear),
                      step: 1,
                      axis: Axis.vertical,
                      itemHeight: 36,
                      haptics: true,
                      textStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                      selectedTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(color: const Color(0xFFEDE954), width: 1),
                        ),
                      ),
                      onChanged: (value) {
                        _isInternalChange = true;
                        setState(() {
                          _selectedDay = value;
                        });
                        _notifyChange();
                        Future.microtask(() => _isInternalChange = false);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Obtener el número de días en un mes específico
  int _getDaysInMonth(int month, int year) {
    if (month == 2) {
      // Febrero: verificar año bisiesto
      if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
        return 29;
      } else {
        return 28;
      }
    } else if ([4, 6, 9, 11].contains(month)) {
      // Abril, Junio, Septiembre, Noviembre
      return 30;
    } else {
      // El resto de los meses tienen 31 días
      return 31;
    }
  }
  
  // Convertir el número de mes a nombre corto
  String _getMonthName(int month) {
    // Intentar obtener nombres de mes internacionalizados o usar valor por defecto
    final context = this.context;
    final monthNames = [
      AppLocalizations.of(context)!['date']?['months']?['jan'] ?? 'Ene', 
      AppLocalizations.of(context)!['date']?['months']?['feb'] ?? 'Feb', 
      AppLocalizations.of(context)!['date']?['months']?['mar'] ?? 'Mar',
      AppLocalizations.of(context)!['date']?['months']?['apr'] ?? 'Abr',
      AppLocalizations.of(context)!['date']?['months']?['may'] ?? 'May',
      AppLocalizations.of(context)!['date']?['months']?['jun'] ?? 'Jun',
      AppLocalizations.of(context)!['date']?['months']?['jul'] ?? 'Jul',
      AppLocalizations.of(context)!['date']?['months']?['aug'] ?? 'Ago',
      AppLocalizations.of(context)!['date']?['months']?['sep'] ?? 'Sep',
      AppLocalizations.of(context)!['date']?['months']?['oct'] ?? 'Oct',
      AppLocalizations.of(context)!['date']?['months']?['nov'] ?? 'Nov',
      AppLocalizations.of(context)!['date']?['months']?['dec'] ?? 'Dic'
    ];
    return monthNames[month - 1];
  }
  
  // Notificar el cambio de fecha al padre
  void _notifyChange() {
    // Formatear la fecha según el formato requerido (YYYY-MM-DD)
    final formattedDate = '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}-${_selectedDay.toString().padLeft(2, '0')}';
    widget.onChanged(formattedDate);
  }
  
  // Método para obtener textos traducidos para las etiquetas del selector
  String _getLocalizedText(String key, String defaultValue) {
    // Acceder al contexto de localización
    final appLocalization = AppLocalizations.of(context);
    
    // Verificar diferentes rutas de traducción basadas en el idioma y la estructura
    if (key == 'year') {
      // Primero intentamos con date.year, luego settings.year, etc.
      return appLocalization?['date']?['year'] ?? 
             appLocalization?['dateFormat']?['year'] ?? 
             appLocalization?['calendar']?['year'] ?? 
             'Año';
    } else if (key == 'month') {
      return appLocalization?['date']?['month'] ?? 
             appLocalization?['dateFormat']?['month'] ?? 
             appLocalization?['calendar']?['month'] ?? 
             'Mes';
    } else if (key == 'day') {
      return appLocalization?['date']?['day'] ?? 
             appLocalization?['dateFormat']?['day'] ?? 
             appLocalization?['calendar']?['day'] ?? 
             'Día';
    }
    
    // Si no hay coincidencias, devolver el valor predeterminado
    return defaultValue;
  }
}
