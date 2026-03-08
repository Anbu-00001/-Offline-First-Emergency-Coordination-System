import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'mdns_discovery.dart';

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  final MDnsDiscovery _mDnsDiscovery = MDnsDiscovery();

  Future<String> resolveBackendBaseUrl() async {
    // 1. Try mDNS discovery first
    debugPrint('Attempting mDNS discovery of backend...');
    final mdnsUrl = await _mDnsDiscovery.discoverBackendUrl();
    if (mdnsUrl != null) {
      debugPrint('mDNS discovery successful: $mdnsUrl');
      return mdnsUrl;
    }

    // 2. Fallback to assets/config.json
    try {
      final configString = await rootBundle.loadString('assets/config.json');
      final Map<String, dynamic> configJson = jsonDecode(configString);
      if (configJson.containsKey('base_url')) {
        final url = configJson['base_url'] as String;
        debugPrint('Loaded backend URL from config.json: $url');
        return url;
      }
    } catch (e) {
      debugPrint('No assets/config.json found or invalid format: $e');
    }

    // 3. Fallback to emulator localhost if running on Android/iOS
    debugPrint('Falling back to default emulator local backend');
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://127.0.0.1:8000'; // iOS simulator or Desktop
    }
  }
}
