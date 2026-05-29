class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? carType;
  final String? approvalStatus;
  final bool? isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.carType,
    this.approvalStatus,
    this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      carType: json['car_type']?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      isActive: json['is_active'] == null
          ? null
          : json['is_active'] == true || json['is_active'].toString() == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'car_type': carType,
      'approval_status': approvalStatus,
      'is_active': isActive,
    };
  }
}