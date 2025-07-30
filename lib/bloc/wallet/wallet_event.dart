import 'package:equatable/equatable.dart';
import 'package:mpitana/screens/wallet/models/payment_method.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWallet extends WalletEvent {
  final String userId;

  const LoadWallet(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadTransactions extends WalletEvent {
  final String userId;
  final int limit;

  const LoadTransactions(this.userId, {this.limit = 50});

  @override
  List<Object> get props => [userId, limit];
}

class LoadPaymentMethods extends WalletEvent {
  final String userId;

  const LoadPaymentMethods(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddMoney extends WalletEvent {
  final String userId;
  final double amount;
  final String paymentMethodId;
  final String? description;

  const AddMoney({
    required this.userId,
    required this.amount,
    required this.paymentMethodId,
    this.description,
  });

  @override
  List<Object?> get props => [userId, amount, paymentMethodId, description];
}

class MakePayment extends WalletEvent {
  final String userId;
  final double amount;
  final String description;
  final String? referenceId;

  const MakePayment({
    required this.userId,
    required this.amount,
    required this.description,
    this.referenceId,
  });

  @override
  List<Object?> get props => [userId, amount, description, referenceId];
}

class AddPaymentMethod extends WalletEvent {
  final PaymentMethod paymentMethod;

  const AddPaymentMethod(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}

class RemovePaymentMethod extends WalletEvent {
  final int paymentMethodId;
  final String userId;

  const RemovePaymentMethod(this.paymentMethodId, this.userId);

  @override
  List<Object> get props => [paymentMethodId, userId];
}

class SetDefaultPaymentMethod extends WalletEvent {
  final int paymentMethodId;
  final String userId;

  const SetDefaultPaymentMethod(this.paymentMethodId, this.userId);

  @override
  List<Object> get props => [paymentMethodId, userId];
}

class RefreshWallet extends WalletEvent {
  final String userId;

  const RefreshWallet(this.userId);

  @override
  List<Object> get props => [userId];
}

class CreateDemoData extends WalletEvent {
  final String userId;

  const CreateDemoData(this.userId);

  @override
  List<Object> get props => [userId];
}
