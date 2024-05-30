// flutter
import 'package:flutter/material.dart';
import 'package:tigerbook/view/feed.dart';
import 'package:tigerbook/view/saved.dart';

import '../controller/login_controller.dart';
import 'my_profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TigerBook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _displayBody(),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _handleDestinationSelected,
        selectedIndex: _selectedIndex,
        destinations: _destinations(),
      ),
    );
  }

  Widget _displayBody() {
    switch (_selectedIndex) {
      case 0:
        return const Feed();
      case 1:
        return const Saved();
      case 2:
        return const MyProfile();
      default:
        return const Feed();
    }
  }

  void _handleDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<NavigationDestination> _destinations() {
    return const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Inicio',
      ),
      NavigationDestination(
        icon: Icon(Icons.save_outlined),
        selectedIcon: Icon(Icons.save),
        label: 'Guardados',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ];
  }

  void _handleLogout() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () async {
                  await LoginController.cerrarSesion().then(
                    (value) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/welcome',
                        (Route<dynamic> route) => false,
                      );
                    },
                  );
                },
                child: const Text('Sí'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('No'),
              ),
            ],
          );
        });
  }
}
