import 'package:mpitana/screens/wallet/models/wallet_balance.dart';
import 'package:mpitana/screens/wallet/models/wallet_transaction.dart';
import 'package:mpitana/common/database/objectbox_db.dart';
import 'package:mpitana/objectbox.g.dart';

class WalletService {
  // Get or create wallet balance for user
  Future<WalletBalance> getOrCreateWalletBalance(String userId) async {
    try {
      final box = await ObjectBoxDb.walletBalanceBox;
      final query = box.query(WalletBalance_.userId.equals(userId)).build();
      final results = query.find();
      query.close();
      
      if (results.isNotEmpty) {
        return results.first;
      } else {
        // Create new wallet balance
        final newBalance = WalletBalance(userId: userId);
        box.put(newBalance);
        return newBalance;
      }
    } catch (e) {
      throw Exception('Failed to get wallet balance: $e');
    }
  }
  
  // Get transactions for user
  Future<List<WalletTransaction>> getTransactions(
    String userId, {
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final box = await ObjectBoxDb.walletTransactionBox;
      final query = box.query(WalletTransaction_.userId.equals(userId))
          .order(WalletTransaction_.createdAt, flags: Order.descending)
          .build();
      
      var results = query.find();
      query.close();
      
      // Apply date filters in memory if provided
      if (fromDate != null && toDate != null) {
        results = results.where((transaction) {
          return transaction.createdAt.isAfter(fromDate) && 
                 transaction.createdAt.isBefore(toDate);
        }).toList();
      }
      
      // Apply limit if provided
      if (limit != null && results.length > limit) {
        results = results.take(limit).toList();
      }
      
      return results;
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }
  
  // Add money to wallet
  Future<WalletTransaction> addMoney({
    required String userId,
    required double amount,
    required String paymentMethod,
    String? reference,
  }) async {
    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }
    
    try {
      // Create transaction record
      final transaction = WalletTransaction(
        userId: userId,
        amount: amount,
        type: 'credit',
        description: 'Money added to wallet',
        status: 'completed',
        paymentMethod: paymentMethod,
        reference: reference ?? _generateReference(),
      );
      transaction.completedAt = DateTime.now();
      
      // Save transaction
      final transactionBox = await ObjectBoxDb.walletTransactionBox;
      transactionBox.put(transaction);
      
      // Update wallet balance
      final balance = await getOrCreateWalletBalance(userId);
      balance.addMoney(amount);
      
      final balanceBox = await ObjectBoxDb.walletBalanceBox;
      balanceBox.put(balance);
      
      return transaction;
    } catch (e) {
      throw Exception('Failed to add money: $e');
    }
  }
  
  // Deduct money from wallet
  Future<WalletTransaction> deductMoney({
    required String userId,
    required double amount,
    required String description,
    String? rideId,
    String? fromLocation,
    String? toLocation,
  }) async {
    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }
    
