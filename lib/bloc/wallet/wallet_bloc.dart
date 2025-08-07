import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/bloc/wallet/wallet_event.dart';
import 'package:mpitana/bloc/wallet/wallet_state.dart';
import 'package:mpitana/screens/wallet/models/wallet_balance.dart';
import 'package:mpitana/screens/wallet/models/wallet_transaction.dart';
import 'package:mpitana/screens/wallet/services/wallet_service.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletService _walletService = WalletService();
  
  WalletBloc() : super(WalletInitial()) {
    on<LoadWalletEvent>(_onLoadWallet);
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<AddMoneyEvent>(_onAddMoney);
    on<DeductMoneyEvent>(_onDeductMoney);
    on<RefundMoneyEvent>(_onRefundMoney);
    on<HoldMoneyEvent>(_onHoldMoney);
    on<ReleaseMoneyEvent>(_onReleaseMoney);
    on<RefreshWalletEvent>(_onRefreshWallet);
  }
  
  Future<void> _onLoadWallet(LoadWalletEvent event, Emitter<WalletState> emit) async {
    try {
      emit(WalletLoading());
      
      final balance = await _walletService.getOrCreateWalletBalance(event.userId);
      final transactions = await _walletService.getTransactions(event.userId, limit: 20);
      
      emit(WalletLoaded(balance: balance, transactions: transactions));
    } catch (e) {
      emit(WalletError(message: 'Failed to load wallet: ${e.toString()}'));
    }
  }
  
  Future<void> _onLoadTransactions(LoadTransactionsEvent event, Emitter<WalletState> emit) async {
    try {
      final currentState = state;
      if (currentState is WalletLoaded) {
        emit(WalletTransactionLoading(
          balance: currentState.balance,
          transactions: currentState.transactions,
        ));
      }
      
      final transactions = await _walletService.getTransactions(
        event.userId,
        limit: event.limit,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );
      
      final balance = await _walletService.getOrCreateWalletBalance(event.userId);
      
      emit(WalletLoaded(balance: balance, transactions: transactions));
    } catch (e) {
      emit(WalletError(message: 'Failed to load transactions: ${e.toString()}'));
    }
  }
  
  Future<void> _onAddMoney(AddMoneyEvent event, Emitter<WalletState> emit) async {
    try {
      final currentState = state;
      WalletBalance? currentBalance;
      List<WalletTransaction> currentTransactions = [];
      
      if (currentState is WalletLoaded) {
        currentBalance = currentState.balance;
        currentTransactions = currentState.transactions;
        emit(WalletTransactionLoading(
          balance: currentBalance,
          transactions: currentTransactions,
        ));
      }
      
      final result = await _walletService.addMoney(
        userId: event.userId,
        amount: event.amount,
        paymentMethod: event.paymentMethod,
        reference: event.reference,
      );
      
      final updatedBalance = await _walletService.getOrCreateWalletBalance(event.userId);
      final updatedTransactions = await _walletService.getTransactions(event.userId, limit: 20);
      
      emit(WalletMoneyAdded(
        balance: updatedBalance,
        transactions: updatedTransactions,
        newTransaction: result,
        message: 'Money added successfully!',
      ));
    } catch (e) {
      emit(WalletError(message: 'Failed to add money: ${e.toString()}'));
    }
  }
  
  Future<void> _onDeductMoney(DeductMoneyEvent event, Emitter<WalletState> emit) async {
    try {
      final currentState = state;
      WalletBalance? currentBalance;
      List<WalletTransaction> currentTransactions = [];
      
      if (currentState is WalletLoaded) {
        currentBalance = currentState.balance;
        currentTransactions = currentState.transactions;
        
        // Check if sufficient funds
        if (!currentBalance.canDeduct(event.amount)) {
          emit(WalletInsufficientFunds(
            balance: currentBalance,
            transactions: currentTransactions,
            requiredAmount: event.amount,
            availableAmount: currentBalance.availableBalance,
            message: 'Insufficient funds. Please add money to your wallet.',
          ));
          return;
        }
        
        emit(WalletTransactionLoading(
          balance: currentBalance,
          transactions: currentTransactions,
        ));
      }
      
      final result = await _walletService.deductMoney(
        userId: event.userId,
        amount: event.amount,
        description: event.description,
        rideId: event.rideId,
        fromLocation: event.fromLocation,
        toLocation: event.toLocation,
      );
      
      final updatedBalance = await _walletService.getOrCreateWalletBalance(event.userId);
      final updatedTransactions = await _walletService.getTransactions(event.userId, limit: 20);
      
      emit(WalletMoneyDeducted(
        balance: updatedBalance,
        transactions: updatedTransactions,
        newTransaction: result,
        message: 'Payment successful!',
      ));
    } catch (e) {
      emit(WalletError(message: 'Failed to deduct money: ${e.toString()}'));
    }
  }
  
  Future<void> _onRefundMoney(RefundMoneyEvent event, Emitter<WalletState> emit) async {
    try {
      final currentState = state;
      if (currentState is WalletLoaded) {
        emit(WalletTransactionLoading(
          balance: currentState.balance,
          transactions: currentState.transactions,
        ));
      }
      
      final result = await _walletService.refundMoney(
        userId: event.userId,
        amount: event.amount,
        description: event.description,
        rideId: event.rideId,
        originalTransactionId: event.originalTransactionId,
      );
      
      final updatedBalance = await _walletService.getOrCreateWalletBalance(event.userId);
      final updatedTransactions = await _walletService.getTransactions(event.userId, limit: 20);
      
      emit(WalletMoneyRefunded(
        balance: updatedBalance,
        transactions: updatedTransactions,
        newTransaction: result,
        message: 'Refund processed successfully!',
      ));
    } catch (e) {
      emit(WalletError(message: 'Failed to process refund: ${e.toString()}'));
    }
  }
  
  Future<void> _onHoldMoney(HoldMoneyEvent event, Emitter<WalletState> emit) async {
    try {
      final currentState = state;
      if (currentState is WalletLoaded) {
        if (!currentState.balance.canDeduct(event.amount)) {
          emit(WalletInsufficientFunds(
            balance: currentState.balance,
            transactions: currentState.transactions,
            requiredAmount: event.amount,
            availableAmount: currentState.balance.availableBalance,
            message: 'Insufficient funds to hold this amount.',
          ));
          return;
        }
        
        emit(WalletTransactionLoading(
          balance: currentState.balance,
          transactions: currentState.transactions,
        ));
      }
      
      final result = await _walletService.holdMoney(
        userId: event.userId,
        amount: event.amount,
        description: event.description,
        rideId: event.rideId,
      );
      
      final updatedBalance = await _walletService.getOrCreateWalletBalance(event.userId);
      final updatedTransactions = await _walletService.getTransactions(event.userId, limit: 20);
      
      emit(WalletMoneyHeld(
        balance: updatedBalance,
        transactions: updatedTransactions,
        newTransaction: result,
        message: 'Money held successfully!',
      ));
    } catch (e) {
      emit(WalletError(message: 'Failed to hold money: ${e.toString()}'));
    }
  }
  
  Future<void> _onReleaseMoney(ReleaseMoneyEvent event, Emitter<WalletState> emit) async {
    try {
      final currentState = state;
      if (currentState is WalletLoaded) {
        emit(WalletTransactionLoading(
          balance: currentState.balance,
          transactions: currentState.transactions,
        ));
      }
      
      final result = await _walletService.releaseMoney(
        userId: event.userId,
        amount: event.amount,
        description: event.description,
        rideId: event.rideId,
      );
      
      final updatedBalance = await _walletService.getOrCreateWalletBalance(event.userId);
      final updatedTransactions = await _walletService.getTransactions(event.userId, limit: 20);
      
      emit(WalletMoneyReleased(
        balance: updatedBalance,
        transactions: updatedTransactions,
        newTransaction: result,
        message: 'Money released successfully!',
      ));
    } catch (e) {
      emit(WalletError(message: 'Failed to release money: ${e.toString()}'));
    }
  }
  
  Future<void> _onRefreshWallet(RefreshWalletEvent event, Emitter<WalletState> emit) async {
    add(LoadWalletEvent(userId: event.userId));
  }
}
