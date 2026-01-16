import 'package:flutter/material.dart';
import 'package:app_rtsg_client/core/theme/app_colors.dart';

class HomeDrawerButton extends StatelessWidget {
  const HomeDrawerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: AppColors.shadow,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Scaffold.of(context).openDrawer(),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.menu, size: 22, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