    try {
      // Check if user has sufficient balance
      final balance = await getOrCreateWalletBalance(userId);
      if (!balance.canDeduct(amount)) {
        throw Exception('Insufficient funds. Available: ${balance.formattedAvailableBalance}');
      }
      
      // Create transaction record
      final transaction = WalletTransaction(
        userId: userId,
        amount: amount,
        type: 'debit',
        description: description,
        status: 'completed',
        rideId: rideId,
        fromLocation: fromLocation,
        toLocation: toLocation,
        reference: _generateReference(),
      );
      transaction.completedAt = DateTime.now();
      
      // Save transaction
      final transactionBox = await ObjectBoxDb.walletTransactionBox;
      transactionBox.put(transaction);
      
      // Update wallet balance
      balance.deductMoney(amount);
      
      final balanceBox = await ObjectBoxDb.walletBalanceBox;
      balanceBox.put(balance);
      
      return transaction;
    } catch (e) {
      throw Exception('Failed to deduct money: $e');
    }
  }
  
  // Refund money to wallet
  Future<WalletTransaction> refundMoney({
    required String userId,
    required double amount,
    required String description,
    String? rideId,
    String? originalTransactionId,
  }) async {
    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }
    
    try {
      // Create refund transaction record
      final transaction = WalletTransaction(
        userId: userId,
        amount: amount,
        type: 'refund',
        description: description,
        status: 'completed',
        rideId: rideId,
        transactionId: originalTransactionId,
        reference: _generateReference(),
      );
      transaction.completedAt = DateTime.now();
      
      // Save transaction
      final transactionBox = await ObjectBoxDb.walletTransactionBox;
      transactionBox.put(transaction);
      
      // Update wallet balance
      final balance = await getOrCreateWalletBalance(userId);
      balance.addMoney(amount);
      
      final balanceBox = await ObjectBoxDb.walletBalanceBox;
      balanceBox.put(balance);
      
      return transaction;
    } catch (e) {
      throw Exception('Failed to process refund: $e');
    }
  }
  
  // Hold money (move from available to pending)
  Future<WalletTransaction> holdMoney({
    required String userId,
    required double amount,
    required String description,
    String? rideId,
  }) async {
    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }
    
    try {
      // Check if user has sufficient balance
      final balance = await getOrCreateWalletBalance(userId);
      if (!balance.canDeduct(amount)) {
        throw Exception('Insufficient funds to hold. Available: ${balance.formattedAvailableBalance}');
      }
      
      // Create hold transaction record
      final transaction = WalletTransaction(
        userId: userId,
        amount: amount,
        type: 'hold',
        description: description,
        status: 'completed',
        rideId: rideId,
        reference: _generateReference(),
      );
      transaction.completedAt = DateTime.now();
      
      // Save transaction
      final transactionBox = await ObjectBoxDb.walletTransactionBox;
      transactionBox.put(transaction);
      
      // Update wallet balance (move money to pending)
      balance.holdMoney(amount);
      
      final balanceBox = await ObjectBoxDb.walletBalanceBox;
      balanceBox.put(balance);
      
      return transaction;
    } catch (e) {
      throw Exception('Failed to hold money: $e');
    }
  }
  
  // Release held money (move from pending back to available)
  Future<WalletTransaction> releaseMoney({
    required String userId,
    required double amount,
    required String description,
    String? rideId,
  }) async {
    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }
    
    try {
      // Create release transaction record
      final transaction = WalletTransaction(
        userId: userId,
        amount: amount,
        type: 'release',
        description: description,
        status: 'completed',
        rideId: rideId,
        reference: _generateReference(),
      );
      transaction.completedAt = DateTime.now();
      
      // Save transaction
      final transactionBox = await ObjectBoxDb.walletTransactionBox;
      transactionBox.put(transaction);
      
      // Update wallet balance (move money from pending to available)
      final balance = await getOrCreateWalletBalance(userId);
      balance.releaseMoney(amount);
      
      final balanceBox = await ObjectBoxDb.walletBalanceBox;
      balanceBox.put(balance);
      
      return transaction;
    } catch (e) {
      throw Exception('Failed to release money: $e');
    }
  }
  
  // Get transaction by ID
  Future<WalletTransaction?> getTransaction(int transactionId) async {
    try {
      final box = await ObjectBoxDb.walletTransactionBox;
      return box.get(transactionId);
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }
  
  // Get transactions by ride ID
  Future<List<WalletTransaction>> getTransactionsByRide(String rideId) async {
    try {
      final box = await ObjectBoxDb.walletTransactionBox;
      final query = box.query(WalletTransaction_.rideId.equals(rideId)).build();
      final results = query.find();
      query.close();
      return results;
    } catch (e) {
      throw Exception('Failed to get ride transactions: $e');
    }
  }
  
  // Generate unique reference number
  String _generateReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'TXN$timestamp$random';
  }
  
  // Get wallet statistics
  Future<Map<String, dynamic>> getWalletStats(String userId) async {
    try {
      final transactions = await getTransactions(userId);
      final balance = await getOrCreateWalletBalance(userId);
      
      double totalCredits = 0;
      double totalDebits = 0;
      int totalTransactions = transactions.length;
      
      for (final transaction in transactions) {
        if (transaction.isCredit) {
          totalCredits += transaction.amount;
        } else if (transaction.isDebit) {
          totalDebits += transaction.amount;
        }
      }
      
      return {
        'currentBalance': balance.availableBalance,
        'pendingBalance': balance.pendingBalance,
        'totalBalance': balance.totalBalance,
        'totalCredits': totalCredits,
        'totalDebits': totalDebits,
        'totalTransactions': totalTransactions,
        'lastUpdated': balance.lastUpdated,
      };
    } catch (e) {
      throw Exception('Failed to get wallet stats: $e');
    }
  }
}
