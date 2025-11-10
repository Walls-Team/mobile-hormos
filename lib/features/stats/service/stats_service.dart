import 'dart:convert';
import 'package:genius_hormo/features/stats/dto/dtos.dart';
import 'package:http/http.dart' as http;



class StatsService {
  static const String _baseUrl = 'http://localhost:3000/v1/api/stats';
  final http.Client client;

  StatsService({http.Client? client}) : client = client ?? http.Client();

  // Método genérico para hacer requests y parsear a tipo específico
  Future<T> _getRequest<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');

      print(uri);

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print(response.statusCode);
      // print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Extraer el campo 'data' del response y convertirlo al tipo específico
        final responseData = data['data'];

        print(responseData);
        return fromJson(responseData);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en la solicitud a $endpoint: $e');
    }
  }

  // GET /v1/api/stats/sleep-efficiency
  Future<SleepEfficiencyData> getSleepEfficiency({
    String? startDate,
    String? endDate,
  }) async {

    print('hola');
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;


    final result = await _getRequest<SleepEfficiencyData>(
      endpoint: 'sleep-efficiency',
      // queryParams: params,
      fromJson: (data) => SleepEfficiencyData.fromJson(data),
    );

    print(result.records);

    return result;
  }

  // GET /v1/api/stats/sleep-duration
  Future<SleepDurationData> getSleepDuration({
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    return await _getRequest<SleepDurationData>(
      endpoint: 'sleep-duration',
      queryParams: params,
      fromJson: (data) => SleepDurationData.fromJson(data),
    );
  }

  // GET /v1/api/stats/heartrate
  Future<HeartRateData> getHeartRate({
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    return await _getRequest<HeartRateData>(
      endpoint: 'heartrate',
      queryParams: params,
      fromJson: (data) => HeartRateData.fromJson(data),
    );
  }

  // GET /v1/api/stats/spo2
  Future<Spo2Data> getSpo2({
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    return await _getRequest<Spo2Data>(
      endpoint: 'spo2',
      queryParams: params,
      fromJson: (data) => Spo2Data.fromJson(data),
    );
  }

  // GET /v1/api/stats/calories
  Future<CaloriesData> getCalories({
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    return await _getRequest<CaloriesData>(
      endpoint: 'calories',
      queryParams: params,
      fromJson: (data) => CaloriesData.fromJson(data),
    );
  }

  // GET /v1/api/stats/sleep-interruptions
  Future<SleepInterruptionsData> getSleepInterruptions({
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    return await _getRequest<SleepInterruptionsData>(
      endpoint: 'sleep-interruptions',
      queryParams: params,
      fromJson: (data) => SleepInterruptionsData.fromJson(data),
    );
  }

  // Método para obtener todos los datos en paralelo
  Future<AllStats> getAllStatsParallel({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final results = await Future.wait([
        getSleepEfficiency(startDate: startDate, endDate: endDate),
        getSleepDuration(startDate: startDate, endDate: endDate),
        getHeartRate(startDate: startDate, endDate: endDate),
        getSpo2(startDate: startDate, endDate: endDate),
        getCalories(startDate: startDate, endDate: endDate),
        getSleepInterruptions(startDate: startDate, endDate: endDate),
      ]);

      print(results);

      return AllStats(
        sleepEfficiency: results[0] as SleepEfficiencyData,
        sleepDuration: results[1] as SleepDurationData,
        heartRate: results[2] as HeartRateData,
        spo2: results[3] as Spo2Data,
        calories: results[4] as CaloriesData,
        sleepInterruptions: results[5] as SleepInterruptionsData,
      );
    } catch (e) {
      throw Exception('Error al obtener todas las estadísticas: $e');
    }
  }

  // Métodos de conveniencia para obtener listas directas
  Future<List<SleepEfficiencyRecord>> getSleepEfficiencyRecords({
    String? startDate,
    String? endDate,
  }) async {
    final data = await getSleepEfficiency(startDate: startDate, endDate: endDate);
    return data.records;
  }

  Future<List<SleepDurationRecord>> getSleepDurationRecords({
    String? startDate,
    String? endDate,
  }) async {
    final data = await getSleepDuration(startDate: startDate, endDate: endDate);
    return data.records;
  }

  Future<List<HeartRateRecord>> getHeartRateRecords({
    String? startDate,
    String? endDate,
  }) async {
    final data = await getHeartRate(startDate: startDate, endDate: endDate);
    return data.records;
  }

  Future<List<Spo2Record>> getSpo2Records({
    String? startDate,
    String? endDate,
  }) async {
    final data = await getSpo2(startDate: startDate, endDate: endDate);
    return data.records;
  }

  Future<List<CalorieRecord>> getCaloriesRecords({
    String? startDate,
    String? endDate,
  }) async {
    final data = await getCalories(startDate: startDate, endDate: endDate);
    return data.records;
  }

  Future<List<SleepInterruptionRecord>> getSleepInterruptionRecords({
    String? startDate,
    String? endDate,
  }) async {
    final data = await getSleepInterruptions(startDate: startDate, endDate: endDate);
    return data.records;
  }

  // Verificar conexión
  Future<bool> checkConnection() async {
    try {
      final response = await client.get(
        Uri.parse('http://localhost:3000/health'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void close() {
    client.close();
  }
}

// Clase para agrupar todas las estadísticas
class AllStats {
  final SleepEfficiencyData sleepEfficiency;
  final SleepDurationData sleepDuration;
  final HeartRateData heartRate;
  final Spo2Data spo2;
  final CaloriesData calories;
  final SleepInterruptionsData sleepInterruptions;

  AllStats({
    required this.sleepEfficiency,
    required this.sleepDuration,
    required this.heartRate,
    required this.spo2,
    required this.calories,
    required this.sleepInterruptions,
  });
}