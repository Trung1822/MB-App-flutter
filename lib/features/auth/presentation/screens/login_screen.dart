import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pcm_mobile/core/services/dio_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

final loginProvider =
    StateNotifierProvider<LoginNotifier, AsyncValue<String?>>((ref) {
  return LoginNotifier(ref);
});

class LoginNotifier extends StateNotifier<AsyncValue<String?>> {
  final Ref ref;
  LoginNotifier(this.ref) : super(const AsyncData(null));

  Future<void> login(
      BuildContext context, String email, String password) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        'Auth/login',
        data: {
          'Email': email,
          'Password': password
        }, // khớp với backend (chữ hoa đầu)
      );

      final token = response.data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Không nhận được token từ server');
      }

      const storage = FlutterSecureStorage();
      await storage.write(key: 'jwt_token', value: token);

      // Debug (chỉ dùng trong dev, sau xóa hoặc thay logger)
      debugPrint('Login thành công - Token: $token');

      state = const AsyncData('Đăng nhập thành công');

      // Chuyển màn Home
      if (context.mounted) {
        // ← fix warning async gap
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data['message'] ??
          'Lỗi server: ${e.response?.statusCode}';
      state = AsyncError(errorMsg, StackTrace.current);
    } catch (e) {
      state = AsyncError('Lỗi không xác định: $e', StackTrace.current);
    }
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    // Hiển thị thông báo khi state thay đổi
    ref.listen<AsyncValue<String?>>(
      loginProvider,
      (previous, next) {
        next.maybeWhen(
          data: (msg) {
            if (msg != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg), backgroundColor: Colors.green),
              );
            }
          },
          error: (err, stack) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(err.toString()),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          },
          orElse: () {},
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập PCM')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loginState.isLoading
                    ? null
                    : () => ref.read(loginProvider.notifier).login(
                          context,
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        ),
                child: loginState.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : const Text('Đăng nhập', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
