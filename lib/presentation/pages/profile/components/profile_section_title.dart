import 'package:flutter/material.dart';

class ProfileSectionTitle extends StatelessWidget {
  final IconData icon;
  final Function? onPress;
  final String title;

  const ProfileSectionTitle({
    super.key,
    required this.icon,
    required this.title,
    this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, color: cs.secondary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
        ),
        Expanded(child: const SizedBox(width: 8)),

        if (onPress != null) Icon(Icons.edit, color: cs.secondary, size: 18),
      ],
    );
  }
}
