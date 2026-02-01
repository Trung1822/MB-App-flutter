enum BookingStatus { holding, pendingPayment, confirmed, cancelled, completed }

class BookingModel {
  final int id;
  final int courtId;
  final String courtName; // từ join API
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final BookingStatus status;
  final String? transactionId;

  BookingModel({
    required this.id,
    required this.courtId,
    required this.courtName,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    this.transactionId,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      courtId: json['courtId'],
      courtName: json['courtName'] ?? 'Sân ${json['courtId']}',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${json['status']}',
        orElse: () => BookingStatus.pendingPayment,
      ),
      transactionId: json['transactionId'],
    );
  }
}
