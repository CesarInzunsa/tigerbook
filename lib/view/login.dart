import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:tigerbook/view/tool.dart';

import '../controller/login_controller.dart';
import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Llave para validar el formulario
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: _displayLogin(),
    );
  }

  Widget _displayLogin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _displayEmailFormField(),
            const SizedBox(height: 15),
            _displayPasswordFormField(),
            const SizedBox(height: 15),
            _displayButtons(),
          ],
        ),
      ),
    );
  }

  Widget _displayEmailFormField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingrese su email';
        }
        // Validar que el email tenga un formato de email valido
        if (!Tool.isEmail(value)) {
          return 'Por favor, ingrese un correo electrónico válido';
        }
        return null;
      },
    );
  }

  Widget _displayPasswordFormField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Contraseña',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingrese su contraseña';
        }
        return null;
      },
    );
  }

  Widget _displayButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            _handleLogin();
          },
          child: const Text('Iniciar sesión'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {

      // Ocultar el teclado
      FocusScope.of(context).unfocus();

      final email = _emailController.text;
      final password = _passwordController.text;

      showDialog(
        context: context,
        builder: (BuildContext context) => FutureProgressDialog(
          LoginController.autenticarUsuario(email, password),
          message: const Text('Iniciando sesión'),
        ),
      ).then(
        (value) => {
          if (value != null)
            {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const Home(),
                ),
                (Route<dynamic> route) => false,
              )
            }
          else
            {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Credenciales incorrectas, o no verificadas'),
                ),
              )
            }
        },
      );
    }
  }
}
