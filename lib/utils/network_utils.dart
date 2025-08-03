import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Network connectivity and utility functions for AgriDirect app
class NetworkUtils {
  static final Dio _dio = Dio();
  static late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  static final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  /// Initialize network utilities
  static void initialize() {
    _setupDio();
    _startConnectivityMonitoring();
  }

  /// Setup Dio configuration
  static void _setupDio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);

    // Add request interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          print('🚀 REQUEST: ${options.method} ${options.uri}');
          print('📊 Headers: ${options.headers}');
          if (options.data != null) {
            print('📦 Data: ${options.data}');
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
          print('📥 Data: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}');
          print('🚨 Message: ${error.message}');
        }
        handler.next(error);
      },
    ));

    // Add retry interceptor
    // Uncomment the following lines after adding dio_retry to your pubspec.yaml:
    // import 'package:dio_retry/dio_retry.dart';
    // _dio.interceptors.add(RetryInterceptor(
    //   dio: _dio,
    //   retries: 3,
    //   retryDelays: const [
    //     Duration(seconds: 1),
    //     Duration(seconds: 2),
    //     Duration(seconds: 3),
    //   ],
    // ));
  }

  /// Start monitoring connectivity changes
  static void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final isConnected = results.any((result) => result != ConnectivityResult.none);
        _connectionController.add(isConnected);
      },
    );
  }

  /// Get current connectivity status
  static Future<bool> isConnected() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.any((connectivity) => connectivity != ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  /// Check internet connectivity by pinging a reliable server
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Get connectivity stream
  static Stream<bool> get connectivityStream => _connectionController.stream;

  /// Get network connection type
  static Future<String> getConnectionType() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else {
      return 'No Connection';
    }
  }

  /// Check if connection is metered (mobile data)
  static Future<bool> isMeteredConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile);
  }

  /// Make GET request
  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    if (headers != null) {
      _dio.options.headers.addAll(headers);
    }

    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }

  /// Make POST request
  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    if (headers != null) {
      _dio.options.headers.addAll(headers);
    }

    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }

  /// Make PUT request
  static Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    if (headers != null) {
      _dio.options.headers.addAll(headers);
    }

    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }

  /// Make DELETE request
  static Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    if (headers != null) {
      _dio.options.headers.addAll(headers);
    }

    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }

  /// Upload file
  static Future<Response> uploadFile(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData();
    
    // Add file
    formData.files.add(MapEntry(
      fieldName,
      await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
    ));

    // Add additional data
    if (additionalData != null) {
      additionalData.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    return await _dio.post(
      path,
      data: formData,
      onSendProgress: onProgress,
      cancelToken: cancelToken,
    );
  }

  /// Download file
  static Future<Response> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    return await _dio.download(
      url,
      savePath,
      onReceiveProgress: onProgress,
      cancelToken: cancelToken,
    );
  }

    /// Handle network errors
  }