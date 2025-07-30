import 'package:mpitana/common/database/objectbox_db.dart';
import 'package:mpitana/screens/wallet/models/wallet.dart';
import 'package:mpitana/screens/wallet/models/transaction.dart';
import 'package:mpitana/screens/wallet/models/payment_method.dart';
import 'package:mpitana/objectbox.g.dart';
import 'package:uuid/uuid.dart';

class WalletService {
  static final _uuid = Uuid();

  // Wallet Operations
  static Future<Wallet?> getWallet(String userId) async {
    final db = await ObjectBoxDb.instance;
    final walletBox = db.box<Wallet>();
    final query = walletBox.query(Wallet_.userId.equals(userId)).build();
    final wallet = query.findFirst();
    query.close();
    return wallet;
  }

  static Future<Wallet> createWallet(String userId) async {
    // Check if wallet already exists
    final existingWallet = await getWallet(userId);
    if (existingWallet != null) {
      return existingWallet;
    }

    final db = await ObjectBoxDb.instance;
    final walletBox = db.box<Wallet>();
    final wallet = Wallet(userId: userId);
    walletBox.put(wallet);
    return wallet;
  }

  static Future<bool> updateWalletBalance(String userId, double newBalance) async {
    try {
      final wallet = await getWallet(userId);
      if (wallet == null) return false;

      wallet.balance = newBalance;
      wallet.updatedAt = DateTime.now();
      
      final db = await ObjectBoxDb.instance;
      final walletBox = db.box<Wallet>();
      walletBox.put(wallet);
      return true;
    } catch (e) {
      print('Error updating wallet balance: $e');
      return false;
    }
  }

  // Transaction Operations
  static Future<String?> addMoney({
    required String userId,
    required double amount,
    required String paymentMethodId,
    String? description,
  }) async {
    try {
      final wallet = await getWallet(userId) ?? await createWallet(userId);
      final transactionId = _uuid.v4();
      
      final transaction = WalletTransaction(
        userId: userId,
        transactionId: transactionId,
        amount: amount,
        type: TransactionType.topUp,
        status: TransactionStatus.pending,
        description: description ?? 'Wallet top-up',
        paymentMethod: paymentMethodId,
        balanceBefore: wallet.balance,
        balanceAfter: wallet.balance + amount,
      );

      final db = await ObjectBoxDb.instance;
      final transactionBox = db.box<WalletTransaction>();
      transactionBox.put(transaction);

      // Simulate payment processing (replace with actual payment gateway)
      await Future.delayed(Duration(seconds: 2));
      
      // Update transaction status
      transaction.status = TransactionStatus.completed;
      transaction.completedAt = DateTime.now();
      transaction.updatedAt = DateTime.now();
      transactionBox.put(transaction);

      // Update wallet balance
      await updateWalletBalance(userId, wallet.balance + amount);

      return transactionId;
    } catch (e) {
      print('Error adding money: $e');
      return null;
    }
  }

  static Future<bool> makePayment({
    required String userId,
    required double amount,
    required String description,
    String? referenceId,
  }) async {
    try {
      final wallet = await getWallet(userId);
      if (wallet == null || wallet.balance < amount) {
        return false; // Insufficient balance
      }

      final transactionId = _uuid.v4();
      final transaction = WalletTransaction(
        userId: userId,
        transactionId: transactionId,
        amount: amount,
        type: TransactionType.payment,
        status: TransactionStatus.completed,
        description: description,
        referenceId: referenceId,
        balanceBefore: wallet.balance,
        balanceAfter: wallet.balance - amount,
        completedAt: DateTime.now(),
      );

      final db = await ObjectBoxDb.instance;
      final transactionBox = db.box<WalletTransaction>();
      transactionBox.put(transaction);

      // Update wallet balance
      await updateWalletBalance(userId, wallet.balance - amount);

      return true;
    } catch (e) {
      print('Error making payment: $e');
      return false;
    }
  }

  static Future<bool> addEarning({
    required String userId,
    required double amount,
    required String description,
    String? referenceId,
  }) async {
    try {
      final wallet = await getWallet(userId) ?? await createWallet(userId);
      final transactionId = _uuid.v4();
      
      final transaction = WalletTransaction(
        userId: userId,
        transactionId: transactionId,
        amount: amount,
        type: TransactionType.earning,
        status: TransactionStatus.completed,
        description: description,
        referenceId: referenceId,
        balanceBefore: wallet.balance,
        balanceAfter: wallet.balance + amount,
        completedAt: DateTime.now(),
      );

      final db = await ObjectBoxDb.instance;
      final transactionBox = db.box<WalletTransaction>();
      transactionBox.put(transaction);

      // Update wallet balance
      await updateWalletBalance(userId, wallet.balance + amount);

      return true;
    } catch (e) {
      print('Error adding earning: $e');
      return false;
    }
  }

  static Future<List<WalletTransaction>> getTransactions(String userId, {int limit = 50}) async {
    final db = await ObjectBoxDb.instance;
    final transactionBox = db.box<WalletTransaction>();
    final query = transactionBox
        .query(WalletTransaction_.userId.equals(userId))
        .order(WalletTransaction_.createdAt, flags: Order.descending)
        .build();
    
    final transactions = query.find();
    query.close();
    
    return transactions.take(limit).toList();
  }

