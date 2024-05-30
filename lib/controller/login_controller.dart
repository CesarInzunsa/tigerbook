// Flutter
import 'dart:io';
import 'dart:developer';

// Plugins
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

// Business Logic
import '../model/user_model.dart';
import './controller.dart';

class LoginController {
  static FirebaseAuth autenticar = FirebaseAuth.instance;

  String getMyProfileId() {
    User? user = LoginController.autenticar.currentUser;
    return user!.uid;
  }

  static Future<User?> createUser(
      UserModel newUser, String password, File profilePicture) async {
    try {
      // Verificar que el correo no este en uso
      await Controller().isEmailAlreadyInUse(newUser.email).then((value) {
        if (value) {
          log('Correo ya en uso');
          return null;
        }
      });

      // Verificar que el nombre de usuario no este en uso
      await Controller().isUserNameAlreadyInUse(newUser.userName).then((value) {
        if (value) {
          log('Nombre de usuario ya en uso');
          return null;
        }
      });

      // Crear la cuenta de usuario
      UserCredential res = await autenticar.createUserWithEmailAndPassword(
        email: newUser.email,
        password: password,
      );

      newUser.id = res.user!.uid;

      // Crear el usuario y guardar la informacion de su cuenta dentro de firebase
      return await Controller()
          .insertOneUser(newUser, profilePicture)
          .then((value) async {
        if (value) {
          log('Usuario creado correctamente');
          // Verificar el correo del usuario
          return await res.user!.sendEmailVerification().then((value) {
            log('Correo de verificación enviado');
            return res.user;
          });
        } else {
          log('Error al crear el usuario');
          return null;
        }
      });
    } catch (signUpError) {
      log(signUpError.toString());
      if (signUpError is PlatformException) {
        if (signUpError.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
          return null;
        }
      }
      return null;
    }
  }

  static Future<User?> autenticarUsuario(String email, String password) async {
    try {
      UserCredential usuario = await autenticar.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      log('Usuario autenticado');

      if (usuario.user!.emailVerified) {
        log('Usuario verificado');
        return usuario.user;
      } else {
        log('Usuario no verificado');
        return null;
      }
    } catch (error) {
      log(error.toString());
      return null;
    }
  }

  static bool estaLogueado() {
    if (autenticar.currentUser != null &&
        autenticar.currentUser!.emailVerified) {
      return true;
    } else {
      return false;
    }
  }

  static Future cerrarSesion() async {
    await autenticar.signOut();
  }
}
