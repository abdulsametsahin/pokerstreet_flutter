class User {
  final int id;
  final String name;
  final String email;
  final String? displayName;
  final String? avatar;
  final DateTime? createdAt;
  final double? totalBalance;
  final double? affiliateBonus;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.displayName,
    this.avatar,
    this.createdAt,
    this.totalBalance,
    this.affiliateBonus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      displayName: json['display_name'],
      avatar: json['avatar'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      totalBalance: json['total_balance'] != null
          ? (json['total_balance']).toDouble()
          : null,
      affiliateBonus: json['affiliate_bonus'] != null
          ? (json['affiliate_bonus']).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'display_name': displayName,
      'avatar': avatar,
      'created_at': createdAt?.toIso8601String(),
      'total_balance': totalBalance,
      'affiliate_bonus': affiliateBonus,
    };
  }

  String get displayNameOrName =>
      displayName?.isNotEmpty == true ? displayName! : name;
}
