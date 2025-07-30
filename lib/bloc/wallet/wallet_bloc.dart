import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/bloc/wallet/wallet_event.dart';
import 'package:mpitana/bloc/wallet/wallet_state.dart';
import 'package:mpitana/screens/wallet/services/wallet_service.dart';
import 'package:mpitana/screens/wallet/models/wallet.dart';
import 'package:mpitana/screens/wallet/models/transaction.dart';
import 'package:mpitana/screens/wallet/models/payment_method.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletInitial()) {
    on<LoadWallet>(_onLoadWallet);
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<AddMoney>(_onAddMoney);
    on<MakePayment>(_onMakePayment);
    on<AddPaymentMethod>(_onAddPaymentMethod);
    on<RemovePaymentMethod>(_onRemovePaymentMethod);
    on<SetDefaultPaymentMethod>(_onSetDefaultPaymentMethod);
    on<RefreshWallet>(_onRefreshWallet);
    on<CreateDemoData>(_onCreateDemoData);
  }

  Future<void> _onLoadWallet(LoadWallet event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    try {
      final wallet = await WalletService.getWallet(event.userId) ?? 
                    await WalletService.createWallet(event.userId);
      final stats = await WalletService.getWalletStats(event.userId);
      
      emit(WalletLoaded(wallet: wallet, stats: stats));
    } catch (e) {
      emit(WalletError('Failed to load wallet: $e'));
    }
  }

  Future<void> _onLoadTransactions(LoadTransactions event, Emitter<WalletState> emit) async {
    try {
      final transactions = await WalletService.getTransactions(event.userId, limit: event.limit);
      emit(TransactionsLoaded(transactions: transactions));
    } catch (e) {
      emit(WalletError('Failed to load transactions: $e'));
    }
  }

  Future<void> _onLoadPaymentMethods(LoadPaymentMethods event, Emitter<WalletState> emit) async {
    try {
      final paymentMethods = await WalletService.getPaymentMethods(event.userId);
      emit(PaymentMethodsLoaded(paymentMethods: paymentMethods));
    } catch (e) {
      emit(WalletError('Failed to load payment methods: $e'));
    }
  }

  Future<void> _onAddMoney(AddMoney event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    try {
      final transactionId = await WalletService.addMoney(
        userId: event.userId,
        amount: event.amount,
        paymentMethodId: event.paymentMethodId,
        description: event.description,
      );

      if (transactionId != null) {
        // Reload wallet data
        add(LoadWallet(event.userId));
        emit(MoneyAddedSuccess(transactionId: transactionId));
      } else {
        emit(WalletError('Failed to add money to wallet'));
      }
    } catch (e) {
      emit(WalletError('Failed to add money: $e'));
    }
  }

  Future<void> _onMakePayment(MakePayment event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    try {
      final success = await WalletService.makePayment(
        userId: event.userId,
        amount: event.amount,
        description: event.description,
        referenceId: event.referenceId,
      );

      if (success) {
        // Reload wallet data
        add(LoadWallet(event.userId));
        emit(PaymentSuccess());
      } else {
        emit(WalletError('Payment failed. Insufficient balance or other error.'));
      }
    } catch (e) {
      emit(WalletError('Payment failed: $e'));
    }
  }

  Future<void> _onAddPaymentMethod(AddPaymentMethod event, Emitter<WalletState> emit) async {
    try {
      final success = await WalletService.addPaymentMethod(event.paymentMethod);
      if (success) {
        add(LoadPaymentMethods(event.paymentMethod.userId));
        emit(PaymentMethodAdded());
      } else {
        emit(WalletError('Failed to add payment method'));
      }
    } catch (e) {
      emit(WalletError('Failed to add payment method: $e'));
    }
  }

  Future<void> _onRemovePaymentMethod(RemovePaymentMethod event, Emitter<WalletState> emit) async {
    try {
      final success = await WalletService.removePaymentMethod(event.paymentMethodId);
      if (success) {
        add(LoadPaymentMethods(event.userId));
        emit(PaymentMethodRemoved());
      } else {
        emit(WalletError('Failed to remove payment method'));
      }
    } catch (e) {
      emit(WalletError('Failed to remove payment method: $e'));
    }
  }

  Future<void> _onSetDefaultPaymentMethod(SetDefaultPaymentMethod event, Emitter<WalletState> emit) async {
    try {
      final success = await WalletService.setDefaultPaymentMethod(event.paymentMethodId, event.userId);
      if (success) {
        add(LoadPaymentMethods(event.userId));
        emit(DefaultPaymentMethodSet());
      } else {
        emit(WalletError('Failed to set default payment method'));
      }
    } catch (e) {
      emit(WalletError('Failed to set default payment method: $e'));
    }
  }

  Future<void> _onRefreshWallet(RefreshWallet event, Emitter<WalletState> emit) async {
    add(LoadWallet(event.userId));
  }

  Future<void> _onCreateDemoData(CreateDemoData event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    try {
      await WalletService.createDemoData(event.userId);
      add(LoadWallet(event.userId));
      emit(DemoDataCreated());
    } catch (e) {
      emit(WalletError('Failed to create demo data: $e'));
    }
  }
}
