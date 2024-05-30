// flutter
import 'package:flutter/material.dart';

// firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// business logic
import 'view/feed.dart';
import 'view/home.dart';
import 'view/login.dart';
import 'view/sign_up.dart';
import 'view/create_post.dart';
import 'view/my_profile.dart';
import 'view/welcome.dart';
import 'controller/login_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tigerbook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          surface: Colors.amber[50],
          surfaceTint: Colors.amber[50],
        ),
        useMaterial3: true,
      ),
      home: option(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const Home(),
        '/feed': (context) => const Feed(),
        '/my-profile': (context) => const MyProfile(),
        //'/:id': (context) => const Profile(),
        '/create-post': (context) => const CreatePost(),
        '/login': (context) => const Login(),
        '/sign-up': (context) => const SignUp(),
        '/welcome': (context) => const Welcome(),
      },
    );
  }

  Widget option() {
    if (LoginController.estaLogueado()) {
      return const Home();
    } else {
      return const Welcome();
    }
  }
}
