import 'package:objectbox/objectbox.dart';

@Entity()
class WalletTransaction {
  @Id()
  int id = 0;
  
  // User identification
  late String userId;
  
  // Transaction details
  late double amount;
  late String type; // 'credit', 'debit', 'refund', 'payment'
  late String description;
  late String status; // 'pending', 'completed', 'failed', 'cancelled'
  
  // Timestamps
  @Index()
  @Property(type: PropertyType.date)
  late DateTime createdAt;
  
  @Property(type: PropertyType.date)
  DateTime? completedAt;
  
  // Optional fields
  String? rideId; // Link to ride if transaction is ride-related
  String? paymentMethod; // 'card', 'bank_transfer', 'mobile_money'
  String? transactionId; // External payment gateway transaction ID
  String? reference; // Internal reference number
  
  // Additional metadata
  String? fromLocation;
  String? toLocation;
  String? driverName;
  
  WalletTransaction({
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.status,
    this.rideId,
    this.paymentMethod,
    this.transactionId,
    this.reference,
    this.fromLocation,
    this.toLocation,
    this.driverName,
  }) {
    createdAt = DateTime.now();
  }
  
  // Helper methods
  bool get isCredit => type == 'credit' || type == 'refund';
  bool get isDebit => type == 'debit' || type == 'payment';
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  
  String get formattedAmount {
    final sign = isCredit ? '+' : '-';
    return '$sign\$${amount.toStringAsFixed(2)}';
  }
  
  String get displayDescription {
    if (rideId != null && fromLocation != null && toLocation != null) {
      return '$description: $fromLocation → $toLocation';
    }
    return description;
  }
}
