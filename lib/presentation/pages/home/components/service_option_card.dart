import 'package:flutter/material.dart';

class ServiceOptionCard extends StatelessWidget {
  const ServiceOptionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isHighlighted = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final backgroundColor = isHighlighted ? colors.primary : colors.surface;

    final foregroundColor = isHighlighted ? colors.onPrimary : colors.onSurface;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isHighlighted
                  ? Colors.transparent
                  : colors.onSurface.withOpacity(0.10),
            ),
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: colors.primary.withOpacity(0.20),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 29, color: foregroundColor),
              const SizedBox(height: 9),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
