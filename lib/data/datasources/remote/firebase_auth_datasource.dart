// lib/data/datasources/remote/firebase_auth_datasource.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/exceptions.dart';

abstract class FirebaseAuthDataSource {
  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password, String fullName);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
  User? get currentUser;
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  FirebaseAuthDataSourceImpl({
    required this.auth,
    required this.firestore,
  });

  @override
  Future<User> signIn(String email, String password) async {
    try {
      final result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw ServerException('Sign in failed - no user returned');
      }

      return result.user!;
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseError(e.code));
    } catch (e) {
      throw ServerException('Unexpected error during sign in: $e');
    }
  }

  @override
  Future<User> signUp(String email, String password, String fullName) async {
    try {
      final result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw ServerException('Sign up failed - no user returned');
      }

      final user = result.user!;

      // Guardar perfil en Firestore
      await firestore.collection('users').doc(user.uid).set({
        'fullName': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseError(e.code));
    } catch (e) {
      throw ServerException('Unexpected error during sign up: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      throw ServerException('Error signing out: $e');
    }
  }

  @override
  Stream<User?> get authStateChanges => auth.authStateChanges();

  @override
  User? get currentUser => auth.currentUser;

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email o contraseña incorrectos';
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      default:
        return 'Error de autenticación: $code';
    }
  }
}