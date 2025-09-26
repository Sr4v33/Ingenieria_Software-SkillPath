// lib/registration_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  String _email = '';
  String _password = '';
  String _fullName = '';
  String _errorMessage = '';
  bool _isLoading = false;

  void _trySubmit() async {
    final isValid = _formKey.currentState?.validate();
    FocusScope.of(context).unfocus();

    if (isValid != true) {
      return;
    }

    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _authService.signUp(_email, _password, _fullName);

      // --- SOLUCIÓN AQUÍ ---
      // Si el registro fue exitoso (no hubo una excepción),
      // cerramos la pantalla de registro.
      if (mounted) {
        Navigator.of(context).pop(); // Esto te devolverá a la pantalla anterior
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _errorMessage = 'El email ya está en uso. Por favor, intenta con otro.';
      } else {
        _errorMessage = 'Ocurrió un error. Por favor, intenta de nuevo más tarde.';
      }
    } catch (e) {
      _errorMessage = 'Ocurrió un error inesperado al crear tu perfil.';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ... el resto de tu clase (build, etc.) no cambia ...
  @override
  Widget build(BuildContext context) {
    // ... el método build es exactamente el mismo que te di antes ...
    return Scaffold(
      appBar: AppBar(title: Text('Crear Perfil')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Únete a Skills Path', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(_errorMessage, style: TextStyle(color: Colors.red), textAlign: TextAlign.center,),
                  ),
                TextFormField(
                  key: ValueKey('fullName'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa tu nombre completo.';
                    }
                    return null;
                  },
                  onSaved: (value) => _fullName = value ?? '',
                  decoration: InputDecoration(
                    labelText: 'Nombre Completo',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  key: ValueKey('email'),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Por favor ingresa un email válido.';
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value ?? '',
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  key: ValueKey('password'),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres.';
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value ?? '',
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: _trySubmit,
                  child: Text('Crear Perfil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}