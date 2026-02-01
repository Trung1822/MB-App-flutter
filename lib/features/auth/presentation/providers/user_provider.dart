import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pcm_mobile/core/services/dio_client.dart';
import 'package:pcm_mobile/features/auth/domain/models/user_model.dart'; // tạo model sau

final userProvider = FutureProvider<UserModel?>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('Auth/me');
    return UserModel.fromJson(response.data);
  } catch (e) {
    return null; // hoặc throw tùy logic
  }
});
