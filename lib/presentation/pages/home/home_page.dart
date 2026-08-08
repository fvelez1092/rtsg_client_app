import 'package:app_rtsg_client/application/home_controller.dart';
import 'package:app_rtsg_client/data/models/partnert_model.dart';
import 'package:app_rtsg_client/presentation/pages/home/components/partner_add_card.dart';
import 'package:app_rtsg_client/presentation/pages/home/components/service_option_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.advertisements.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          if (controller.hasError.value && controller.advertisements.isEmpty) {
            return _HomeError(onRetry: controller.loadHome);
          }

          return RefreshIndicator(
            color: colors.primary,
            backgroundColor: colors.surface,
            onRefresh: controller.loadHome,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverToBoxAdapter(child: _buildDestinationCard(context)),
                SliverToBoxAdapter(child: _buildServiceOptions(context)),
                SliverToBoxAdapter(child: _buildAdvertisementSection(context)),
                SliverToBoxAdapter(child: _buildPartnersSection(context)),
                SliverToBoxAdapter(child: _buildRecentActivity(context)),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buenos días',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withOpacity(0.60),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '¿A dónde vamos?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: colors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () {
                // Get.toNamed(AppRoutes.profile);
              },
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: colors.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          onTap: () {
            // Get.toNamed(AppRoutes.locationSearch);
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.onSurface.withOpacity(0.10)),
              boxShadow: [
                BoxShadow(
                  color: colors.scrim.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: colors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    'Ingresa tu destino',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: colors.onSurface.withOpacity(0.50),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.82,
        children: [
          ServiceOptionCard(
            title: 'Viaje',
            icon: Icons.directions_car_filled_rounded,
            isHighlighted: true,
            onTap: () {
              // Get.toNamed(AppRoutes.trip);
            },
          ),
          ServiceOptionCard(
            title: 'Reserva',
            icon: Icons.calendar_month_rounded,
            onTap: () {
              // Get.toNamed(AppRoutes.reservation);
            },
          ),
          ServiceOptionCard(
            title: 'Envíos',
            icon: Icons.inventory_2_outlined,
            onTap: () {
              // Get.toNamed(AppRoutes.delivery);
            },
          ),
          ServiceOptionCard(
            title: 'Partners',
            icon: Icons.storefront_outlined,
            onTap: () {
              // Get.toNamed(AppRoutes.partners);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertisementSection(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (controller.advertisements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 37,
                  height: 37,
                  decoration: BoxDecoration(
                    color: colors.tertiary.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    Icons.local_offer_outlined,
                    color: colors.onTertiary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Beneficios para ti',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 225,
            child: PageView.builder(
              controller: controller.advertisementsPageController,
              itemCount: controller.advertisements.length,
              onPageChanged: controller.changeAdvertisement,
              itemBuilder: (context, index) {
                final advertisement = controller.advertisements[index];

                return PartnerAdCard(
                  advertisement: advertisement,
                  onTap: () {
                    // Abrir detalle, WebView o enlace externo.
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 13),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(controller.advertisements.length, (
                index,
              ) {
                final isSelected =
                    controller.selectedAdvertisementIndex.value == index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isSelected ? 23 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary
                        : colors.onSurface.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnersSection(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (controller.partners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Partners RTSG',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Get.toNamed(AppRoutes.partners);
                  },
                  child: const Text('Ver todos'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 190,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: controller.partners.length,
              separatorBuilder: (_, __) {
                return const SizedBox(width: 12);
              },
              itemBuilder: (context, index) {
                final partner = controller.partners[index];

                return _PartnerCard(
                  partner: partner,
                  onTap: () {
                    // Get.toNamed(
                    //   AppRoutes.partnerDetail,
                    //   arguments: partner,
                    // );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad reciente',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {
                // Get.toNamed(AppRoutes.activity);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.onSurface.withOpacity(0.10)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 53,
                      height: 53,
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(Icons.history_rounded, color: colors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Todavía no tienes viajes recientes',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tus últimos servicios aparecerán aquí.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurface.withOpacity(0.58),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: colors.onSurface.withOpacity(0.45),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Obx(
      () => NavigationBarTheme(
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
          selectedIndex: controller.selectedBottomIndex.value,
          onDestinationSelected: (index) {
            controller.changeBottomIndex(index);

            switch (index) {
              case 0:
                break;
              case 1:
                // Get.toNamed(AppRoutes.activity);
                break;
              case 2:
                // Get.toNamed(AppRoutes.wallet);
                break;
              case 3:
                // Get.toNamed(AppRoutes.profile);
                break;
            }
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
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.partner, required this.onTap});

  final PartnerModel partner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 115,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.onSurface.withOpacity(0.08)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  partner.logoUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Center(
                      child: Icon(
                        Icons.storefront_outlined,
                        color: colors.primary,
                        size: 35,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 9),
              Text(
                partner.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      partner.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withOpacity(0.58),
                      ),
                    ),
                  ),
                  Icon(Icons.star_rounded, size: 15, color: colors.tertiary),
                  const SizedBox(width: 2),
                  Text(
                    partner.rating.toStringAsFixed(1),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
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
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: colors.secondary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 38,
                color: colors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No pudimos cargar el inicio',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verifica tu conexión e inténtalo nuevamente.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.60),
              ),
            ),
            const SizedBox(height: 21),
            FilledButton.icon(
              onPressed: () {
                onRetry();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
