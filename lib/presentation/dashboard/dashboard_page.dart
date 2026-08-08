import 'package:app_rtsg_client/application/dashboard_controller.dart';
import 'package:app_rtsg_client/presentation/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Obx(
      () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,

        // Permite que el contenido continúe detrás de la barra flotante.
        extendBody: true,

        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: const [
            HomePage(),
            _ActivityPlaceholder(),
            _WalletPlaceholder(),
            _ProfilePlaceholder(),
          ],
        ),

        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: colors.onSurface.withOpacity(0.06)),
              boxShadow: [
                BoxShadow(
                  color: colors.scrim.withOpacity(0.18),
                  blurRadius: 24,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                height: 72,
                backgroundColor: colors.surface,
                elevation: 0,

                indicatorColor: colors.primary.withOpacity(0.15),

                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final isSelected = states.contains(WidgetState.selected);

                  return theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? colors.primary
                        : colors.onSurface.withOpacity(0.55),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  );
                }),

                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final isSelected = states.contains(WidgetState.selected);

                  return IconThemeData(
                    size: isSelected ? 26 : 24,
                    color: isSelected
                        ? colors.primary
                        : colors.onSurface.withOpacity(0.55),
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: controller.changePage,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Inicio',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    selectedIcon: Icon(Icons.receipt_long_rounded),
                    label: 'Actividad',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                    label: 'Billetera',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Cuenta',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityPlaceholder extends StatelessWidget {
  const _ActivityPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Actividad'));
  }
}

class _WalletPlaceholder extends StatelessWidget {
  const _WalletPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Billetera'));
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Cuenta'));
  }
}
