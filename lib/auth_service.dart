// lib/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Necesario para guardar el nombre

  // --- FUNCIÓN FALTANTE: Registro con Correo/Contraseña ---
  Future<User?> signUp(String email, String password, String fullName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Guardar el nombre del usuario en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'email': email,
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  // --- FUNCIÓN FALTANTE: Inicio de sesión con Correo/Contraseña ---
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  // Función para cerrar sesión (ya la tenías)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream para escuchar cambios en el estado de autenticación (ya la tenías)
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}