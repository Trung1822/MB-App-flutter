import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pcm_mobile/core/services/dio_client.dart';
import 'package:pcm_mobile/features/auth/presentation/providers/user_provider.dart';
import 'package:pcm_mobile/features/wallet/domain/models/transaction_model.dart';

// Lấy số dư ví + tier (từ /api/Auth/me)
final walletBalanceProvider = Provider<double?>((ref) {
  final user = ref.watch(userProvider).value;
  return user?.walletBalance;
});

final tierProvider = Provider<String?>((ref) {
  final user = ref.watch(userProvider).value;
  return user?.tier;
});

// Lấy danh sách giao dịch
final transactionsProvider =
    FutureProvider<List<TransactionModel>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('Wallet/transactions');
    final List<dynamic> data = response.data;
    return data.map((json) => TransactionModel.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Không tải được lịch sử giao dịch: $e');
  }
});

// Provider tạo yêu cầu nạp tiền
final depositRequestProvider =
    StateNotifierProvider<DepositRequestNotifier, AsyncValue<String?>>((ref) {
  return DepositRequestNotifier(ref);
});

class DepositRequestNotifier extends StateNotifier<AsyncValue<String?>> {
  final Ref ref;
  DepositRequestNotifier(this.ref) : super(const AsyncData(null));

  Future<void> createDepositRequest(double amount, String? note) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('Wallet/deposit-request', data: {
        'amount': amount,
        'note': note ?? '',
      });

      state =
          AsyncData(response.data['message'] ?? 'Yêu cầu nạp tiền đã được gửi');
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }
}
