class UserModel {
  final int? id;
  final String name;
  final String phone;
  final String password;
  final String role;

  UserModel({
    this.id,
    required this.name,
    required this.phone,
    required this.password,
    this.role = 'user',
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        name: map['name'],
        phone: map['phone'],
        password: map['password'],
        role: map['role'],
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'password': password,
        'role': role,
      };
}