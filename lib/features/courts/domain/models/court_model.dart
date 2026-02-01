class CourtModel {
  final int id;
  final String name;
  final String? description;
  final double pricePerHour;
  final bool isActive;

  CourtModel({
    required this.id,
    required this.name,
    this.description,
    required this.pricePerHour,
    required this.isActive,
  });

  factory CourtModel.fromJson(Map<String, dynamic> json) {
    return CourtModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      isActive:
          json['isActive'] == true, // ← fix: an toàn với null → false nếu null
    );
  }
}
