import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpitana/bloc/wallet/wallet_bloc.dart';
import 'package:mpitana/bloc/wallet/wallet_event.dart';
import 'package:mpitana/bloc/wallet/wallet_state.dart';
import 'package:mpitana/screens/wallet/widgets/wallet_balance_card.dart';
import 'package:mpitana/screens/wallet/widgets/quick_actions_widget.dart';
import 'package:mpitana/screens/wallet/widgets/recent_transactions_widget.dart';
import 'package:mpitana/screens/wallet/widgets/wallet_stats_widget.dart';
import 'package:mpitana/screens/wallet/add_money_screen.dart';
import 'package:mpitana/screens/wallet/transactions_screen.dart';
import 'package:mpitana/screens/wallet/payment_methods_screen.dart';

class WalletScreen extends StatefulWidget {
  final String userId;

  const WalletScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(LoadWallet(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<WalletBloc>().add(RefreshWallet(widget.userId));
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'My Wallet',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.history,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionsScreen(userId: widget.userId),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.credit_card,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentMethodsScreen(userId: widget.userId),
                      ),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onSelected: (value) {
                    if (value == 'demo') {
                      context.read<WalletBloc>().add(CreateDemoData(widget.userId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demo data created!')),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'demo',
                      child: Text('Create Demo Data'),
                    ),
                  ],
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: BlocConsumer<WalletBloc, WalletState>(
                listener: (context, state) {
                  if (state is WalletError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  } else if (state is MoneyAddedSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Money added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is WalletLoading) {
                    return Container(
                      height: 400,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  }

                  if (state is WalletLoaded) {
                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Balance Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: WalletBalanceCard(
                            wallet: state.wallet,
                            onAddMoney: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddMoneyScreen(userId: widget.userId),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Quick Actions
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: QuickActionsWidget(
                            userId: widget.userId,
                            onAddMoney: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddMoneyScreen(userId: widget.userId),
                                ),
                              );
                            },
                            onViewTransactions: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransactionsScreen(userId: widget.userId),
                                ),
                              );
                            },
                            onPaymentMethods: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentMethodsScreen(userId: widget.userId),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Wallet Stats
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: WalletStatsWidget(stats: state.stats),
                        ),

                        const SizedBox(height: 20),

                        // Recent Transactions
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: RecentTransactionsWidget(
                            userId: widget.userId,
                            onViewAll: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransactionsScreen(userId: widget.userId),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 100), // Bottom padding
                      ],
                    );
                  }

                  return Container(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Welcome to your wallet!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the menu to create demo data',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
