import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_rtsg_client/core/theme/app_colors.dart';
import 'package:app_rtsg_client/data/models/partnert_model.dart';

class PartnerDetailPage extends StatelessWidget {
  const PartnerDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = _PartnerDetailData.from(Get.arguments);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 285,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    data.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.inputFill,
                      child: const Icon(
                        Icons.storefront_outlined,
                        size: 70,
                        color: AppColors.brandGreen,
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x99000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          data.category,
                          style: const TextStyle(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandGreen.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: AppColors.brandGreen,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Partner verificado',
                            style: TextStyle(
                              color: AppColors.brandGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.taxiYellow,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.rating,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'Lo que ofrece',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.taxiYellow.withValues(alpha: 0.24),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.local_offer_outlined,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Beneficio RTSG',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.offer,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const _BenefitLine(
                  icon: Icons.card_membership_outlined,
                  text: 'Muestra tu cuenta RTSG al momento de pagar.',
                ),
                const _BenefitLine(
                  icon: Icons.schedule_outlined,
                  text: 'Beneficio sujeto a disponibilidad del establecimiento.',
                ),
                const _BenefitLine(
                  icon: Icons.workspace_premium_outlined,
                  text: 'Promoción exclusiva para usuarios activos de RTSG.',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'Beneficio activado',
                        'Este flujo es de demostración. Más adelante se conectará al backend del partner.',
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    icon: const Icon(Icons.redeem_rounded),
                    label: const Text('Usar beneficio'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandGreen,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitLine extends StatelessWidget {
  const _BenefitLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.brandGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerDetailData {
  const _PartnerDetailData({
    required this.name,
    required this.category,
    required this.description,
    required this.offer,
    required this.imageUrl,
    required this.rating,
  });

  final String name;
  final String category;
  final String description;
  final String offer;
  final String imageUrl;
  final String rating;

  factory _PartnerDetailData.from(dynamic source) {
    if (source is PartnerAdModel) {
      return _PartnerDetailData(
        name: source.partnerName,
        category: 'Beneficio destacado',
        description: source.description,
        offer: source.title,
        imageUrl: source.imageUrl,
        rating: '4.9',
      );
    }

    if (source is PartnerModel) {
      final offer = switch (source.category.toLowerCase()) {
        'cafetería' => '15% de descuento en bebidas seleccionadas',
        'supermercado' => '5% de descuento en compras desde $20',
        'restaurante' => 'Postre de cortesía en consumos desde $25',
        _ => 'Beneficio exclusivo para usuarios RTSG',
      };

      return _PartnerDetailData(
        name: source.name,
        category: source.category,
        description:
            '${source.name} forma parte de la red de aliados RTSG. Aquí podrás encontrar promociones, beneficios y experiencias exclusivas asociadas a tu cuenta.',
        offer: offer,
        imageUrl: source.logoUrl,
        rating: source.rating.toStringAsFixed(1),
      );
    }

    return const _PartnerDetailData(
      name: 'Partner RTSG',
      category: 'Aliado',
      description:
          'Conoce los beneficios disponibles para usuarios RTSG en este establecimiento aliado.',
      offer: 'Beneficio exclusivo RTSG',
      imageUrl: '',
      rating: '4.8',
    );
  }
}
