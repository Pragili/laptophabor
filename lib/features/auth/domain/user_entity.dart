class UserEntity {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String role;

  UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  factory UserEntity.fromJson(Map<String, dynamic> j) => UserEntity(
        id: j['id'],
        fullName: j['fullName'] ?? '',
        email: j['email'] ?? '',
        phone: j['phone'],
        avatarUrl: j['avatarUrl'],
        role: j['role'] ?? 'customer',
      );
}
