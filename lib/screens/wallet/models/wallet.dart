import 'package:objectbox/objectbox.dart';

@Entity()
class Wallet {
  @Id()
  int id = 0;

  @Unique()
  String userId;
  
  double balance;
  String currency;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;

  Wallet({
    required this.userId,
    this.balance = 0.0,
    this.currency = 'USD',
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'balance': balance,
      'currency': currency,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      userId: json['userId'],
      balance: json['balance']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    )..id = json['id'] ?? 0;
  }
}
