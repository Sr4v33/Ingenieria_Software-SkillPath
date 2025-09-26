// lib/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'registration_screen.dart';

// --- CLASE PRINCIPAL (FALTABA) ---
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- VARIABLES DE ESTADO (FALTABAN) ---
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  String _email = '';
  String _password = '';
  String _errorMessage = '';
  bool _isLoading = false;

  // --- LÓGICA DE INICIO DE SESIÓN (FALTABA) ---
  void _trySignIn() async {
    final isValid = _formKey.currentState?.validate();
    FocusScope.of(context).unfocus();

    if (isValid == true) {
      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        await _authService.signIn(_email, _password);
        // La navegación la maneja el AuthWrapper automáticamente
      } on FirebaseAuthException catch (e) {
        // Manejo de errores comunes de Firebase
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          _errorMessage = 'Email o contraseña incorrectos.';
        } else {
          _errorMessage = 'Ocurrió un error. Intenta de nuevo.';
        }
      } catch (e) {
        _errorMessage = 'Ocurrió un error inesperado.';
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- MÉTODO BUILD (YA LO TENÍAS) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenido')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Inicia Sesión', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
                  ),
                TextFormField(
                  key: ValueKey('email'),
                  validator: (value) => !(value?.contains('@') ?? false) ? 'Ingresa un email válido.' : null,
                  onSaved: (value) => _email = value ?? '',
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  key: ValueKey('password'),
                  validator: (value) => (value?.length ?? 0) < 6 ? 'La contraseña es muy corta.' : null,
                  onSaved: (value) => _password = value ?? '',
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Contraseña'),
                ),
                SizedBox(height: 30),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _trySignIn,
                  child: Text('Iniciar Sesión'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => RegistrationScreen()),
                    );
                  },
                  child: Text('¿No tienes una cuenta? Créala aquí'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}