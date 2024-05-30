//flutter
import 'package:flutter/material.dart';
import 'dart:io';

//plugins
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:image_picker/image_picker.dart';

// bussiness logic
import '../controller/controller.dart';
import '../controller/login_controller.dart';
import '../model/post_model.dart';
import './tool.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  // Llave para el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final List<File?> _imgFiles = [];
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Post'),
      ),
      body: _displayCreatePost(),
    );
  }

  Widget _displayCreatePost() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _displayImgFormField(),
            const SizedBox(height: 15),
            _displayContentFormField(),
            const SizedBox(height: 15),
            _displayButtons(),
          ],
        ),
      ),
    );
  }

  Widget _displayContentFormField() {
    return TextFormField(
      controller: _contentController,
      decoration: const InputDecoration(
        labelText: 'Contenido',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.text_fields),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingrese el contenido';
        }
        return null;
      },
    );
  }

  Widget _displayImgFormField() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                // foregroundColor: Colors.white,
                // backgroundColor: Colors.black,
                minimumSize: const Size(88, 36),
                //padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onPressed: _handlePickImages,
              child: const Icon(Icons.add_a_photo),
            ),
          ),
          if (_imgFiles.isNotEmpty)
            for (var img in _imgFiles)
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.file(img!),
                ),
              ),
        ],
      ),
    );
  }

  Widget _displayButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _handleSavePost,
          style: Tool.getButtonStyle('primary'),
          child: const Text('Guardar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: Tool.getButtonStyle('cancel'),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  void _handleSavePost() {
    if (_formKey.currentState!.validate()) {

      if(_imgFiles.isEmpty){
        Tool.showMessage('Debe seleccionar al menos una imagen', context);
        return;
      }

      // Crear el post
      final post = PostModel(
        id: '',
        userId: LoginController().getMyProfileId(),
        content: _contentController.text,
        images: [],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) => FutureProgressDialog(
          Controller().createPost(post, _imgFiles),
          message: const Text('Creando post'),
        ),
      ).then((value){
        if(value){
          Tool.showMessage('Post guardado', context);
          Navigator.pop(context);
        }else{
          Tool.showMessage('Error al guardar el post', context);
        }
      });
    }
  }

  void _handlePickImages() async {
    File? imgFile;

    final ImagePicker picker = ImagePicker();

    final List<XFile?> imgs = await picker.pickMultiImage();

    if (imgs.isEmpty) {
      return;
    }

    for (var img in imgs) {
      imgFile = File(img!.path); // convert it to a Dart:io file
      _imgFiles.add(imgFile);
      //log(img.path);
    }

    setState(() {
      _imgFiles;
    });
  }
}
