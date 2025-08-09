import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddMoneyDialog extends StatefulWidget {
  final Function(double amount, String paymentMethod) onAddMoney;

  const AddMoneyDialog({
    super.key,
    required this.onAddMoney,
  });

  @override
  State<AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<AddMoneyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedPaymentMethod = 'card';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'value': 'card',
      'label': 'Credit/Debit Card',
      'icon': Icons.credit_card,
    },
    {
      'value': 'bank_transfer',
      'label': 'Bank Transfer',
      'icon': Icons.account_balance,
    },
    {
      'value': 'mobile_money',
      'label': 'Mobile Money',
      'icon': Icons.phone_android,
    },
  ];

  final List<double> _quickAmounts = [5000.0, 10000.0, 25000.0, 50000.0];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.add_circle,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add Money',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Amount Input
              Text(
                'Enter Amount',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: 'BIF ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount < 1000) {
                    return 'Minimum amount is BIF 1,000';
                  }
                  if (amount > 1000000) {
                    return 'Maximum amount is BIF 1,000,000';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Quick Amount Buttons
              Text(
                'Quick Add',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _quickAmounts.map((amount) {
                  return ActionChip(
                    label: Text('BIF ${amount.toStringAsFixed(0)}'),
                    onPressed: () {
                      _amountController.text = amount.toStringAsFixed(0);
                    },
                    backgroundColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Payment Method Selection
              Text(
                'Payment Method',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: _paymentMethods.map((method) {
                  return RadioListTile<String>(
                    value: method['value'],
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value!;
                      });
                    },
                    title: Text(method['label']),
                    secondary: Icon(method['icon']),
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleAddMoney,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add Money'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddMoney() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      await widget.onAddMoney(amount, _selectedPaymentMethod);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully added BIF ${amount.toStringAsFixed(0)} to your wallet'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add money: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
