import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pcm_mobile/features/booking/presentation/screens/booking_screen.dart';
import 'package:pcm_mobile/features/wallet/presentation/screens/wallet_screen.dart';

// Giả lập dữ liệu (sau này thay bằng provider gọi API thật)
final mockUser = {
  'fullName': 'Thành Trung',
  'tier': 'Vàng',
  'balance': 3850000.0,
  'upcomingBookings': [
    {'court': 'Sân VIP 1', 'time': '19:00 - 20:00', 'date': '02/02/2026'},
    {'court': 'Sân 2', 'time': '08:00 - 09:00', 'date': '04/02/2026'},
  ],
};

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    _HomeContent(),
    BookingScreen(),
    WalletScreen(),
    Center(child: Text('Thông báo & Tin tức')),
    Center(child: Text('Hồ sơ cá nhân')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('PCM - Vợt Thủ Phố Núi'),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.green[700],
              radius: 18,
              child: Text(
                mockUser['fullName'].toString()[0],
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_tennis), label: 'Sân'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Ví'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Nội dung chính của trang chủ
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Gọi lại API lấy thông tin user, lịch đặt, số dư ví...
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Card Ví điện tử nổi bật
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.green[700]!, Colors.green[500]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ví PCM',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.amber[700],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                mockUser['tier'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currencyFormat.format(mockUser['balance']),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 32,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sẵn sàng đặt sân',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Chuyển sang màn nạp tiền
                                },
                                icon: const Icon(Icons.add_circle_outline,
                                    size: 18),
                                label: const Text('Nạp tiền'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.green[800],
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // TODO: Chuyển sang màn lịch sử giao dịch
                                },
                                icon: const Icon(Icons.history, size: 18),
                                label: const Text('Lịch sử'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white70),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Nút chính – Đặt sân ngay
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Chuyển sang màn đặt sân
                    },
                    icon: const Icon(Icons.sports_tennis, size: 28),
                    label: const Text('Đặt sân ngay',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Lịch sắp tới + mini calendar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Lịch sắp tới',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

              Card(
                margin: const EdgeInsets.all(16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: TableCalendar(
                  firstDay: DateTime.utc(2025, 1, 1),
                  lastDay: DateTime.utc(2027, 12, 31),
                  focusedDay: DateTime.now(),
                  calendarFormat: CalendarFormat.week,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                        color: Colors.green[100], shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(
                        color: Colors.green[700], shape: BoxShape.circle),
                    weekendTextStyle: const TextStyle(color: Colors.red),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),

              // Upcoming bookings (đã fix null safety)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      (mockUser['upcomingBookings'] as List<dynamic>? ?? [])
                          .map<Widget>((booking) {
                    final court =
                        booking['court'] as String? ?? 'Sân không xác định';
                    final date = booking['date'] as String? ?? '';
                    final time = booking['time'] as String? ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.sports_tennis,
                            color: Colors.green, size: 32),
                        title: Text(court,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('$date • $time'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () {
                            // TODO: Hủy đặt sân
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(
                  height: 100), // padding dưới cùng để không bị che bởi FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Chuyển sang màn đặt sân
        },
        label: const Text('Đặt sân'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
    );
  }
}
