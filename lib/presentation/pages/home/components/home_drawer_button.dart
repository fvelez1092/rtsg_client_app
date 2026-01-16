import 'package:flutter/material.dart';

class HomeDrawerButton extends StatelessWidget {
  const HomeDrawerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Material(
        //color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Scaffold.of(context).openDrawer(),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.menu, size: 22),
          ),
        ),
      ),
    );
  }
}
