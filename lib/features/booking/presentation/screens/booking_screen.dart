import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:pcm_mobile/features/booking/presentation/providers/booking_provider.dart';
import 'package:pcm_mobile/features/courts/presentation/providers/courts_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int? _selectedCourtId;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedStartTime;
  String? _selectedEndTime;

  // Danh sách giờ (30 phút/lượt)
  final List<String> _timeSlots = List.generate(48, (index) {
    final hour = (index ~/ 2).toString().padLeft(2, '0');
    final minute = (index % 2 == 0) ? '00' : '30';
    return '$hour:$minute';
  });

  @override
  Widget build(BuildContext context) {
    final courtsAsync = ref.watch(courtsProvider);
    final createBooking = ref.watch(createBookingProvider);

    final canConfirm = _selectedCourtId != null &&
        _selectedDay != null &&
        _selectedStartTime != null &&
        _selectedEndTime != null &&
        !createBooking.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt sân'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chọn sân
              const Text('Chọn sân',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              courtsAsync.when(
                data: (courts) {
                  if (courts.isEmpty) return const Text('Chưa có sân nào');
                  return DropdownButtonFormField<int>(
                    value: _selectedCourtId,
                    hint: const Text('Chọn sân'),
                    isExpanded: true,
                    items: courts.map((court) {
                      return DropdownMenuItem<int>(
                        value: court.id,
                        child: Text(
                            '${court.name} - ${court.pricePerHour.toStringAsFixed(0)}₫/giờ'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() {
                      _selectedCourtId = value;
                      _selectedStartTime = null;
                      _selectedEndTime = null;
                    }),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Lỗi tải danh sách sân: $err'),
              ),

              const SizedBox(height: 24),

              // Chọn ngày
              const Text('Chọn ngày',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 30)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                        color: Colors.green[100], shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(
                        color: Colors.green[700], shape: BoxShape.circle),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Chọn giờ bắt đầu & kết thúc
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Giờ bắt đầu',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedStartTime,
                          hint: const Text('Chọn giờ'),
                          isExpanded: true,
                          items: _timeSlots
                              .map((slot) => DropdownMenuItem(
                                  value: slot, child: Text(slot)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedStartTime = value),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Giờ kết thúc',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedEndTime,
                          hint: const Text('Chọn giờ'),
                          isExpanded: true,
                          items: _timeSlots
                              .map((slot) => DropdownMenuItem(
                                  value: slot, child: Text(slot)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedEndTime = value),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Debug trạng thái chọn (giúp bạn kiểm tra)
              Text(
                'Debug: Sân: $_selectedCourtId | Ngày: $_selectedDay | Bắt đầu: $_selectedStartTime | Kết thúc: $_selectedEndTime',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 16),

              // Nút xác nhận
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: canConfirm
                      ? () {
                          final startParts = _selectedStartTime!.split(':');
                          final endParts = _selectedEndTime!.split(':');

                          final start = DateTime(
                            _selectedDay!.year,
                            _selectedDay!.month,
                            _selectedDay!.day,
                            int.parse(startParts[0]),
                            int.parse(startParts[1]),
                          );
                          final end = DateTime(
                            _selectedDay!.year,
                            _selectedDay!.month,
                            _selectedDay!.day,
                            int.parse(endParts[0]),
                            int.parse(endParts[1]),
                          );

                          ref
                              .read(createBookingProvider.notifier)
                              .createBooking(
                                courtId: _selectedCourtId!,
                                startTime: start,
                                endTime: end,
                              );
                        }
                      : null,
                  icon: const Icon(Icons.check_circle),
                  label: createBooking.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 3))
                      : const Text('Xác nhận đặt sân'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Kết quả đặt sân
              // Kết quả đặt sân
              if (createBooking.hasValue && createBooking.value != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Card(
                    color: Colors.green[50],
                    child: ListTile(
                      leading: const Icon(Icons.check_circle,
                          color: Colors.green, size: 36),
                      title: const Text('Đặt sân thành công!',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Sân ${createBooking.value!.courtName}\n'
                        '${DateFormat('dd/MM/yyyy HH:mm').format(createBooking.value!.startTime)} - '
                        '${DateFormat('HH:mm').format(createBooking.value!.endTime)}',
                      ),
                    ),
                  ),
                ),

              if (createBooking.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Card(
                    color: Colors.red[50],
                    child: ListTile(
                      leading:
                          const Icon(Icons.error, color: Colors.red, size: 36),
                      title: const Text('Đặt sân thất bại',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(createBooking.error.toString()),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
