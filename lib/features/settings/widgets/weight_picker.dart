import 'package:flutter/material.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:numberpicker/numberpicker.dart';

class WeightPicker extends StatefulWidget {
  final double? initialValue;
  final Function(double) onChanged;
  final bool isMetric;

  const WeightPicker({
    super.key,
    this.initialValue,
    required this.onChanged,
    required this.isMetric,
  });

  @override
  State<WeightPicker> createState() => _WeightPickerState();
}

class _WeightPickerState extends State<WeightPicker> {
  // For metric (kilograms) - valor predeterminado seguro
  int _selectedKg = 70;
  
  // For imperial (pounds) - valor predeterminado seguro
  int _selectedLbs = 150;
  
  // Rangos permitidos
  final int minKg = 35;
  final int maxKg = 150;
  final int minLbs = 77;
  final int maxLbs = 330;
  
  // Track current measurement system
  bool _isMetric = true;
  
  // Flag para evitar que didUpdateWidget sobreescriba valores durante cambios internos
  bool _isInternalChange = false;

  @override
  void initState() {
    super.initState();
    
    _isMetric = widget.isMetric;
    
    // Initialize with the value if provided
    if (widget.initialValue != null) {
      // El valor viene en libras desde el backend
      final weightInLbs = widget.initialValue!;
      
      // Establecer valores tanto para métrico como imperial y asegurar rangos válidos
      // Usar valores seguros que estén dentro del rango permitido
      if (weightInLbs < 77) {
        _selectedLbs = 77;
      } else if (weightInLbs > 330) {
        _selectedLbs = 330;
      } else {
        _selectedLbs = weightInLbs.round();
      }
      
      // Convertir a kg y asegurar rango
      double kgValue = _lbsToKg(_selectedLbs.toDouble());
      if (kgValue < 35) {
        _selectedKg = 35;
      } else if (kgValue > 150) {
        _selectedKg = 150;
      } else {
        _selectedKg = kgValue.round();
      }
      
      debugPrint('🏅️ Weight initialized: $_selectedLbs lbs ($_selectedKg kg)');
    } else {
      // Valores por defecto seguros
      _selectedLbs = 154; // ~70kg
      _selectedKg = 70;
    }
    
    // Verificación final para asegurar valores válidos
    _selectedKg = _selectedKg.clamp(35, 150);
    _selectedLbs = _selectedLbs.clamp(77, 330);
  }
  
  @override
  void didUpdateWidget(WeightPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update if measurement system changed
    if (oldWidget.isMetric != widget.isMetric) {
      setState(() {
        _isMetric = widget.isMetric;
      });
    }
    
    // Actualizar si el valor inicial cambia (ignorar cambios internos del picker)
    if (oldWidget.initialValue != widget.initialValue && widget.initialValue != null && !_isInternalChange) {
      final weightInLbs = widget.initialValue!;
      
      setState(() {
        // Asegurar que los valores estén en rangos válidos
        _selectedLbs = weightInLbs.round().clamp(77, 330);
        _selectedKg = _lbsToKg(weightInLbs.toDouble()).round().clamp(35, 150);
        debugPrint('🏅️ Weight updated: ${weightInLbs} lbs (${_selectedKg} kg)');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force update based on current prop value
    _isMetric = widget.isMetric;
    
    // Asegurar que los valores estén siempre en el rango correcto
    _selectedKg = _selectedKg.clamp(minKg, maxKg);
    _selectedLbs = _selectedLbs.clamp(minLbs, maxLbs);
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2C3B),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppLocalizations.of(context)!['settings']['weight'],
              style: const TextStyle(fontSize: 14, color: Colors.white60),
            ),
          ),
          const SizedBox(height: 8),
          _isMetric ? _buildMetricPicker() : _buildImperialPicker(),
        ],
      ),
    );
  }

  Widget _buildMetricPicker() {
    // Validación simplificada - usar valor seguro
    final int safeKgValue = _selectedKg.clamp(minKg, maxKg);
    
    return Column(
      children: [
        // Etiqueta de unidad de peso (KG)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            _getUnitLabel(true),
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Container(
          height: 60, // Altura del contenedor para el picker
          width: double.infinity, // Ocupar todo el ancho disponible
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Marco decorativo para el valor seleccionado
              Container(
                width: 60,
                height: 38,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEDE954), width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent, // Fondo transparente para que se vea el número
                ),
              ),
              
              // Número picker horizontal
              NumberPicker(
                value: safeKgValue,
                minValue: minKg, // Mínimo 35kg
                maxValue: maxKg, // Máximo 150kg
                step: 1,
                axis: Axis.horizontal,
                itemWidth: 60, // Ancho de cada item
                haptics: true,
                textStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                selectedTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                onChanged: (value) {
                  _isInternalChange = true;
                  
                  setState(() {
                    _selectedKg = value;
                    _selectedLbs = _kgToLbs(value.toDouble()).round();
                  });
                  
                  final weightInLbs = _kgToLbs(value.toDouble());
                  debugPrint('⚖️ Vista métrica: $_selectedKg kg = ${weightInLbs.toStringAsFixed(1)} lbs');
                  widget.onChanged(weightInLbs);
                  
                  Future.microtask(() => _isInternalChange = false);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImperialPicker() {
    // Validación simplificada - usar valor seguro
    final int safeLbsValue = _selectedLbs.clamp(minLbs, maxLbs);
    
    return Column(
      children: [
        // Etiqueta de unidad de peso (LBS)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            _getUnitLabel(false),
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Container(
          height: 60, // Altura del contenedor para el picker
          width: double.infinity, // Ocupar todo el ancho disponible
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Marco decorativo para el valor seleccionado
              Container(
                width: 60,
                height: 38,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEDE954), width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent, // Fondo transparente para que se vea el número
                ),
              ),
              
              // Número picker horizontal
              NumberPicker(
                value: safeLbsValue,
                minValue: minLbs, // Mínimo 77lbs
                maxValue: maxLbs, // Máximo 330lbs
                step: 1,
                axis: Axis.horizontal,
                itemWidth: 60, // Ancho de cada item
                haptics: true,
                textStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                selectedTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                onChanged: (value) {
                  _isInternalChange = true;
                  
                  setState(() {
                    _selectedLbs = value;
                    _selectedKg = _lbsToKg(value.toDouble()).round();
                  });
                  
                  debugPrint('⚖️ Vista imperial: $_selectedLbs lbs = $_selectedKg kg');
                  widget.onChanged(value.toDouble());
                  
                  Future.microtask(() => _isInternalChange = false);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Obtener la etiqueta de unidad localizada
  String _getUnitLabel(bool isMetric) {
    final appLocalization = AppLocalizations.of(context);
    
    if (isMetric) {
      return appLocalization?['settings']?['weightUnit']?['metric'] ?? 'KG';
    } else {
      return appLocalization?['settings']?['weightUnit']?['imperial'] ?? 'LBS';
    }
  }

  // Funciones de conversión entre kg y lbs
  double _lbsToKg(double lbs) {
    return lbs * 0.45359237;
  }

  double _kgToLbs(double kg) {
    return kg / 0.45359237;
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}
