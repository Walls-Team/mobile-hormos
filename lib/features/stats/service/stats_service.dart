import 'dart:convert';
import 'package:genius_hormo/features/stats/dto/dtos.dart';
import 'package:http/http.dart' as http;



class StatsService {
  static const String _baseUrl = 'https://main.geniushpro.com/v1/api/stats';
  final http.Client client;

  StatsService({http.Client? client}) : client = client ?? http.Client();

  // Método genérico para hacer requests y parsear a tipo específico
  Future<T> _getRequest<T>({
    required String endpoint,
    required T Function(dynamic) fromJson,
    required String token,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');

      print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📡 STATS API REQUEST: $endpoint');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔗 URL: $uri');
      print('🔐 Token: ${token.substring(0, 20)}...');

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body:');
      print(response.body);
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (response.statusCode == 200) {
        final Map<String, dynamic> fullResponse = json.decode(response.body);
        
        print('✅ Parsing response for: $endpoint');
        print('📋 Full Response Keys: ${fullResponse.keys.toList()}');
        
        // Extraer el campo 'data' del response
        final responseData = fullResponse['data'];
        print('📦 Data Type: ${responseData.runtimeType}');
        print('📦 Data Content: $responseData');
        
        final result = fromJson(responseData);
        print('✅ Successfully parsed $endpoint\n');
        
        return result;
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}\n');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 ERROR in $endpoint');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ Error: $e');
      print('📍 StackTrace: $stackTrace');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      throw Exception('Error en la solicitud a $endpoint: $e');
    }
  }

  // GET /v1/api/stats/sleep-efficiency
  Future<SleepEfficiencyData> getSleepEfficiency({
    required String token,
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    return await _getRequest<SleepEfficiencyData>(
      endpoint: 'sleep-efficiency',
      token: token,
      queryParams: params,
      fromJson: (data) => SleepEfficiencyData.fromJson(data),
    );
  }

  // GET /v1/api/stats/sleep-duration
  Future<SleepDurationData> getSleepDuration({
    required String token,
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    return await _getRequest<SleepDurationData>(
      endpoint: 'sleep-duration',
      token: token,
      queryParams: params,
      fromJson: (data) => SleepDurationData.fromJson(data),
    );
  }

  // GET /v1/api/stats/heartrate
  Future<HeartRateData> getHeartRate({
    required String token,
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    return await _getRequest<HeartRateData>(
      endpoint: 'heartrate',
      token: token,
      queryParams: params,
      fromJson: (data) => HeartRateData.fromJson(data),
    );
  }

  // GET /v1/api/stats/spo2
  Future<Spo2Data> getSpo2({
    required String token,
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    return await _getRequest<Spo2Data>(
      endpoint: 'spo2',
      token: token,
      queryParams: params,
      fromJson: (data) => Spo2Data.fromJson(data),
    );
  }

  // GET /v1/api/stats/calories
  Future<CaloriesData> getCalories({
    required String token,
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    return await _getRequest<CaloriesData>(
      endpoint: 'calories',
      token: token,
      queryParams: params,
      fromJson: (data) => CaloriesData.fromJson(data),
    );
  }

  // GET /v1/api/stats/sleep-interruptions
  Future<SleepInterruptionsData> getSleepInterruptions({
    required String token,
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    return await _getRequest<SleepInterruptionsData>(
      endpoint: 'sleep-interruptions',
      token: token,
      queryParams: params,
      fromJson: (data) => SleepInterruptionsData.fromJson(data),
    );
  }

  // Método para obtener todos los datos en paralelo
  Future<AllStats> getAllStatsParallel({
    required String token,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final results = await Future.wait([
        getSleepEfficiency(token: token, startDate: startDate, endDate: endDate),
        getSleepDuration(token: token, startDate: startDate, endDate: endDate),
        getHeartRate(token: token, startDate: startDate, endDate: endDate),
        getSpo2(token: token, startDate: startDate, endDate: endDate),
        getCalories(token: token, startDate: startDate, endDate: endDate),
        getSleepInterruptions(token: token, startDate: startDate, endDate: endDate),
      ]);

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
    required String token,
    String? startDate,
    String? endDate,
  }) async {
    final data = await getSleepEfficiency(token: token, startDate: startDate, endDate: endDate);
    return data.records;
  }

  Future<List<SleepDurationRecord>> getSleepDurationRecords({
    required String token,
    String? startDate,
    String? endDate,
  }) async {
    final data = await getSleepDuration(token: token, startDate: startDate, endDate: endDate);
    return data.records;
  }

  Future<List<HeartRateRecord>> getHeartRateRecords({
    required String token,
    String? startDate,
    String? endDate,
  }) async {
    final data = await getHeartRate(token: token, startDate: startDate, endDate: endDate);
    return data.records;
  }

  Future<List<Spo2Record>> getSpo2Records({
    required String token,
    String? startDate,
    String? endDate,
  }) async {
    final data = await getSpo2(token: token, startDate: startDate, endDate: endDate);
    return data.records;
  }

  Future<List<CalorieRecord>> getCaloriesRecords({
    required String token,
    String? startDate,
    String? endDate,
  }) async {
    final data = await getCalories(token: token, startDate: startDate, endDate: endDate);
    return data.records;
  }

  Future<List<SleepInterruptionRecord>> getSleepInterruptionRecords({
    required String token,
    String? startDate,
    String? endDate,
  }) async {
    final data = await getSleepInterruptions(token: token, startDate: startDate, endDate: endDate);
    return data.records;
  }

  // Verificar conexión
  Future<bool> checkConnection() async {
    try {
      final response = await client.get(
        Uri.parse('https://main.geniushpro.com/health'),
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