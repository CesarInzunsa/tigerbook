import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TigerPlace'),
      ),
      body: _displayWelcome(),
    );
  }

  Widget _displayWelcome() {
    return Column(
      children: [
        _welcomeText(),
        _botonSignIn(),
        _botonLogin(),
      ],
    );
  }

  Widget _welcomeText() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido a TigerBook!',
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Ya sea que estés buscando algun objeto perdido o simplemente quieras conectar con la comunidad estudiantil, ¡has llegado al lugar ideal!',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonSignIn() {
    return ElevatedButton.icon(
      onPressed: () {
        // Navegar a la pantalla de registro
        Navigator.pushNamed(context, '/sign-up');
      },
      icon: const Icon(Icons.account_box_outlined),
      label: const Text('Crea una cuenta ahora!'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        minimumSize: const Size(88, 36),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );
  }

  Widget _botonLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Ya tienes una cuenta?',
          style: TextStyle(color: Colors.grey[700]),
        ),
        TextButton(
          onPressed: () {
            // Navegar a la pantalla de login
            Navigator.pushNamed(context, '/login');
          },
          child: const Text(
            'Inicia sesión!',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
