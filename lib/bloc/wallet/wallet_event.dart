abstract class WalletEvent {}

class LoadWalletEvent extends WalletEvent {
  final String userId;
  
  LoadWalletEvent({required this.userId});
}

class LoadTransactionsEvent extends WalletEvent {
  final String userId;
  final int? limit;
  final DateTime? fromDate;
  final DateTime? toDate;
  
  LoadTransactionsEvent({
    required this.userId,
    this.limit,
    this.fromDate,
    this.toDate,
  });
}

class AddMoneyEvent extends WalletEvent {
  final String userId;
  final double amount;
  final String paymentMethod;
  final String? reference;
  
  AddMoneyEvent({
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    this.reference,
  });
}

class DeductMoneyEvent extends WalletEvent {
  final String userId;
  final double amount;
  final String description;
  final String? rideId;
  final String? fromLocation;
  final String? toLocation;
  
  DeductMoneyEvent({
    required this.userId,
    required this.amount,
    required this.description,
    this.rideId,
    this.fromLocation,
    this.toLocation,
  });
}

class RefundMoneyEvent extends WalletEvent {
  final String userId;
  final double amount;
  final String description;
  final String? rideId;
  final String? originalTransactionId;
  
  RefundMoneyEvent({
    required this.userId,
    required this.amount,
    required this.description,
    this.rideId,
    this.originalTransactionId,
  });
}

class HoldMoneyEvent extends WalletEvent {
  final String userId;
  final double amount;
  final String description;
  final String? rideId;
  
  HoldMoneyEvent({
    required this.userId,
    required this.amount,
    required this.description,
    this.rideId,
  });
}

class ReleaseMoneyEvent extends WalletEvent {
  final String userId;
  final double amount;
  final String description;
  final String? rideId;
  
  ReleaseMoneyEvent({
    required this.userId,
    required this.amount,
    required this.description,
    this.rideId,
  });
}

class RefreshWalletEvent extends WalletEvent {
  final String userId;
  
  RefreshWalletEvent({required this.userId});
}
