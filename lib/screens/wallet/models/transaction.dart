import 'package:objectbox/objectbox.dart';

enum TransactionType {
  topUp,
  payment,
  refund,
  withdrawal,
  earning,
  bonus,
  penalty
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled
}

@Entity()
class WalletTransaction {
  @Id()
  int id = 0;

  String userId;
  String transactionId;
  double amount;
  String currency;
  
  int typeIndex; // Store enum as int
  int statusIndex; // Store enum as int
  
  String description;
  String? referenceId; // For ride bookings, etc.
  String? paymentMethod; // Credit card, bank transfer, etc.
  String? paymentGatewayId; // Stripe, PayPal transaction ID
  
  double balanceBefore;
  double balanceAfter;
  
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? completedAt;

  WalletTransaction({
    required this.userId,
    required this.transactionId,
    required this.amount,
    this.currency = 'USD',
    TransactionType type = TransactionType.topUp,
    TransactionStatus status = TransactionStatus.pending,
    required this.description,
    this.referenceId,
    this.paymentMethod,
    this.paymentGatewayId,
    this.balanceBefore = 0.0,
    this.balanceAfter = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.completedAt,
  }) : typeIndex = type.index,
       statusIndex = status.index,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Getters to convert int back to enum
  TransactionType get type => TransactionType.values[typeIndex];
  TransactionStatus get status => TransactionStatus.values[statusIndex];
  
  // Setters to convert enum to int
  set type(TransactionType value) {
    typeIndex = value.index;
  }
  
  set status(TransactionStatus value) {
    statusIndex = value.index;
  }

  String get typeDisplayName {
    switch (type) {
      case TransactionType.topUp:
        return 'Top Up';
      case TransactionType.payment:
        return 'Payment';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.earning:
        return 'Earning';
      case TransactionType.bonus:
        return 'Bonus';
      case TransactionType.penalty:
        return 'Penalty';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isCredit {
    return type == TransactionType.topUp ||
           type == TransactionType.refund ||
           type == TransactionType.earning ||
           type == TransactionType.bonus;
  }

  bool get isDebit {
    return type == TransactionType.payment ||
           type == TransactionType.withdrawal ||
           type == TransactionType.penalty;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'transactionId': transactionId,
      'amount': amount,
      'currency': currency,
      'type': type.index,
      'status': status.index,
      'description': description,
      'referenceId': referenceId,
      'paymentMethod': paymentMethod,
      'paymentGatewayId': paymentGatewayId,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      userId: json['userId'],
      transactionId: json['transactionId'],
      amount: json['amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      type: TransactionType.values[json['type'] ?? 0],
      status: TransactionStatus.values[json['status'] ?? 0],
      description: json['description'] ?? '',
      referenceId: json['referenceId'],
      paymentMethod: json['paymentMethod'],
      paymentGatewayId: json['paymentGatewayId'],
      balanceBefore: json['balanceBefore']?.toDouble() ?? 0.0,
      balanceAfter: json['balanceAfter']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    )..id = json['id'] ?? 0;
  }
}
