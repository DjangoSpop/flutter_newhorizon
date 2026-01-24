import 'package:uuid/uuid.dart';

/// Payment method model
class PaymentMethod {
  String id;
  String userId;
  PaymentMethodType type;
  bool isDefault;

  // Card details (for card payments)
  String? cardLast4;
  String? cardBrand; // visa, mastercard, amex, etc.
  String? cardExpMonth;
  String? cardExpYear;
  String? cardHolderName;

  // Digital wallet details
  String? walletEmail; // For PayPal, etc.

  // Metadata
  String? stripePaymentMethodId;
  DateTime createdAt;
  DateTime? updatedAt;

  PaymentMethod({
    String? id,
    required this.userId,
    required this.type,
    this.isDefault = false,
    this.cardLast4,
    this.cardBrand,
    this.cardExpMonth,
    this.cardExpYear,
    this.cardHolderName,
    this.walletEmail,
    this.stripePaymentMethodId,
    DateTime? createdAt,
    this.updatedAt,
  })  : this.id = id ?? Uuid().v4(),
        this.createdAt = createdAt ?? DateTime.now();

  /// Get display name for payment method
  String get displayName {
    switch (type) {
      case PaymentMethodType.card:
        return '${cardBrand?.toUpperCase() ?? 'Card'} •••• ${cardLast4 ?? '****'}';
      case PaymentMethodType.paypal:
        return 'PayPal${walletEmail != null ? ' ($walletEmail)' : ''}';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.cashOnDelivery:
        return 'Cash on Delivery';
      default:
        return 'Payment Method';
    }
  }

  /// Get icon name for payment method
  String get iconName {
    switch (type) {
      case PaymentMethodType.card:
        return _getCardIcon();
      case PaymentMethodType.paypal:
        return 'paypal';
      case PaymentMethodType.googlePay:
        return 'google_pay';
      case PaymentMethodType.applePay:
        return 'apple_pay';
      case PaymentMethodType.cashOnDelivery:
        return 'cash';
      default:
        return 'payment';
    }
  }

  /// Get card brand icon
  String _getCardIcon() {
    switch (cardBrand?.toLowerCase()) {
      case 'visa':
        return 'visa';
      case 'mastercard':
        return 'mastercard';
      case 'amex':
      case 'american express':
        return 'amex';
      case 'discover':
        return 'discover';
      default:
        return 'credit_card';
    }
  }

  /// Check if card is expired
  bool get isExpired {
    if (cardExpMonth == null || cardExpYear == null) return false;

    try {
      final expMonth = int.parse(cardExpMonth!);
      final expYear = int.parse(cardExpYear!);
      final now = DateTime.now();

      // Assuming expYear is in YY format
      final fullYear = expYear < 100 ? 2000 + expYear : expYear;

      final expiryDate = DateTime(fullYear, expMonth + 1, 0);
      return expiryDate.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  /// Create from JSON
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      userId: json['userId'] ?? json['user_id'],
      type: PaymentMethodType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] ?? 'card'),
        orElse: () => PaymentMethodType.card,
      ),
      isDefault: json['isDefault'] ?? json['is_default'] ?? false,
      cardLast4: json['cardLast4'] ?? json['card_last4'],
      cardBrand: json['cardBrand'] ?? json['card_brand'],
      cardExpMonth: json['cardExpMonth'] ?? json['card_exp_month'],
      cardExpYear: json['cardExpYear'] ?? json['card_exp_year'],
      cardHolderName: json['cardHolderName'] ?? json['card_holder_name'],
      walletEmail: json['walletEmail'] ?? json['wallet_email'],
      stripePaymentMethodId:
          json['stripePaymentMethodId'] ?? json['stripe_payment_method_id'],
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
      'type': type.toString().split('.').last,
      'isDefault': isDefault,
      'cardLast4': cardLast4,
      'cardBrand': cardBrand,
      'cardExpMonth': cardExpMonth,
      'cardExpYear': cardExpYear,
      'cardHolderName': cardHolderName,
      'walletEmail': walletEmail,
      'stripePaymentMethodId': stripePaymentMethodId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  PaymentMethod copyWith({
    bool? isDefault,
    DateTime? updatedAt,
  }) {
    return PaymentMethod(
      id: id,
      userId: userId,
      type: type,
      isDefault: isDefault ?? this.isDefault,
      cardLast4: cardLast4,
      cardBrand: cardBrand,
      cardExpMonth: cardExpMonth,
      cardExpYear: cardExpYear,
      cardHolderName: cardHolderName,
      walletEmail: walletEmail,
      stripePaymentMethodId: stripePaymentMethodId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

/// Payment method type enum
enum PaymentMethodType {
  card,
  paypal,
  googlePay,
  applePay,
  cashOnDelivery,
}
