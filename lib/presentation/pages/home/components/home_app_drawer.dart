import 'package:flutter/material.dart';

class HomeAppDrawer extends StatelessWidget {
  const HomeAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ListTile(title: Text('Menú')),
            ListTile(
              title: Row(
                children: [
                  Image.asset(
                    'assets/images/avatar.png',
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(width: 20),
                  Text(
                    ' Fernando ',
                    style: TextStyle(color: Colors.black, fontSize: 25),
                  ),
                  Expanded(child: SizedBox()),
                  Icon(Icons.edit),
                ],
              ),
            ),
            Divider(height: 1),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Perfil', style: TextStyle(color: Colors.black)),
            ),
            ListTile(
              leading: Icon(Icons.notification_important_outlined),
              title: Text(
                'Notificaciones',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Historial', style: TextStyle(color: Colors.black)),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Configuración',
                style: TextStyle(color: Colors.black),
              ),
            ),
            Divider(height: 1),
          ],
        ),
      ),
    );
  }
}
