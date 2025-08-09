import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/bloc/wallet/wallet_bloc.dart';
import 'package:mpitana/bloc/wallet/wallet_event.dart';
import 'package:mpitana/bloc/wallet/wallet_state.dart';
import 'package:mpitana/screens/wallet/widgets/transaction_card.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String userId;
  final List<dynamic> initialTransactions;

  const TransactionHistoryScreen({
    super.key,
    required this.userId,
    required this.initialTransactions,
  });

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'all';
  final List<String> _filterOptions = ['all', 'credit', 'debit', 'pending', 'completed'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<WalletBloc>().add(RefreshWalletEvent(userId: widget.userId));
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
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
          }
        },
        builder: (context, state) {
          final transactions = _getTransactionsFromState(state) ?? widget.initialTransactions;
          final filteredTransactions = _filterTransactions(transactions);
          final isLoading = state is WalletLoading || state is WalletTransactionLoading;

          return Column(
            children: [
              // Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter by:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filterOptions.map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(_getFilterLabel(filter)),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                              checkmarkColor: theme.colorScheme.primary,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Transaction Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${filteredTransactions.length} transaction${filteredTransactions.length != 1 ? 's' : ''}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if (isLoading) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Transaction List
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
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
                              _selectedFilter == 'all' 
                                  ? 'No transactions yet'
                                  : 'No ${_getFilterLabel(_selectedFilter).toLowerCase()} transactions',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedFilter == 'all'
                                  ? 'Your transaction history will appear here'
                                  : 'Try selecting a different filter',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          context.read<WalletBloc>().add(RefreshWalletEvent(userId: widget.userId));
                        },
                        child: ListView.builder(
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = filteredTransactions[index];
                            return TransactionCard(
                              transaction: transaction,
                              onTap: () => _showTransactionDetails(transaction),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<dynamic>? _getTransactionsFromState(WalletState state) {
    if (state is WalletLoaded) return state.transactions;
    if (state is WalletTransactionLoading) return state.transactions;
    if (state is WalletMoneyAdded) return state.transactions;
    if (state is WalletMoneyDeducted) return state.transactions;
    if (state is WalletMoneyRefunded) return state.transactions;
    if (state is WalletMoneyHeld) return state.transactions;
    if (state is WalletMoneyReleased) return state.transactions;
    if (state is WalletInsufficientFunds) return state.transactions;
    if (state is WalletError) return state.transactions;
    return null;
  }

  List<dynamic> _filterTransactions(List<dynamic> transactions) {
    if (_selectedFilter == 'all') {
      return transactions;
    }

    return transactions.where((transaction) {
      switch (_selectedFilter) {
        case 'credit':
          return transaction.isCredit;
        case 'debit':
          return !transaction.isCredit;
        case 'pending':
          return transaction.status.toLowerCase() == 'pending';
        case 'completed':
          return transaction.status.toLowerCase() == 'completed';
        default:
          return true;
      }
    }).toList();
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'All';
      case 'credit':
        return 'Credits';
      case 'debit':
        return 'Debits';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      default:
        return filter;
    }
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
