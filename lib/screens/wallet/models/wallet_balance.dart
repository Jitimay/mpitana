import 'package:objectbox/objectbox.dart';

@Entity()
class WalletBalance {
  @Id()
  int id = 0;
  
  // User identification
  @Index()
  late String userId;
  
  // Balance details
  late double availableBalance;
  late double pendingBalance; // Money that's on hold (e.g., for ongoing rides)
  late double totalBalance; // availableBalance + pendingBalance
  
  // Timestamps
  @Property(type: PropertyType.date)
  late DateTime lastUpdated;
  
  @Property(type: PropertyType.date)
  late DateTime createdAt;
  
  // Currency (for future multi-currency support)
  String currency = 'USD';
  
  // Status
  bool isActive = true;
  bool isFrozen = false; // Account can be frozen for security reasons
  
  WalletBalance({
    required this.userId,
    this.availableBalance = 0.0,
    this.pendingBalance = 0.0,
    this.currency = 'USD',
    this.isActive = true,
    this.isFrozen = false,
  }) {
    createdAt = DateTime.now();
    lastUpdated = DateTime.now();
    totalBalance = availableBalance + pendingBalance;
  }
  
  // Helper methods
  void updateBalance({
    double? available,
    double? pending,
  }) {
    if (available != null) availableBalance = available;
    if (pending != null) pendingBalance = pending;
    totalBalance = availableBalance + pendingBalance;
    lastUpdated = DateTime.now();
  }
  
  bool canDeduct(double amount) {
    return !isFrozen && isActive && availableBalance >= amount;
  }
  
  void addMoney(double amount) {
    availableBalance += amount;
    totalBalance = availableBalance + pendingBalance;
    lastUpdated = DateTime.now();
  }
  
  void deductMoney(double amount) {
    if (canDeduct(amount)) {
      availableBalance -= amount;
      totalBalance = availableBalance + pendingBalance;
      lastUpdated = DateTime.now();
    }
  }
  
  void holdMoney(double amount) {
    if (canDeduct(amount)) {
      availableBalance -= amount;
      pendingBalance += amount;
      totalBalance = availableBalance + pendingBalance;
      lastUpdated = DateTime.now();
    }
  }
  
  void releaseMoney(double amount) {
    if (pendingBalance >= amount) {
      pendingBalance -= amount;
      availableBalance += amount;
      totalBalance = availableBalance + pendingBalance;
      lastUpdated = DateTime.now();
    }
  }
  
  String get formattedAvailableBalance => '\$${availableBalance.toStringAsFixed(2)}';
  String get formattedPendingBalance => '\$${pendingBalance.toStringAsFixed(2)}';
  String get formattedTotalBalance => '\$${totalBalance.toStringAsFixed(2)}';
}
