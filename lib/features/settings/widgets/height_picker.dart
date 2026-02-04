import 'package:flutter/material.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:numberpicker/numberpicker.dart';

class HeightPicker extends StatefulWidget {
  final double? initialValue;
  final Function(double) onChanged;
  final bool isMetric;

  const HeightPicker({
    super.key,
    this.initialValue,
    required this.onChanged,
    required this.isMetric,
  });

  @override
  State<HeightPicker> createState() => _HeightPickerState();
}

class _HeightPickerState extends State<HeightPicker> {
  // For metric (meters)
  double _selectedMeters = 1.7; // Default to 1.7m
  
  // For imperial (feet and inches)
  int _selectedFeet = 5; // Default to 5 feet
  int _selectedInches = 7; // Default to 7 inches
  
  // Track current measurement system
  bool _isMetric = true;
  
  // Rangos permitidos
  final int minMetersIndex = 100; // 1.00m
  final int maxMetersIndex = 250; // 2.50m - Ampliado para usuarios de habla hispana
  final int minFeet = 3;
  final int maxFeet = 10; // Actualizado para ser compatible con la altura máxima de 2.50m (8 pies 2 pulgadas)
  final int minInches = 0;
  final int maxInches = 11;
  
  // No necesitamos ScrollControllers ya que NumberPicker maneja el scroll internamente

  @override
  void initState() {
    super.initState();
    
    _isMetric = widget.isMetric;
    
    // Initialize with the value if provided
    if (widget.initialValue != null) {
      // IMPORTANTE: El valor ahora viene como formato decimal de pies (ej: 6.1 para 6 pies 1 pulgada)
      final heightInDecimalFeet = widget.initialValue!;
      debugPrint('📍 INICIALIZANDO HeightPicker con: $heightInDecimalFeet pies en formato decimal');
      
      // Extraer los pies (parte entera) y pulgadas (parte decimal * 10)
      // Y asegurar que estén dentro de los rangos permitidos
      _selectedFeet = heightInDecimalFeet.floor().clamp(3, 9);
      _selectedInches = ((heightInDecimalFeet - _selectedFeet) * 10).round().clamp(0, 9);
      
      // Calcular pulgadas totales para conversiones internas
      final totalInches = (_selectedFeet * 12) + _selectedInches;
      
      // Convertir a metros para la vista métrica y asegurar rango válido
      double metersValue = totalInches * 0.0254;
      _selectedMeters = metersValue.clamp(1.0, 2.0);
      
      debugPrint('📍 Extracción: $heightInDecimalFeet = $_selectedFeet pies $_selectedInches pulgadas');
      debugPrint('📍 Pulgadas totales equivalentes: $totalInches pulgadas');
      debugPrint('📍 Metros equivalentes: $_selectedMeters metros');
    }
    // Siempre validar valores por defecto
    else {
      _selectedMeters = 1.7; // Valor por defecto validado (entre 1.0 y 2.0)
      _selectedFeet = 5;     // Valor por defecto validado (entre 3 y 9) 
      _selectedInches = 7;   // Valor por defecto validado (entre 0 y 9)
    }
  }
  
