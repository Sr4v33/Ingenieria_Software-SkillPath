// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;

// Importar temporalmente tus screens antiguos
import 'login_screen.dart'; // Tu archivo existente
import 'registration_screen.dart'; // Tu archivo existente
// import las demás pantallas que necesites...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar inyección de dependencias
  await di.initializeDependencies();

  runApp(SkillsPathApp());
}

class SkillsPathApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skills Path',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Este widget decide si mostrar login o la app
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Por ahora, usa tu AuthService antiguo
    // En el siguiente paso migraremos esto
    return LoginScreen(); // Tu pantalla existente
  }
}