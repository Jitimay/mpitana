import 'package:objectbox/objectbox.dart';

enum PaymentMethodType {
  creditCard,
  debitCard,
  bankAccount,
  paypal,
  applePay,
  googlePay,
  mobileMoney
}

@Entity()
class PaymentMethod {
  @Id()
  int id = 0;

  String userId;
  String methodId; // Unique identifier for the payment method
  
  int typeIndex; // Store enum as int instead of using @Property(type: PropertyType.byte)
  
  String displayName; // e.g., "Visa ending in 1234"
  String? last4Digits; // Last 4 digits for cards
  String? brand; // Visa, Mastercard, etc.
  String? expiryMonth;
  String? expiryYear;
  String? bankName;
  String? accountHolderName;
  
  bool isDefault;
  bool isActive;
  
  // For payment gateway integration
  String? stripePaymentMethodId;
  String? paypalPaymentMethodId;
  
  DateTime createdAt;
  DateTime updatedAt;

  PaymentMethod({
    required this.userId,
    required this.methodId,
    PaymentMethodType type = PaymentMethodType.creditCard,
    required this.displayName,
    this.last4Digits,
    this.brand,
    this.expiryMonth,
    this.expiryYear,
    this.bankName,
    this.accountHolderName,
    this.isDefault = false,
    this.isActive = true,
    this.stripePaymentMethodId,
    this.paypalPaymentMethodId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : typeIndex = type.index,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Getter to convert int back to enum
  PaymentMethodType get type => PaymentMethodType.values[typeIndex];
  
  // Setter to convert enum to int
  set type(PaymentMethodType value) {
    typeIndex = value.index;
  }

  String get typeDisplayName {
    switch (type) {
      case PaymentMethodType.creditCard:
        return 'Credit Card';
      case PaymentMethodType.debitCard:
        return 'Debit Card';
      case PaymentMethodType.bankAccount:
        return 'Bank Account';
      case PaymentMethodType.paypal:
        return 'PayPal';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.mobileMoney:
        return 'Mobile Money';
    }
  }

  String get maskedNumber {
    if (last4Digits != null) {
      return '**** **** **** $last4Digits';
    }
    return displayName;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'methodId': methodId,
      'type': type.index,
      'displayName': displayName,
      'last4Digits': last4Digits,
      'brand': brand,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'bankName': bankName,
      'accountHolderName': accountHolderName,
      'isDefault': isDefault,
      'isActive': isActive,
      'stripePaymentMethodId': stripePaymentMethodId,
      'paypalPaymentMethodId': paypalPaymentMethodId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      userId: json['userId'],
      methodId: json['methodId'],
      type: PaymentMethodType.values[json['type'] ?? 0],
      displayName: json['displayName'],
      last4Digits: json['last4Digits'],
      brand: json['brand'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      bankName: json['bankName'],
      accountHolderName: json['accountHolderName'],
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
      stripePaymentMethodId: json['stripePaymentMethodId'],
      paypalPaymentMethodId: json['paypalPaymentMethodId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    )..id = json['id'] ?? 0;
  }
}
