enum TransactionType {
  depositRequest,
  depositApproved,
  depositRejected,
  bookingPayment,
  refund,
  other
}

class TransactionModel {
  final int id;
  final double amount;
  final TransactionType type;
  final DateTime createdAt;
  final String? description;
  final String? status; // Pending, Approved, Rejected (cho deposit request)

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.createdAt,
    this.description,
    this.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
        orElse: () => TransactionType.other,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      description: json['description'] as String?,
      status: json['status'] as String?,
    );
  }
}
