// flutter
import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:io';

// plugins
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:image_picker/image_picker.dart';

// Business Logic
import './tool.dart';
import '../model/user_model.dart';
import '../controller/login_controller.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Crear un controlador para cada campo
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Crear un controlador para la imagen de perfil
  File _imgProfile = File('');

  // Crear una clave global para el formulario
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),
      body: _displayForm(),
    );
  }

  Widget _displayForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _displayInputProfilePicture(),
            _displayInput('Nombre', _nameController),
            _displayInput('Nombre de Usuario', _userNameController),
            _displayEmailInput('Correo Institucional', _emailController),
            _displayPasswordInput('Contraseña', _passwordController),
            //_displayCombo(),
            _displayActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _displayInputProfilePicture() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10),
                child: _drawCircleAvatar(),
              ),
              OutlinedButton(
                onPressed: () {
                  _showImagePicker();
                },
                style: Tool.getButtonStyle('secondary'),
                child: const Text('Cambiar imagen'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _drawCircleAvatar() {
    if (_imgProfile.path.isEmpty) {
      return const CircleAvatar(
        radius: 50,
        child: Icon(Icons.person, size: 50),
      );
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(_imgProfile),
      );
    }
  }

  void _showImagePicker() async {
    final ImagePicker picker = ImagePicker();

    final XFile? img = await picker.pickImage(source: ImageSource.gallery);

    if (img == null) {
      return;
    }

    // convert it to a Dart:io file
    _imgProfile = File(img.path);

    log('EditProfile: _imgProfile: ${_imgProfile.path}');

    setState(() {
      _imgProfile;
    });
  }

  Widget _displayInput(String label, controller) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
        top: 8.0,
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Por favor, ingrese su $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _displayEmailInput(String label, controller) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
        top: 8.0,
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Por favor, ingrese su $label';
          }
          if (!Tool.isEmail(value)) {
            return 'Por favor, ingrese un email válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _displayPasswordInput(String label, controller) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
        top: 8.0,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Por favor, ingrese su $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _displayActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
        top: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _displayCreateAccountButton(),
          _displayCancelButton(),
        ],
      ),
    );
  }

  Widget _displayCreateAccountButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _createNewAccount();
        }
      },
      style: Tool.getButtonStyle('primary'),
      child: const Text('Crear cuenta'),
    );
  }

  Widget _displayCancelButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: Tool.getButtonStyle('cancel'),
      child: const Text('Cancelar'),
    );
  }

  Future<void> _createNewAccount() async {

    if(_imgProfile.path == ''){
      Tool.showMessage('Por favor, seleccione una imagen de perfil', context);
      return;
    }

    // Obtener los valores de los campos
    String name = _nameController.text;
    String userName = _userNameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    // Crear objeto de tipo User
    final UserModel newUser = UserModel(
      id: '',
      name: name,
      userName: userName,
      email: email,
      profilePicture: '',
    );

    // Dialogo de progreso
    showDialog(
      context: context,
      builder: (BuildContext context) => FutureProgressDialog(
        LoginController.createUser(newUser, password, _imgProfile),
        message: const Text('Creando cuenta'),
      ),
    ).then(
      (value) {
        if (value != null) {
          // Limpiar los campos
          _clearTextFields();
          // Mostrar mensaje de éxito
          Tool.showMessage(
              'Cuenta creada exitosamente, Inicie sesión', context);
          // Regresar a la pantalla de login
          Navigator.pop(context);
        } else {
          Tool.showMessage(
            'Ocurrio un error al crear la cuenta o el correo o usuario ya estan registrados',
            context,
          );
        }
      },
    );
  }

  void _clearTextFields() {
    _nameController.clear();
    _userNameController.clear();
    _emailController.clear();
    _passwordController.clear();
  }
}
