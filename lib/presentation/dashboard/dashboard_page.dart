import 'dart:ui' as ui;

import 'package:app_rtsg_client/application/dashboard_controller.dart';
import 'package:app_rtsg_client/presentation/pages/account/account_page.dart';
import 'package:app_rtsg_client/presentation/pages/activity/activity_page.dart';
import 'package:app_rtsg_client/presentation/pages/home/home_page.dart';
import 'package:app_rtsg_client/presentation/pages/wallet/wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  static const double _navigationHeight = 70;
  static const double _navigationBottomGap = 10;
  static const double _contentGap = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bottomSafeArea = MediaQuery.viewPaddingOf(context).bottom;

    // Aunque la barra siga siendo flotante, el contenido útil termina antes de
    // ella. Esto evita que botones, cards o el final de un scroll queden ocultos.
    final contentBottomInset =
        _navigationHeight + _navigationBottomGap + bottomSafeArea + _contentGap;

    return Obx(
      () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        extendBody: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: contentBottomInset),
              child: IndexedStack(
                index: controller.selectedIndex.value,
                children: const [
                  HomePage(),
                  ActivityPage(),
                  WalletPage(),
                  AccountPage(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(
            14,
            0,
            14,
            _navigationBottomGap,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.84),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: colors.onSurface.withValues(alpha: 0.055),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.scrim.withValues(alpha: 0.14),
                      blurRadius: 22,
                      spreadRadius: 0,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: NavigationBarTheme(
                  data: NavigationBarThemeData(
                    height: _navigationHeight,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    indicatorColor: colors.primary.withValues(alpha: 0.12),
                    indicatorShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    labelTextStyle: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return theme.textTheme.labelSmall?.copyWith(
                        color: selected
                            ? colors.primary
                            : colors.onSurface.withValues(alpha: 0.58),
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w500,
                      );
                    }),
                    iconTheme: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return IconThemeData(
                        size: selected ? 26 : 24,
                        color: selected
                            ? colors.primary
                            : colors.onSurface.withValues(alpha: 0.58),
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
        ),
      ),
    );
  }
}
