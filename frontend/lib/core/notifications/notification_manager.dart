import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../notifications/device_token_service.dart';
import '../notifications/firebase_messaging_service.dart';

final notificationManagerProvider = Provider<NotificationManager>((ref) {
  return NotificationManager(ref);
});

class NotificationManager {
  NotificationManager(this._ref);

  final Ref _ref;

  /// Initialize notifications on app startup
  Future<void> initializeNotifications() async {
    if (kDebugMode) {
      debugPrint('🔔 [NOTIFICATION_MANAGER] Initializing notifications');
    }

    // Initialize Firebase Messaging
    await _ref.read(firebaseMessagingServiceProvider).initialize();

    // Set up token refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        debugPrint(
          '🔔 [NOTIFICATION_MANAGER] Firebase token refreshed, re-registering with backend',
        );
      }
      _handleTokenRefresh(newToken);
    });

    if (kDebugMode) {
      debugPrint('✅ [NOTIFICATION_MANAGER] Notifications initialized');
    }
  }

  /// Register device token after successful login
  Future<bool> registerDeviceTokenAfterLogin() async {
    try {
      if (kDebugMode) {
        debugPrint('🔔 [NOTIFICATION_MANAGER] Registering device token after login');
      }

      final fcmService = _ref.read(firebaseMessagingServiceProvider);
      final deviceTokenService = _ref.read(deviceTokenServiceProvider);

      // Get FCM token from Firebase
      final fcmToken = await fcmService.getToken();
      if (fcmToken == null) {
        if (kDebugMode) {
          debugPrint('⚠️ [NOTIFICATION_MANAGER] Failed to get FCM token');
        }
        return false;
      }

      // Register token with backend
      final success = await deviceTokenService.registerToken(fcmToken);
      if (success) {
        // Save token locally for future reference
        await deviceTokenService.saveLastToken(fcmToken);
        if (kDebugMode) {
          debugPrint('✅ [NOTIFICATION_MANAGER] Device token registered');
        }
        return true;
      }

      if (kDebugMode) {
        debugPrint('❌ [NOTIFICATION_MANAGER] Failed to register device token');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [NOTIFICATION_MANAGER] Error registering device token: $e');
      }
      return false;
    }
  }

  /// Deregister device token on logout
  Future<bool> deregisterDeviceTokenOnLogout() async {
    try {
      if (kDebugMode) {
        debugPrint('🔔 [NOTIFICATION_MANAGER] Deregistering device token on logout');
      }

      final deviceTokenService = _ref.read(deviceTokenServiceProvider);

      // Get the last saved token
      final lastToken = await deviceTokenService.getLastToken();
      if (lastToken == null) {
        if (kDebugMode) {
          debugPrint('⚠️ [NOTIFICATION_MANAGER] No saved token to deregister');
        }
        return true; // Not an error, just nothing to do
      }

      // Deregister token from backend
      final success = await deviceTokenService.deregisterToken(lastToken);
      if (success) {
        // Clear token from local storage
        await deviceTokenService.clearLastToken();
        if (kDebugMode) {
          debugPrint('✅ [NOTIFICATION_MANAGER] Device token deregistered');
        }
        return true;
      }

      if (kDebugMode) {
        debugPrint('❌ [NOTIFICATION_MANAGER] Failed to deregister device token');
      }
      // Continue with logout even if deregistration fails
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [NOTIFICATION_MANAGER] Error deregistering device token: $e');
      }
      // Continue with logout even if there's an error
      return true;
    }
  }

  /// Handle token refresh from Firebase
  Future<void> _handleTokenRefresh(String newToken) async {
    try {
      // Check if user is authenticated
      final authState = _ref.read(authControllerProvider);
      if (!authState.isAuthenticated) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [NOTIFICATION_MANAGER] User not authenticated, skipping token registration',
          );
        }
        return;
      }

      // Register new token with backend
      final deviceTokenService = _ref.read(deviceTokenServiceProvider);
      final success = await deviceTokenService.registerToken(newToken);

      if (success) {
        // Save new token locally
        await deviceTokenService.saveLastToken(newToken);
        if (kDebugMode) {
          debugPrint('✅ [NOTIFICATION_MANAGER] New token registered on refresh');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [NOTIFICATION_MANAGER] Error handling token refresh: $e');
      }
    }
  }
}
