import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pcm_mobile/core/services/dio_client.dart';
import 'package:pcm_mobile/features/booking/domain/models/booking_model.dart';

final createBookingProvider =
    StateNotifierProvider<CreateBookingNotifier, AsyncValue<BookingModel?>>(
        (ref) {
  return CreateBookingNotifier(ref);
});

class CreateBookingNotifier extends StateNotifier<AsyncValue<BookingModel?>> {
  final Ref ref;
  CreateBookingNotifier(this.ref) : super(const AsyncData(null));

  Future<void> createBooking({
    required int courtId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        'Bookings', // sửa nếu backend dùng tên khác (xem Swagger)
        data: {
          'courtId': courtId,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
        },
      );

      // Xử lý response linh hoạt (có thể là Map hoặc String)
      final data = response.data;

      if (data is Map<String, dynamic>) {
        // Backend trả JSON object → parse thành BookingModel
        final booking = BookingModel.fromJson(data);
        state = AsyncData(booking);
      } else if (data is String) {
        // Backend trả string → tạo object giả để hiển thị message
        state = AsyncData(BookingModel(
          id: 0,
          courtId: courtId,
          courtName: 'Đặt sân thành công',
          startTime: startTime,
          endTime: endTime,
          totalPrice: 0,
          status: BookingStatus.confirmed,
        ));
      } else {
        throw Exception('Response không đúng định dạng');
      }
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }
}
