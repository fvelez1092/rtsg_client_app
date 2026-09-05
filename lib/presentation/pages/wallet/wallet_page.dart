import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/presentation/widgets/main_bottom_navigation.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double _balance = 18.50;
  double _selectedAmount = 10;
  String _paymentMethod = 'Tarjeta •••• 4242';

  final _amounts = const [5.0, 10.0, 20.0, 50.0];

  void _topUp() {
    setState(() => _balance += _selectedAmount);

    Get.snackbar(
      'Recarga simulada',
      'Se añadieron \$${_selectedAmount.toStringAsFixed(2)} a tu saldo virtual.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          children: [
            Text(
              'Billetera',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Consulta tu consumo y administra saldo virtual para futuros servicios.',
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.brandGreen,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.surface,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Saldo RTSG',
                        style: TextStyle(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '\$${_balance.toStringAsFixed(2)}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Saldo virtual disponible',
                    style: TextStyle(color: Color(0xD9FFFFFF)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.directions_car_rounded,
                    value: '12',
                    label: 'Viajes realizados',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.payments_outlined,
                    value: r'$86.35',
                    label: 'Costo acumulado',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'Recargar saldo',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Modo demostración: las recargas solo modifican el saldo en esta vista.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _amounts.map((amount) {
                final selected = amount == _selectedAmount;

                return ChoiceChip(
                  selected: selected,
                  label: Text('\$${amount.toStringAsFixed(0)}'),
                  onSelected: (_) => setState(() => _selectedAmount = amount),
                  selectedColor: AppColors.brandGreen.withValues(alpha: 0.14),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: selected
                        ? AppColors.brandGreen
                        : AppColors.borderSoft,
                  ),
                  labelStyle: TextStyle(
                    color: selected
                        ? AppColors.brandGreen
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _paymentMethod,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: const [
                    DropdownMenuItem(
                      value: 'Tarjeta •••• 4242',
                      child: Row(
                        children: [
                          Icon(Icons.credit_card_rounded),
                          SizedBox(width: 10),
                          Text('Tarjeta •••• 4242'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Transferencia bancaria',
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_outlined),
                          SizedBox(width: 10),
                          Text('Transferencia bancaria'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _paymentMethod = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _topUp,
                icon: const Icon(Icons.add_card_rounded),
                label: Text(
                  'Recargar \$${_selectedAmount.toStringAsFixed(2)}',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  foregroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Text(
              'Últimos movimientos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const _Movement(
              icon: Icons.directions_car_rounded,
              title: 'Viaje · Centro Histórico',
              subtitle: 'Hoy · 09:42',
              amount: r'-$4.80',
            ),
            const _Movement(
              icon: Icons.add_circle_outline_rounded,
              title: 'Recarga de saldo',
              subtitle: '2 sep · 16:10',
              amount: r'+$20.00',
              positive: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.brandGreen),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _Movement extends StatelessWidget {
  const _Movement({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.positive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (positive ? AppColors.brandGreen : AppColors.brandRed)
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: positive ? AppColors.brandGreen : AppColors.brandRed,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: positive ? AppColors.brandGreen : AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
