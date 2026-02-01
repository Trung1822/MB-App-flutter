class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final double? walletBalance;
  final String? tier;
  final List<String> roles;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.walletBalance,
    this.tier,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
      walletBalance: (json['walletBalance'] as num?)?.toDouble(),
      tier: json['tier'],
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}
