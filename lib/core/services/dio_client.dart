import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Provider cho Dio instance (singleton)
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl:
          'http://10.0.2.2:5005/api/', // Android emulator gọi localhost máy tính
      // Nếu test trên thiết bị thật → thay bằng IP máy tính (ví dụ: 'http://192.168.1.100:5005/api/')
      // Nếu test trên web hoặc desktop → dùng 'http://localhost:5005/api/'

      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      validateStatus: (status) =>
          status != null && status < 500, // Không throw cho 400, 401, 404
    ),
  );

  // Interceptor tự động thêm Bearer token từ secure storage
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      // Debug log request (chỉ hiện khi debug)
      if (kDebugMode) {
        debugPrint('→ REQUEST: ${options.method} ${options.uri}');
        debugPrint('Headers: ${options.headers}');
        debugPrint('Data: ${options.data}');
      }

      return handler.next(options);
    },
    onResponse: (response, handler) {
      // Debug log response (chỉ hiện khi debug)
      if (kDebugMode) {
        debugPrint(
            '← RESPONSE [${response.statusCode}]: ${response.requestOptions.uri}');
        debugPrint('Data: ${response.data}');
      }
      return handler.next(response);
    },
    onError: (DioException e, handler) {
      // Xử lý lỗi chung (401 → logout, 404 → thông báo, ...)
      if (e.response?.statusCode == 401) {
        // TODO: Xử lý logout tự động (xóa token, chuyển về màn login)
        debugPrint('Token hết hạn hoặc không hợp lệ → nên logout');
      }

      // Log lỗi chi tiết
      if (kDebugMode) {
        debugPrint('Dio Error: ${e.message}');
        debugPrint('Status: ${e.response?.statusCode}');
        debugPrint('Data: ${e.response?.data}');
      }

      return handler.next(e);
    },
  ));

  return dio;
});

// Provider riêng cho secure storage (dễ dùng lại)
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});
