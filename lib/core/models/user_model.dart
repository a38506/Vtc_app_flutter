class User {
  final String id;
  final String name;
  final String email;
  final int userType;
  final String? roleId;
  final String? branchId;
  final String? customerId;
  final String? avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.roleId,
    this.branchId,
    this.customerId,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      userType: json['user_type'] ?? 0,
      roleId: json['role_id']?.toString(),
      branchId: json['branch_id']?.toString(),
      customerId: json['customer_id']?.toString(),
      avatar: json['avartar'], // trong JSON viết sai chính tả "avartar"
    );
  }
}
