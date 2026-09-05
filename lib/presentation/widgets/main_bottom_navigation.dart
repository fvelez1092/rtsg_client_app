import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_rtsg_client/routes/rtsg_routes.dart';

class MainBottomNavigation extends StatelessWidget {
  const MainBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  bool get _isInsideDashboardShell {
    return const {
      AppRoutes.DASHBOARD,
      AppRoutes.HOME,
      AppRoutes.ACTIVITY,
      AppRoutes.WALLET,
      AppRoutes.ACCOUNT,
    }.contains(Get.currentRoute);
  }

  @override
  Widget build(BuildContext context) {
    // Las páginas principales se renderizan dentro de DashboardPage.
    // Ahí la única navegación visible debe ser la barra flotante del shell.
    if (_isInsideDashboardShell) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primary.withOpacity(0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);

          return theme.textTheme.labelSmall?.copyWith(
            color: selected
                ? colors.primary
                : colors.onSurface.withOpacity(0.60),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);

          return IconThemeData(
            color: selected
                ? colors.primary
                : colors.onSurface.withOpacity(0.60),
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index == currentIndex) return;
          Get.offAllNamed(AppRoutes.DASHBOARD, arguments: {'tab': index});
        },
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
    );
  }
}