  static Future<Map<String, dynamic>> getWalletStats(String userId) async {
    final transactions = await getTransactions(userId, limit: 1000);
    
    double totalEarnings = 0;
    double totalSpent = 0;
    double totalTopUps = 0;
    int completedTransactions = 0;
    
    for (final transaction in transactions) {
      if (transaction.status == TransactionStatus.completed) {
        completedTransactions++;
        
        switch (transaction.type) {
          case TransactionType.earning:
          case TransactionType.bonus:
          case TransactionType.refund:
            totalEarnings += transaction.amount;
            break;
          case TransactionType.payment:
          case TransactionType.penalty:
            totalSpent += transaction.amount;
            break;
          case TransactionType.topUp:
            totalTopUps += transaction.amount;
            break;
          default:
            break;
        }
      }
    }

    return {
      'totalEarnings': totalEarnings,
      'totalSpent': totalSpent,
      'totalTopUps': totalTopUps,
      'completedTransactions': completedTransactions,
      'totalTransactions': transactions.length,
    };
  }

  // Payment Method Operations
  static Future<List<PaymentMethod>> getPaymentMethods(String userId) async {
    final db = await ObjectBoxDb.instance;
    final paymentMethodBox = db.box<PaymentMethod>();
    final query = paymentMethodBox
        .query(PaymentMethod_.userId.equals(userId) & PaymentMethod_.isActive.equals(true))
        .order(PaymentMethod_.isDefault, flags: Order.descending)
        .build();
    
    final methods = query.find();
    query.close();
    return methods;
  }

  static Future<bool> addPaymentMethod(PaymentMethod paymentMethod) async {
    try {
      final db = await ObjectBoxDb.instance;
      final paymentMethodBox = db.box<PaymentMethod>();
      
      // If this is set as default, unset other default methods
      if (paymentMethod.isDefault) {
        final existingMethods = await getPaymentMethods(paymentMethod.userId);
        for (final method in existingMethods) {
          if (method.isDefault) {
            method.isDefault = false;
            paymentMethodBox.put(method);
          }
        }
      }
      
      paymentMethodBox.put(paymentMethod);
      return true;
    } catch (e) {
      print('Error adding payment method: $e');
      return false;
    }
  }

  static Future<bool> removePaymentMethod(int paymentMethodId) async {
    try {
      final db = await ObjectBoxDb.instance;
      final paymentMethodBox = db.box<PaymentMethod>();
      final paymentMethod = paymentMethodBox.get(paymentMethodId);
      
      if (paymentMethod != null) {
        paymentMethod.isActive = false;
        paymentMethod.updatedAt = DateTime.now();
        paymentMethodBox.put(paymentMethod);
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing payment method: $e');
      return false;
    }
  }

  static Future<bool> setDefaultPaymentMethod(int paymentMethodId, String userId) async {
    try {
      final db = await ObjectBoxDb.instance;
      final paymentMethodBox = db.box<PaymentMethod>();
      
      // Unset all default methods for this user
      final existingMethods = await getPaymentMethods(userId);
      for (final method in existingMethods) {
        method.isDefault = false;
        paymentMethodBox.put(method);
      }
      
      // Set the new default
      final paymentMethod = paymentMethodBox.get(paymentMethodId);
      if (paymentMethod != null) {
        paymentMethod.isDefault = true;
        paymentMethod.updatedAt = DateTime.now();
        paymentMethodBox.put(paymentMethod);
        return true;
      }
      return false;
    } catch (e) {
      print('Error setting default payment method: $e');
      return false;
    }
  }

  // Demo/Test Methods
  static Future<void> createDemoData(String userId) async {
    // Create wallet
    await createWallet(userId);
    
    // Add some demo payment methods
    final demoMethods = [
      PaymentMethod(
        userId: userId,
        methodId: 'card_1',
        type: PaymentMethodType.creditCard,
        displayName: 'Visa ending in 1234',
        last4Digits: '1234',
        brand: 'Visa',
        expiryMonth: '12',
        expiryYear: '2025',
        isDefault: true,
      ),
      PaymentMethod(
        userId: userId,
        methodId: 'card_2',
        type: PaymentMethodType.debitCard,
        displayName: 'Mastercard ending in 5678',
        last4Digits: '5678',
        brand: 'Mastercard',
        expiryMonth: '08',
        expiryYear: '2026',
      ),
      PaymentMethod(
        userId: userId,
        methodId: 'paypal_1',
        type: PaymentMethodType.paypal,
        displayName: 'PayPal Account',
        accountHolderName: 'John Doe',
      ),
    ];

    for (final method in demoMethods) {
      await addPaymentMethod(method);
    }

    // Add some demo transactions
    await addMoney(userId: userId, amount: 100.0, paymentMethodId: 'card_1', description: 'Initial wallet top-up');
    await Future.delayed(Duration(milliseconds: 100));
    
    await makePayment(userId: userId, amount: 25.0, description: 'Ride payment to downtown', referenceId: 'ride_001');
    await Future.delayed(Duration(milliseconds: 100));
    
    await addEarning(userId: userId, amount: 30.0, description: 'Earning from ride sharing', referenceId: 'ride_002');
    await Future.delayed(Duration(milliseconds: 100));
    
    await addMoney(userId: userId, amount: 50.0, paymentMethodId: 'paypal_1', description: 'Wallet top-up via PayPal');
  }
}
