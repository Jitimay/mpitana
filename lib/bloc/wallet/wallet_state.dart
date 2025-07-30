import 'package:equatable/equatable.dart';
import 'package:mpitana/screens/wallet/models/wallet.dart';
import 'package:mpitana/screens/wallet/models/transaction.dart';
import 'package:mpitana/screens/wallet/models/payment_method.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final Wallet wallet;
  final Map<String, dynamic> stats;

  const WalletLoaded({
    required this.wallet,
    required this.stats,
  });

  @override
  List<Object> get props => [wallet, stats];
}

class TransactionsLoaded extends WalletState {
  final List<WalletTransaction> transactions;

  const TransactionsLoaded({required this.transactions});

  @override
  List<Object> get props => [transactions];
}

class PaymentMethodsLoaded extends WalletState {
  final List<PaymentMethod> paymentMethods;

  const PaymentMethodsLoaded({required this.paymentMethods});

  @override
  List<Object> get props => [paymentMethods];
}

class MoneyAddedSuccess extends WalletState {
  final String transactionId;

  const MoneyAddedSuccess({required this.transactionId});

  @override
  List<Object> get props => [transactionId];
}

class PaymentSuccess extends WalletState {}

class PaymentMethodAdded extends WalletState {}

class PaymentMethodRemoved extends WalletState {}

class DefaultPaymentMethodSet extends WalletState {}

class DemoDataCreated extends WalletState {}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object> get props => [message];
}
