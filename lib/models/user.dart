class User {
  final int id;
  final String name;
  final String email;
  final String? displayName;
  final String? avatar;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.displayName,
    this.avatar,
    this.createdAt,
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
    };
  }

  String get displayNameOrName =>
      displayName?.isNotEmpty == true ? displayName! : name;
}
