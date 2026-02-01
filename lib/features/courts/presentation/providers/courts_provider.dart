import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pcm_mobile/core/services/dio_client.dart';
import 'package:pcm_mobile/features/courts/domain/models/court_model.dart';

final courtsProvider = FutureProvider<List<CourtModel>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('Courts');
    final List<dynamic> data = response.data;
    return data.map((json) => CourtModel.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Không tải được danh sách sân: $e');
  }
});
