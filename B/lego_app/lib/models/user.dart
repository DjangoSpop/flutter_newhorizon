class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final String phone;
  final String address;
  final String shopName;
  final String shopDescription;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.phone,
    required this.address,
    required this.shopName,
    required this.shopDescription,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      shopName: json['shopname'] ?? '',
      shopDescription: json['shopdes'] ?? '',
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
      'shopname': shopName,
      'shopdes': shopDescription,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    String? phone,
    String? address,
    String? shopName,
    String? shopDescription,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      shopName: shopName ?? this.shopName,
      shopDescription: shopDescription ?? this.shopDescription,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, role: $role, phone: $phone, address: $address, shopName: $shopName, shopDescription: $shopDescription)';
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
        other.address == address &&
        other.shopName == shopName &&
        other.shopDescription == shopDescription;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        role.hashCode ^
        phone.hashCode ^
        address.hashCode ^
        shopName.hashCode ^
        shopDescription.hashCode;
  }
}
