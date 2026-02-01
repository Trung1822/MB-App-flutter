import 'package:flutter/material.dart';
import 'package:pcm_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:pcm_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:pcm_mobile/features/booking/presentation/screens/booking_screen.dart';

class PCMApp extends StatelessWidget {
  const PCMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PCM - Vợt Thủ Phố Núi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/booking': (context) => const BookingScreen(),
        // Thêm route khác khi có màn mới
      },
    );
  }
}
