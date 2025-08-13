class PersonalVoucher {
  final int id;
  final String code;
  final double amount;
  final String? description;
  final String status;
  final DateTime? expiresAt;
  final DateTime createdAt;

  PersonalVoucher({
    required this.id,
    required this.code,
    required this.amount,
    this.description,
    required this.status,
    this.expiresAt,
    required this.createdAt,
  });

  factory PersonalVoucher.fromJson(Map<String, dynamic> json) {
    return PersonalVoucher(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      description: json['description'],
      status: json['status'] ?? 'active',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'amount': amount,
      'description': description,
      'status': status,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isActive => status == 'active';
  bool get isUsed => status == 'used';
  bool get isValid => isActive && !isExpired;

  String get displayStatus {
    if (isUsed) return 'Used';
    if (isExpired) return 'Expired';
    if (isActive) return 'Active';
    return status;
  }
}
