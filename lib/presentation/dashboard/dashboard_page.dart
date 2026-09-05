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

  static const double _navigationHeight = 64;
  static const double _collapsedSize = 58;
  static const double _navigationBottomGap = 8;
  static const double _contentGap = 10;
  static const double _navigationHorizontalMargin = 24;
  static const double _navigationMaxWidth = 390;

  IconData _selectedTabIcon(int index) {
    return switch (index) {
      0 => Icons.home_rounded,
      1 => Icons.receipt_long_rounded,
      2 => Icons.account_balance_wallet_rounded,
      _ => Icons.person_rounded,
    };
  }

  Widget _fullNavigation(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: _navigationHeight,
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: colors.primary.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return theme.textTheme.labelSmall?.copyWith(
            fontSize: 11,
            color: selected
                ? colors.primary
                : colors.onSurface.withValues(alpha: 0.58),
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: selected ? 24 : 22,
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
    );
  }

  Widget _collapsedNavigation(ColorScheme colors) {
    return Semantics(
      button: true,
      label: 'Mostrar navegación',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.showNavigation,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              _selectedTabIcon(controller.selectedIndex.value),
              size: 29,
              color: colors.primary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bottomSafeArea = MediaQuery.viewPaddingOf(context).bottom;

    return Obx(() {
      final navigationVisible = controller.isNavigationVisible.value;

      // Incluso colapsada dejamos espacio para el botón circular flotante.
      final contentBottomInset = navigationVisible
          ? _navigationHeight +
                _navigationBottomGap +
                bottomSafeArea +
                _contentGap
          : _collapsedSize +
                _navigationBottomGap +
                bottomSafeArea +
                4;

      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        extendBody: true,
        body: AnimatedPadding(
          duration: const Duration(milliseconds: 210),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(bottom: contentBottomInset),
          child: IndexedStack(
            index: controller.selectedIndex.value,
            children: [
              PrimaryScrollController(
                controller: controller.tabScrollControllers[0],
                child: const HomePage(),
              ),
              PrimaryScrollController(
                controller: controller.tabScrollControllers[1],
                child: const ActivityPage(),
              ),
              PrimaryScrollController(
                controller: controller.tabScrollControllers[2],
                child: const WalletPage(),
              ),
              PrimaryScrollController(
                controller: controller.tabScrollControllers[3],
                child: const AccountPage(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(
            _navigationHorizontalMargin,
            0,
            _navigationHorizontalMargin,
            _navigationBottomGap,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: navigationVisible
                ? Alignment.bottomCenter
                : Alignment.bottomLeft,
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _navigationMaxWidth),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                width: navigationVisible ? double.infinity : _collapsedSize,
                height: navigationVisible
                    ? _navigationHeight
                    : _collapsedSize,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(
                    alpha: navigationVisible ? 0.84 : 0.90,
                  ),
                  borderRadius: BorderRadius.circular(
                    navigationVisible ? 27 : _collapsedSize / 2,
                  ),
                  border: Border.all(
                    color: colors.onSurface.withValues(alpha: 0.055),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.scrim.withValues(alpha: 0.14),
                      blurRadius: navigationVisible ? 20 : 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 170),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: navigationVisible
                        ? KeyedSubtree(
                            key: const ValueKey('full-navigation'),
                            child: _fullNavigation(context, theme, colors),
                          )
                        : KeyedSubtree(
                            key: const ValueKey('collapsed-navigation'),
                            child: _collapsedNavigation(colors),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
