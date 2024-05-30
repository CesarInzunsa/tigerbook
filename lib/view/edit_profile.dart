// flutter
import 'package:flutter/material.dart';
import 'dart:io';

// plugins
import 'package:image_picker/image_picker.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';

import '../controller/controller.dart';
import '../model/user_content_model.dart';
import '../model/user_model.dart';
import './tool.dart';

class EditProfile extends StatefulWidget {
  final UserContentModel userContent;

  const EditProfile({super.key, required this.userContent});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // Crear una clave global para el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _profilePictureController = TextEditingController();

  // Archivo de imagen temporal
  File _imgProfile = File('');

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userContent.name;
    _userNameController.text = widget.userContent.userName;
    _profilePictureController.text = widget.userContent.profilePicture;
  }

  @override
  Widget build(BuildContext context) {
    // Crear un Scaffold
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: _displayBody(),
    );
  }

  Widget _displayBody() {
    return ListView(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
      children: [
        _displayForm(),
      ],
    );
  }

  Widget _displayForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _displaySelectImage(),
          _drawFormField(_nameController, 'Nombre'),
          _drawFormField(_userNameController, 'Nombre de Usuario'),
          _displayButtons(),
        ],
      ),
    );
  }

  Widget _displaySelectImage() {
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

  void _showImagePicker() async {
    final ImagePicker picker = ImagePicker();

    final XFile? img = await picker.pickImage(source: ImageSource.gallery);

    if (img == null) {
      return;
    }

    // convert it to a Dart:io file
    _imgProfile = File(img.path);

    //log('EditProfile: _imgProfile: ${_imgProfile.path}');

    setState(() {
      _imgProfile;
    });
  }

  Widget _drawCircleAvatar() {
    return CircleAvatar(
      radius: 40,
      backgroundImage: _getImgProfile(),
    );
  }

  ImageProvider _getImgProfile() {
    if (_imgProfile.path != '') {
      return Image.file(
        _imgProfile,
        fit: BoxFit.scaleDown,
      ).image;
    } else {
      return Image.network(
        _profilePictureController.text,
        fit: BoxFit.scaleDown,
      ).image;
    }
  }

  Widget _drawFormField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: TextFormField(
        style: const TextStyle(fontSize: 20),
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
        validator: (value) {
          if (Tool.isNullOrBlank(value!)) {
            return 'Por favor, ingrese su $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _displayButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: Tool.getButtonStyle('cancel'),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validar si el formulario es válido
              if (_formKey.currentState!.validate()) {
                // Crear objeto de tipo User
                final UserModel user = UserModel(
                  id: widget.userContent.id,
                  name: _nameController.text.isEmpty? widget.userContent.name : _nameController.text,
                  userName: _userNameController.text.isEmpty? widget.userContent.userName : _userNameController.text,
                  email: '',
                  profilePicture: _profilePictureController.text
                );

                // Enviar el objeto al método de actualización del perfil
                showDialog(
                  context: context,
                  builder: (context) => FutureProgressDialog(
                    Controller().updateOneUser(user, _imgProfile),
                    message: const Text('Actualizando perfil...'),
                  ),
                ).then((value) {
                  if (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Perfil actualizado'),
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al actualizar el perfil'),
                      ),
                    );
                  }
                });
              }
            },
            style: Tool.getButtonStyle('primary'),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
