import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/bloc/wallet/wallet_bloc.dart';
import 'package:mpitana/bloc/wallet/wallet_event.dart';
import 'package:mpitana/bloc/wallet/wallet_state.dart';
import 'package:mpitana/screens/wallet/widgets/balance_card.dart';
import 'package:mpitana/screens/wallet/widgets/transaction_card.dart';
import 'package:mpitana/screens/wallet/widgets/add_money_dialog.dart';
import 'package:mpitana/screens/wallet/transaction_history_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final String _currentUserId = 'user123'; // TODO: Get from auth service
  
  @override
  void initState() {
    super.initState();
    // Load wallet data when screen initializes
    context.read<WalletBloc>().add(LoadWalletEvent(userId: _currentUserId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<WalletBloc>().add(RefreshWalletEvent(userId: _currentUserId));
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'statements',
                child: ListTile(
                  leading: Icon(Icons.receipt_long),
                  title: Text('Statements'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('Help & Support'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is WalletMoneyAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is WalletInsufficientFunds) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'Add Money',
                  onPressed: _showAddMoneyDialog,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state is WalletError && state.balance == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load wallet',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<WalletBloc>().add(LoadWalletEvent(userId: _currentUserId));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          // Extract balance and transactions from various states
          final balance = _getBalanceFromState(state);
          final transactions = _getTransactionsFromState(state);
          final isTransactionLoading = state is WalletTransactionLoading;
          
          if (balance == null) {
            return const Center(
              child: Text('No wallet data available'),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              context.read<WalletBloc>().add(RefreshWalletEvent(userId: _currentUserId));
            },
            child: CustomScrollView(
              slivers: [
                // Balance Card
                SliverToBoxAdapter(
                  child: BalanceCard(
                    balance: balance,
                    onAddMoney: _showAddMoneyDialog,
                    isLoading: isTransactionLoading,
                  ),
                ),
                
                // Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.send,
                            label: 'Send Money',
                            onTap: () {
                              // TODO: Implement send money
                              _showComingSoonDialog('Send Money');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.qr_code_scanner,
                            label: 'Scan & Pay',
                            onTap: () {
                              // TODO: Implement QR code scanner
                              _showComingSoonDialog('Scan & Pay');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.receipt_long,
                            label: 'Bills',
                            onTap: () {
                              // TODO: Implement bill payments
                              _showComingSoonDialog('Bill Payments');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                
                // Transaction History Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Recent Transactions',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TransactionHistoryScreen(
                                  userId: _currentUserId,
                                  initialTransactions: transactions,
                                ),
                              ),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Transaction List
                if (transactions.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your transaction history will appear here',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final recentTransactions = transactions.take(3).toList();
                        if (index < recentTransactions.length) {
                          final transaction = recentTransactions[index];
                          return TransactionCard(
                            transaction: transaction,
                            onTap: () => _showTransactionDetails(transaction),
                          );
                        } else {
                          // Show "View More" card if there are more transactions
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => TransactionHistoryScreen(
                                      userId: _currentUserId,
                                      initialTransactions: transactions,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.expand_more,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'View ${transactions.length - 3} more transactions',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      childCount: transactions.length > 3 ? 4 : transactions.length,
                    ),
                  ),
                
                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }
  
  dynamic _getBalanceFromState(WalletState state) {
    if (state is WalletLoaded) return state.balance;
    if (state is WalletTransactionLoading) return state.balance;
    if (state is WalletMoneyAdded) return state.balance;
    if (state is WalletMoneyDeducted) return state.balance;
    if (state is WalletMoneyRefunded) return state.balance;
    if (state is WalletMoneyHeld) return state.balance;
    if (state is WalletMoneyReleased) return state.balance;
    if (state is WalletInsufficientFunds) return state.balance;
    if (state is WalletError) return state.balance;
    return null;
  }
  
  List<dynamic> _getTransactionsFromState(WalletState state) {
    if (state is WalletLoaded) return state.transactions;
    if (state is WalletTransactionLoading) return state.transactions;
    if (state is WalletMoneyAdded) return state.transactions;
    if (state is WalletMoneyDeducted) return state.transactions;
    if (state is WalletMoneyRefunded) return state.transactions;
    if (state is WalletMoneyHeld) return state.transactions;
    if (state is WalletMoneyReleased) return state.transactions;
    if (state is WalletInsufficientFunds) return state.transactions;
    if (state is WalletError) return state.transactions ?? [];
    return [];
  }
  
  void _showAddMoneyDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMoneyDialog(
        onAddMoney: (amount, paymentMethod) async {
          context.read<WalletBloc>().add(AddMoneyEvent(
            userId: _currentUserId,
            amount: amount,
            paymentMethod: paymentMethod,
          ));
        },
      ),
    );
  }
  
  void _showTransactionDetails(dynamic transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow('Amount', transaction.formattedAmount),
            _DetailRow('Type', transaction.type.toUpperCase()),
            _DetailRow('Status', transaction.status.toUpperCase()),
            _DetailRow('Date', transaction.createdAt.toString()),
            if (transaction.reference != null)
              _DetailRow('Reference', transaction.reference!),
            if (transaction.paymentMethod != null)
              _DetailRow('Payment Method', transaction.paymentMethod!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'statements':
        _showComingSoonDialog('Statements');
        break;
      case 'help':
        _showComingSoonDialog('Help & Support');
        break;
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
