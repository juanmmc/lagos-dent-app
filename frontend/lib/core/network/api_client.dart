import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/session_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final sessionStorage = ref.watch(sessionStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (kDebugMode) {
          debugPrint('➡️ [API] preparing ${options.method} ${options.uri}');
        }

        try {
          final session = await sessionStorage
              .read()
              .timeout(const Duration(seconds: 2));
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.token}';
          }
        } catch (error) {
          if (kDebugMode) {
            debugPrint('⚠️ [API] token read failed: $error');
          }
          // Continue without blocking request dispatch.
        }

        if (kDebugMode) {
          debugPrint('➡️ [API] ${options.method} ${options.uri}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint(
            '✅ [API] ${response.statusCode} ${response.requestOptions.uri}',
          );
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          debugPrint(
            '❌ [API] ${error.response?.statusCode ?? '-'} ${error.requestOptions.uri} ${error.message}',
          );
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});
