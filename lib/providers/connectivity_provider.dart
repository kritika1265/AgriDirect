import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Provider for managing network connectivity state throughout the app
/// Tracks both connectivity status and actual internet access
class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker = InternetConnectionChecker.instance;
  
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late StreamSubscription<InternetConnectionStatus> _internetSubscription;
  
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  bool _hasInternetAccess = false;
  bool _isInitialized = false;

  /// Current connectivity result (wifi, mobile, none, etc.)
  List<ConnectivityResult> get connectionStatus => _connectionStatus;
  
  /// Primary connection type for backwards compatibility
  ConnectivityResult get primaryConnectionType => 
      _connectionStatus.isNotEmpty ? _connectionStatus.first : ConnectivityResult.none;
  
  /// Whether the device has actual internet access
  bool get hasInternetAccess => _hasInternetAccess;
  
  /// Whether the device is connected to any network
  bool get isConnected => !_connectionStatus.contains(ConnectivityResult.none) || 
                          _connectionStatus.any((result) => result != ConnectivityResult.none);
  
  /// Whether the provider has been initialized
  bool get isInitialized => _isInitialized;
  
  /// Human-readable connection status
  String get connectionStatusText {
    if (_connectionStatus.isEmpty || _connectionStatus.first == ConnectivityResult.none) {
      return 'No connection';
    }
    
    final primaryConnection = _connectionStatus.first;
    switch (primaryConnection) {
      case ConnectivityResult.wifi:
        return _hasInternetAccess ? 'Connected via WiFi' : 'WiFi connected, no internet';
      case ConnectivityResult.mobile:
        return _hasInternetAccess ? 'Connected via Mobile Data' : 'Mobile connected, no internet';
      case ConnectivityResult.ethernet:
        return _hasInternetAccess ? 'Connected via Ethernet' : 'Ethernet connected, no internet';
      case ConnectivityResult.vpn:
        return _hasInternetAccess ? 'Connected via VPN' : 'VPN connected, no internet';
      case ConnectivityResult.bluetooth:
        return _hasInternetAccess ? 'Connected via Bluetooth' : 'Bluetooth connected, no internet';
      case ConnectivityResult.other:
        return _hasInternetAccess ? 'Connected via Other' : 'Other connection, no internet';
      case ConnectivityResult.none:
        return 'No connection';
    }
  }
  
  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    
    try {
      // Get initial connectivity status
      _connectionStatus = await _connectivity.checkConnectivity();
      _hasInternetAccess = await _internetChecker.hasConnection;
      
      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: _onConnectivityError,
      );
      
      // Listen to internet access changes
      _internetSubscription = _internetChecker.onStatusChange.listen(
        _onInternetStatusChanged,
        onError: _onInternetError,
      );
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing connectivity provider: $e');
    }
  }
  
  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _connectionStatus = results;
    notifyListeners();
    
    // Check internet access when connectivity changes
    _checkInternetAccess();
  }
  
  /// Handle internet status changes
  void _onInternetStatusChanged(InternetConnectionStatus status) {
    _hasInternetAccess = status == InternetConnectionStatus.connected;
    notifyListeners();
  }
  
  /// Handle connectivity errors
  void _onConnectivityError(dynamic error) {
    debugPrint('Connectivity error: $error');
    _connectionStatus = [ConnectivityResult.none];
    _hasInternetAccess = false;
    notifyListeners();
  }
  
  /// Handle internet checker errors
  void _onInternetError(dynamic error) {
    debugPrint('Internet checker error: $error');
    _hasInternetAccess = false;
    notifyListeners();
  }
  
  /// Manually check internet access
  Future<void> _checkInternetAccess() async {
    try {
      final hasConnection = await _internetChecker.hasConnection;
      if (_hasInternetAccess != hasConnection) {
        _hasInternetAccess = hasConnection;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error checking internet access: $e');
      _hasInternetAccess = false;
      notifyListeners();
    }
  }
  
  /// Force refresh connectivity status
  Future<void> refreshConnectivity() async {
    try {
      _connectionStatus = await _connectivity.checkConnectivity();
      _hasInternetAccess = await _internetChecker.hasConnection;
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing connectivity: $e');
    }
  }
  
  /// Check if specific network operations should be allowed
  bool canPerformNetworkOperation() => isConnected && hasInternetAccess;
  
  /// Get network quality indicator (rough estimate)
  NetworkQuality getNetworkQuality() {
    if (!hasInternetAccess) {
      return NetworkQuality.none;
    }
    
    final primaryConnection = primaryConnectionType;
    switch (primaryConnection) {
      case ConnectivityResult.wifi:
        return NetworkQuality.good;
      case ConnectivityResult.mobile:
        return NetworkQuality.moderate;
      case ConnectivityResult.ethernet:
        return NetworkQuality.excellent;
      default:
        return NetworkQuality.poor;
    }
  }
  
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _internetSubscription.cancel();
    super.dispose();
  }
}

/// Enum for network quality indication
enum NetworkQuality {
  /// No network connection available
  none,
  /// Poor network quality
  poor,
  /// Moderate network quality
  moderate,
  /// Good network quality
  good,
  /// Excellent network quality
  excellent,
}

/// Extension for NetworkQuality enum
extension NetworkQualityExtension on NetworkQuality {
  /// Human-readable display name for network quality
  String get displayName {
    switch (this) {
      case NetworkQuality.none:
        return 'No Connection';
      case NetworkQuality.poor:
        return 'Poor';
      case NetworkQuality.moderate:
        return 'Moderate';
      case NetworkQuality.good:
        return 'Good';
      case NetworkQuality.excellent:
        return 'Excellent';
    }
  }
  
  /// Color representation for network quality
  Color get color {
    switch (this) {
      case NetworkQuality.none:
        return Colors.grey;
      case NetworkQuality.poor:
        return Colors.red;
      case NetworkQuality.moderate:
        return Colors.orange;
      case NetworkQuality.good:
        return Colors.lightGreen;
      case NetworkQuality.excellent:
        return Colors.green;
    }
  }
  
  /// Icon representation for network quality
  IconData get icon {
    switch (this) {
      case NetworkQuality.none:
        return Icons.signal_wifi_off;
      case NetworkQuality.poor:
        return Icons.network_wifi_1_bar;
      case NetworkQuality.moderate:
        return Icons.network_wifi_2_bar;
      case NetworkQuality.good:
        return Icons.network_wifi_3_bar;
      case NetworkQuality.excellent:
        return Icons.signal_wifi_4_bar;
    }
  }
}