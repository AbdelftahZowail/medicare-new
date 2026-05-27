import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../clinic/clinic_service.dart';

class ClinicPaymentsScreen extends StatefulWidget {
  const ClinicPaymentsScreen({super.key});

  @override
  State<ClinicPaymentsScreen> createState() => _ClinicPaymentsScreenState();
}

class _ClinicPaymentsScreenState extends State<ClinicPaymentsScreen> {
  final _service = ClinicService();
  Map<String, dynamic>? _paymentsData;
  bool _isLoading = true;
  String? _error;
  String _timeframe = 'today'; // today, week, month

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final data = await _service.getClinicPayments(_timeframe);
      setState(() {
        _paymentsData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onTimeframeChanged(String timeframe) {
    setState(() => _timeframe = timeframe);
    _loadPayments();
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.clinicDashboard);
        break;
      case 1:
        context.go(AppRoutes.clinicDoctors);
        break;
      case 2:
        context.go(AppRoutes.clinicPayments);
        break;
      case 3:
        context.go(AppRoutes.clinicProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _paymentsData?['summary'] as Map<String, dynamic>? ?? {};
    final transactions = (_paymentsData?['transactions'] as List<dynamic>?) ?? [];

    final totalRevenue = (summary['totalRevenue'] as num?)?.toDouble() ?? 0.0;
    final cashRevenue = (summary['cashRevenue'] as num?)?.toDouble() ?? 0.0;
    final onlineRevenue = (summary['onlineRevenue'] as num?)?.toDouble() ?? 0.0;
    final refunds = (summary['totalRefunds'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payments Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPayments,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : RefreshIndicator(
                    onRefresh: _loadPayments,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTimeframeSelector(),
                          const SizedBox(height: 20),
                          _buildRevenueCard(totalRevenue),
                          const SizedBox(height: 20),
                          _buildBreakdownCards(cashRevenue, onlineRevenue, refunds),
                          const SizedBox(height: 24),
                          Text('Recent Transactions', style: AppTextStyles.heading2),
                          const SizedBox(height: 12),
                          if (transactions.isEmpty)
                            _buildEmptyTransactions()
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: transactions.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final tx = transactions[index] as Map<String, dynamic>;
                                return _TransactionCard(transaction: tx);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        items: ClinicNavItems.items,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Failed to load payments',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadPayments,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    final options = [
      {'value': 'today', 'label': 'Today'},
      {'value': 'week', 'label': 'This Week'},
      {'value': 'month', 'label': 'This Month'},
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = _timeframe == opt['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () => _onTimeframeChanged(opt['value']!),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  opt['label']!,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRevenueCard(double totalRevenue) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet, color: AppColors.textOnPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Revenue',
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary100),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${totalRevenue.toStringAsFixed(2)}',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: AppColors.textOnPrimary,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCards(double cash, double online, double refunds) {
    return Row(
      children: [
        Expanded(
          child: _BreakdownCard(
            icon: Icons.money,
            label: 'Cash',
            value: '\$${cash.toStringAsFixed(2)}',
            iconColor: AppColors.success,
            iconBg: AppColors.successBg,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BreakdownCard(
            icon: Icons.credit_card,
            label: 'Online',
            value: '\$${online.toStringAsFixed(2)}',
            iconColor: AppColors.primary,
            iconBg: AppColors.primary100,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BreakdownCard(
            icon: Icons.undo,
            label: 'Refunds',
            value: '\$${refunds.toStringAsFixed(2)}',
            iconColor: AppColors.error,
            iconBg: AppColors.errorBg,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 48, color: AppColors.textTertiary.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(
              'No transactions yet',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBg;

  const _BreakdownCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final patientName = transaction['patientName'] ?? '';
    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
    final isRefund = transaction['isRefund'] ?? false;
    final paymentMethod = transaction['paymentMethodText'] ?? '';
    final date = transaction['createdAt'] ?? '';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: isRefund ? AppColors.errorBg : AppColors.successBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isRefund ? Icons.undo : Icons.check_circle,
              color: isRefund ? AppColors.error : AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '$paymentMethod · $date',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${isRefund ? '-' : '+'}\$${amount.abs().toStringAsFixed(2)}',
            style: AppTextStyles.labelLarge.copyWith(
              color: isRefund ? AppColors.error : AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
