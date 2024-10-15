import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final String phone;
  final String address;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.phone,
    required this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    String? phone,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, role: $role, phone: $phone, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.role == role &&
        other.phone == phone &&
        other.address == address;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        role.hashCode ^
        phone.hashCode ^
        address.hashCode;
  }
}