  @override
  void didUpdateWidget(HeightPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update if measurement system changed
    if (oldWidget.isMetric != widget.isMetric) {
      setState(() {
        _isMetric = widget.isMetric;
      });
      
      // Necesitamos hacer un scroll al valor seleccionado después de cambiar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedValue();
      });
    }
    
    // Actualizar si el valor inicial cambia
    if (oldWidget.initialValue != widget.initialValue && widget.initialValue != null) {
      // El valor ahora viene como formato decimal de pies
      final heightInDecimalFeet = widget.initialValue!;
      debugPrint('📍 Actualizando HeightPicker con altura: $heightInDecimalFeet pies en formato decimal');
      
      setState(() {
        // Extraer los pies (parte entera) y pulgadas (parte decimal * 10)
        _selectedFeet = heightInDecimalFeet.floor();
        _selectedInches = ((heightInDecimalFeet - _selectedFeet) * 10).round();
        
        // Calcular pulgadas totales para conversiones internas
        final totalInches = (_selectedFeet * 12) + _selectedInches;
        
        // Convertir a metros para la vista métrica
        _selectedMeters = totalInches * 0.0254;
        
        debugPrint('📍 Extracción actualizada: $heightInDecimalFeet = $_selectedFeet pies $_selectedInches pulgadas');
        
        // Ajustar valores si están fuera de rango
        if (_selectedFeet < 3) _selectedFeet = 3;
        if (_selectedFeet > 9) _selectedFeet = 9;
        if (_selectedInches < 0) _selectedInches = 0;
        if (_selectedInches > 9) _selectedInches = 9; // Máximo 9 para el formato decimal
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force update based on current prop value
    _isMetric = widget.isMetric;
    
    // Validar valores para evitar errores
    _selectedMeters = _selectedMeters.clamp(1.00, 2.00);
    _selectedFeet = _selectedFeet.clamp(minFeet, maxFeet);
    _selectedInches = _selectedInches.clamp(minInches, maxInches);
    
    // Calcular ancho de pantalla para centrar el picker
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2C3B),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: _isMetric ? _buildMetricPicker() : _buildImperialPicker(),
    );
  }

  Widget _buildMetricPicker() {
    // Asegurar que el valor esté en el rango permitido antes de crear el NumberPicker
    if (_selectedMeters < 1.00) _selectedMeters = 1.00;
    if (_selectedMeters > 2.50) _selectedMeters = 2.50;
    
    // Convertir a un valor entero entre 100 y 250
    int selectedMetersIndex = (_selectedMeters * 100).round();
    
    // Validación adicional de seguridad para garantizar que está dentro del rango
    if (selectedMetersIndex < minMetersIndex) selectedMetersIndex = minMetersIndex;
    if (selectedMetersIndex > maxMetersIndex) selectedMetersIndex = maxMetersIndex;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de altura
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context)!['settings']['height'],
            style: const TextStyle(fontSize: 14, color: Colors.white60),
          ),
        ),
        const SizedBox(height: 8),
        // Etiqueta de unidad (M)
        Center(
          child: Text(
            'Mts',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Container(
          height: 60,
          width: double.infinity, // Ocupar todo el ancho disponible
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Marco decorativo para el valor seleccionado
              Container(
                width: 70,
                height: 38,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEDE954), width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent, // Fondo transparente para que se vea el número
                ),
              ),
              
              // Número picker horizontal
              NumberPicker(
                value: selectedMetersIndex,
                minValue: minMetersIndex, // 1.00m
                maxValue: maxMetersIndex, // 2.00m
                step: 1,
                axis: Axis.horizontal,
                itemWidth: 70,
                haptics: true,
                textStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                selectedTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    // Asegurar que el valor esté en el rango válido
                    _selectedMeters = (value / 100.0).clamp(1.00, 2.00);
                    
                    // Actualizar vista imperial
                    final heightInFeet = _selectedMeters / 0.3048;
                    _selectedFeet = heightInFeet.floor().clamp(minFeet, maxFeet);
                    _selectedInches = ((heightInFeet - _selectedFeet) * 12).round().clamp(minInches, maxInches);
                  });
                  
                  // Convertimos metros a pies y pulgadas
                  final heightInFeet = _selectedMeters / 0.3048;
                  final feet = heightInFeet.floor();
                  final inches = ((heightInFeet - feet) * 12).round();
                  
                  // Convertimos a formato decimal de pies
                  final heightInDecimalFeet = feet + (inches / 10.0);
                  
                  debugPrint('📍 VISTA MÉTRICA: Seleccionado $_selectedMeters metros');
                  debugPrint('📍 Convirtiendo: $_selectedMeters metros = $feet pies $inches pulgadas');
                  
                  widget.onChanged(heightInDecimalFeet);
                },
                // Formateador para mostrar metros con 2 decimales (sin unidad)
                textMapper: (valueString) {
                  int value = int.parse(valueString);
                  return '${(value / 100.0).toStringAsFixed(2)}';
                },
              ),
              
            ],
          ),
        ),
      ],
    );
  }
  

  Widget _buildImperialPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de altura
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context)!['settings']['height'],
            style: const TextStyle(fontSize: 14, color: Colors.white60),
          ),
        ),
        const SizedBox(height: 8),
        // Contenedor principal con FT e IN
        Container(
          height: 90,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Feet picker con etiqueta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'FT',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Marco decorativo
                          Container(
                            width: 60,
                            height: 38,
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFEDE954), width: 2),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.transparent, // Fondo transparente
                            ),
                          ),
                          
                          // NumberPicker para pies (horizontal)
                          NumberPicker(
                            value: _selectedFeet.clamp(minFeet, maxFeet),
                            minValue: minFeet, // Min 3 feet
                            maxValue: maxFeet, // Max 9 feet
                            step: 1,
                            axis: Axis.horizontal,
                            itemWidth: 60,
                            haptics: true,
                            textStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                            selectedTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            onChanged: (value) {
                              setState(() {
                                _selectedFeet = value;
                              });
                              _updateImperialHeight();
                            },
                            // Formateador para mostrar pies
                            textMapper: (valueString) => valueString,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Inches picker con etiqueta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'IN',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Marco decorativo
                          Container(
                            width: 60,
                            height: 38,
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFEDE954), width: 2),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.transparent, // Fondo transparente
                            ),
                          ),
                          
                          // NumberPicker para pulgadas (horizontal)
                          NumberPicker(
                            value: _selectedInches.clamp(minInches, maxInches),
                            minValue: minInches, // Min 0 inches
                            maxValue: maxInches, // Max 11 inches
                            step: 1,
                            axis: Axis.horizontal,
                            itemWidth: 60,
                            haptics: true,
                            textStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                            selectedTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            onChanged: (value) {
                              setState(() {
                                _selectedInches = value;
                              });
                              _updateImperialHeight();
                            },
                            // Formateador para mostrar pulgadas
                            textMapper: (valueString) => valueString,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateImperialHeight() {
    // Asegurar que los valores estén en rangos válidos
    _selectedFeet = _selectedFeet.clamp(minFeet, maxFeet);
    _selectedInches = _selectedInches.clamp(minInches, maxInches);
    
    // Convertimos pies y pulgadas a formato decimal de pies
    // Ejemplo: 6 pies 1 pulgada = 6.1 pies (no es el valor matemático exacto, sino una representación)
    final heightInDecimalFeet = _selectedFeet + (_selectedInches / 10.0);
    
    // También calculamos las pulgadas totales para el backend (esto no cambia)
    final totalInches = (_selectedFeet * 12) + _selectedInches;
    
    // Actualizamos el valor en metros para mantener la consistencia (y aseguramos el rango)
    double metersValue = totalInches * 0.0254;
    _selectedMeters = metersValue.clamp(1.00, 2.50);
    
    debugPrint('📍 VISTA IMPERIAL: Seleccionado $_selectedFeet pies $_selectedInches pulgadas');
    debugPrint('📍 Formato decimal de pies: $heightInDecimalFeet');
    debugPrint('📍 Pulgadas totales (para backend): $totalInches');
    debugPrint('📍 También convertido a $_selectedMeters metros para consistencia');
    
    // IMPORTANTE: Ahora enviamos el valor en formato decimal de pies
    // Ejemplo: 6 pies 1 pulgada = 6.1
    widget.onChanged(heightInDecimalFeet);
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  // Método para hacer scroll al valor seleccionado
  void _scrollToSelectedValue() {
    // El NumberPicker maneja automáticamente la posición del elemento seleccionado
    // por lo que no necesitamos un scroll manual
    if (_isMetric) {
      debugPrint('📍 NumberPicker centrado en metros: $_selectedMeters');
    } else {
      debugPrint('📍 NumberPicker centrado en pies: $_selectedFeet y pulgadas: $_selectedInches');
    }
  }
}
