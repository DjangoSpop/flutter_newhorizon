import 'package:uuid/uuid.dart';

/// User address model for shipping and billing
class Address {
  String id;
  String userId;
  String fullName;
  String phoneNumber;
  String addressLine1;
  String? addressLine2;
  String city;
  String state;
  String postalCode;
  String country;
  bool isDefault;
  AddressType type;
  String? label; // e.g., "Home", "Office"
  double? latitude;
  double? longitude;
  DateTime createdAt;
  DateTime? updatedAt;

  Address({
    String? id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
    this.type = AddressType.shipping,
    this.label,
    this.latitude,
    this.longitude,
    DateTime? createdAt,
    this.updatedAt,
  })  : this.id = id ?? Uuid().v4(),
        this.createdAt = createdAt ?? DateTime.now();

  /// Get full address as a single string
  String get fullAddress {
    StringBuffer buffer = StringBuffer();
    buffer.write(addressLine1);
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      buffer.write(', $addressLine2');
    }
    buffer.write(', $city, $state $postalCode');
    buffer.write(', $country');
    return buffer.toString();
  }

  /// Get short address (for lists)
  String get shortAddress {
    return '$addressLine1, $city, $state';
  }

  /// Create from JSON
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      userId: json['userId'] ?? json['user_id'],
      fullName: json['fullName'] ?? json['full_name'],
      phoneNumber: json['phoneNumber'] ?? json['phone_number'],
      addressLine1: json['addressLine1'] ?? json['address_line1'],
      addressLine2: json['addressLine2'] ?? json['address_line2'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'] ?? json['postal_code'],
      country: json['country'],
      isDefault: json['isDefault'] ?? json['is_default'] ?? false,
      type: AddressType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] ?? 'shipping'),
        orElse: () => AddressType.shipping,
      ),
      label: json['label'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse(json['createdAt'] ?? json['created_at'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['updated_at'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
      'type': type.toString().split('.').last,
      'label': label,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to API JSON (snake_case)
  Map<String, dynamic> toApiJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'is_default': isDefault,
      'type': type.toString().split('.').last,
      'label': label,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Create a copy with updated fields
  Address copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phoneNumber,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
    AddressType? type,
    String? label,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      type: type ?? this.type,
      label: label ?? this.label,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Address(id: $id, fullName: $fullName, address: $shortAddress)';
  }
}

/// Address type enum
enum AddressType {
  shipping,
  billing,
  both,
}
