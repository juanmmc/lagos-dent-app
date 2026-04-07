import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../storage/session_storage.dart';

final deviceTokenServiceProvider = Provider<DeviceTokenService>((ref) {
  final dio = ref.watch(dioProvider);
  final sessionStorage = ref.watch(sessionStorageProvider);
  return DeviceTokenService(dio, sessionStorage);
});

class DeviceTokenService {
  DeviceTokenService(this._dio, this._sessionStorage);

  final Dio _dio;
  final SessionStorage _sessionStorage;

  static const _deviceTokenEndpoint = '/api/device-tokens';
  static const _platformAndroid = 'android';

  /// Register the FCM token with the backend
  /// Called after successful login
  Future<bool> registerToken(String token) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📱 [DEVICE_TOKEN] Registering token: ${token.substring(0, 20)}...',
        );
      }

      final response = await _dio.post(
        _deviceTokenEndpoint,
        data: {
          'token': token,
          'platform': _platformAndroid,
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('✅ [DEVICE_TOKEN] Token registered successfully');
        }
        return true;
      }

      if (kDebugMode) {
        debugPrint(
          '❌ [DEVICE_TOKEN] Failed to register token: ${response.statusCode}',
        );
      }
      return false;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('❌ [DEVICE_TOKEN] Error registering token: $error');
      }
      return false;
    }
  }

  /// Deregister the FCM token from the backend
  /// Called on logout
  Future<bool> deregisterToken(String token) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📱 [DEVICE_TOKEN] Deregistering token: ${token.substring(0, 20)}...',
        );
      }

      final response = await _dio.delete(
        _deviceTokenEndpoint,
        data: {
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('✅ [DEVICE_TOKEN] Token deregistered successfully');
        }
        return true;
      }

      if (kDebugMode) {
        debugPrint(
          '❌ [DEVICE_TOKEN] Failed to deregister token: ${response.statusCode}',
        );
      }
      return false;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('❌ [DEVICE_TOKEN] Error deregistering token: $error');
      }
      return false;
    }
  }

  /// Store the last registered token locally
  Future<void> saveLastToken(String token) async {
    await _sessionStorage.saveDeviceToken(token);
  }

  /// Get the last registered token
  Future<String?> getLastToken() async {
    return _sessionStorage.getDeviceToken();
  }

  /// Clear the last registered token
  Future<void> clearLastToken() async {
    await _sessionStorage.clearDeviceToken();
  }
}
