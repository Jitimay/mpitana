import 'package:mpitana/screens/wallet/models/wallet_balance.dart';
import 'package:mpitana/screens/wallet/models/wallet_transaction.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletBalance balance;
  final List<WalletTransaction> transactions;
  
  WalletLoaded({
    required this.balance,
    required this.transactions,
  });
}

class WalletTransactionLoading extends WalletState {
  final WalletBalance balance;
  final List<WalletTransaction> transactions;
  
  WalletTransactionLoading({
    required this.balance,
    required this.transactions,
  });
}

class WalletMoneyAdded extends WalletState {
  final WalletBalance balance;
  final List<WalletTransaction> transactions;
  final WalletTransaction newTransaction;
  final String message;
  
  WalletMoneyAdded({
    required this.balance,
    required this.transactions,
    required this.newTransaction,
    required this.message,
  });
}

class WalletMoneyDeducted extends WalletState {
  final WalletBalance balance;
  final List<WalletTransaction> transactions;
  final WalletTransaction newTransaction;
  final String message;
  
  WalletMoneyDeducted({
    required this.balance,
    required this.transactions,
    required this.newTransaction,
    required this.message,
  });
}

class WalletMoneyRefunded extends WalletState {
  final WalletBalance balance;
  final List<WalletTransaction> transactions;
  final WalletTransaction newTransaction;
  final String message;
  
  WalletMoneyRefunded({
    required this.balance,
    required this.transactions,
    required this.newTransaction,
    required this.message,
  });
}

class WalletMoneyHeld extends WalletState {
  final WalletBalance balance;
  final List<WalletTransaction> transactions;
  final WalletTransaction newTransaction;
  final String message;
  
  WalletMoneyHeld({
    required this.balance,
    required this.transactions,
    required this.newTransaction,
    required this.message,
  });
}

class WalletMoneyReleased extends WalletState {
  final WalletBalance balance;
  final List<WalletTransaction> transactions;
  final WalletTransaction newTransaction;
  final String message;
  
  WalletMoneyReleased({
    required this.balance,
    required this.transactions,
    required this.newTransaction,
    required this.message,
  });
}

class WalletError extends WalletState {
  final String message;
  final WalletBalance? balance;
  final List<WalletTransaction>? transactions;
  
  WalletError({
    required this.message,
    this.balance,
    this.transactions,
  });
}

class WalletInsufficientFunds extends WalletState {
  final WalletBalance balance;
  final List<WalletTransaction> transactions;
  final double requiredAmount;
  final double availableAmount;
  final String message;
  
  WalletInsufficientFunds({
    required this.balance,
    required this.transactions,
    required this.requiredAmount,
    required this.availableAmount,
    required this.message,
  });
}
