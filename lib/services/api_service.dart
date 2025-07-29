import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/network_utils.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const int _timeoutDuration = 30;
  late final http.Client _client;

  void initialize() {
    _client = http.Client();
  }

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    try {
      // Check network connectivity
      if (!await NetworkUtils.isConnected()) {
        throw ApiException('No internet connection', 0);
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
          .replace(queryParameters: queryParams);

      final defaultHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (ApiConfig.apiKey.isNotEmpty) 'X-API-Key': ApiConfig.apiKey,
        ...?headers,
      };

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client
              .get(uri, headers: defaultHeaders)
              .timeout(const Duration(seconds: _timeoutDuration));
          break;
        case 'POST':
          response = await _client
              .post(
                uri,
                headers: defaultHeaders,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(const Duration(seconds: _timeoutDuration));
          break;
        case 'PUT':
          response = await _client
              .put(
                uri,
                headers: defaultHeaders,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(const Duration(seconds: _timeoutDuration));
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: defaultHeaders)
              .timeout(const Duration(seconds: _timeoutDuration));
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method', 0);
      }

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Network error. Please check your connection.', 0);
    } on HttpException {
      throw ApiException('HTTP error occurred.', 0);
    } on FormatException {
      throw ApiException('Invalid response format.', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: ${e.toString()}', 0);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data;
    
    try {
      data = json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('Invalid JSON response', response.statusCode);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final message = data['message'] ?? 
                     data['error'] ?? 
                     'Request failed with status ${response.statusCode}';
      throw ApiException(message, response.statusCode);
    }
  }

  // Weather API methods
  Future<Map<String, dynamic>> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    return await _makeRequest(
      'GET',
      '/weather/current',
      queryParams: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'units': 'metric',
      },
    );
  }

  Future<Map<String, dynamic>> getWeatherForecast({
    required double latitude,
    required double longitude,
    int days = 7,
  }) async {
    return await _makeRequest(
      'GET',
      '/weather/forecast',
      queryParams: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'days': days.toString(),
        'units': 'metric',
      },
    );
  }

  // Crop prediction API methods
  Future<Map<String, dynamic>> predictCrop({
    required Map<String, dynamic> soilData,
    required Map<String, dynamic> weatherData,
    required String location,
  }) async {
    return await _makeRequest(
      'POST',
      '/ml/crop-prediction',
      body: {
        'soil_data': soilData,
        'weather_data': weatherData,
        'location': location,
      },
    );
  }

  // Disease detection API methods
  Future<Map<String, dynamic>> detectPlantDisease({
    required String imageBase64,
    required String cropType,
  }) async {
    return await _makeRequest(
      'POST',
      '/ml/disease-detection',
      body: {
        'image': imageBase64,
        'crop_type': cropType,
      },
    );
  }

  // News and feed API methods
  Future<Map<String, dynamic>> getAgricultureNews({
    int page = 1,
    int limit = 20,
    String? category,
    String? language = 'en',
  }) async {
    return await _makeRequest(
      'GET',
      '/news',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (category != null) 'category': category,
        'language': language!,
      },
    );
  }

  // Market prices API methods
  Future<Map<String, dynamic>> getMarketPrices({
    String? cropType,
    String? market,
    String? state,
  }) async {
    return await _makeRequest(
      'GET',
      '/market/prices',
      queryParams: {
        if (cropType != null) 'crop': cropType,
        if (market != null) 'market': market,
        if (state != null) 'state': state,
      },
    );
  }

  // Tool rental API methods
  Future<Map<String, dynamic>> getAvailableTools({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
    String? toolType,
  }) async {
    return await _makeRequest(
      'GET',
      '/tools/available',
      queryParams: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'radius': radiusKm.toString(),
        if (toolType != null) 'type': toolType,
      },
    );
  }

  Future<Map<String, dynamic>> bookTool({
    required String toolId,
    required String startDate,
    required String endDate,
    required String userId,
  }) async {
    return await _makeRequest(
      'POST',
      '/tools/book',
      body: {
        'tool_id': toolId,
        'start_date': startDate,
        'end_date': endDate,
        'user_id': userId,
      },
    );
  }

  // Expert consultation API methods
  Future<Map<String, dynamic>> getAvailableExperts({
    String? specialization,
    String? language,
  }) async {
    return await _makeRequest(
      'GET',
      '/experts',
      queryParams: {
        if (specialization != null) 'specialization': specialization,
        if (language != null) 'language': language,
      },
    );
  }

  Future<Map<String, dynamic>> bookConsultation({
    required String expertId,
    required String userId,
    required String preferredTime,
    required String query,
  }) async {
    return await _makeRequest(
      'POST',
      '/experts/book',
      body: {
        'expert_id': expertId,
        'user_id': userId,
        'preferred_time': preferredTime,
        'query': query,
      },
    );
  }

  // Soil analysis API methods
  Future<Map<String, dynamic>> analyzeSoil({
    required String imageBase64,
    required double latitude,
    required double longitude,
  }) async {
    return await _makeRequest(
      'POST',
      '/soil/analyze',
      body: {
        'image': imageBase64,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  // Government schemes API methods
  Future<Map<String, dynamic>> getGovernmentSchemes({
    String? state,
    String? category,
  }) async {
    return await _makeRequest(
      'GET',
      '/schemes',
      queryParams: {
        if (state != null) 'state': state,
        if (category != null) 'category': category,
      },
    );
  }

  // Upload file method for images
  Future<Map<String, dynamic>> uploadFile({
    required String filePath,
    required String endpoint,
    String fieldName = 'file',
    Map<String, String>? additionalFields,
  }) async {
    try {
      if (!await NetworkUtils.isConnected()) {
        throw ApiException('No internet connection', 0);
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        if (ApiConfig.apiKey.isNotEmpty) 'X-API-Key': ApiConfig.apiKey,
      });

      // Add file
      final file = await http.MultipartFile.fromPath(fieldName, filePath);
      request.files.add(file);

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send()
          .timeout(const Duration(seconds: _timeoutDuration * 2));
      
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('File upload failed: ${e.toString()}', 0);
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}