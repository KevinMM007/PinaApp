import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pina_app/models/usuario.dart';
import 'package:pina_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  Usuario? _userProfile;
  bool _isLoading = false;
  String _error = '';

  User? get user => _user;
  Usuario? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String get error => _error;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;
    
    try {
      DocumentSnapshot doc = await _firestore.collection('usuarios').doc(_user!.uid).get();
      if (doc.exists) {
        _userProfile = Usuario.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      notifyListeners();
    } catch (e) {
      print('Error al cargar perfil: $e');
    }
  }

  Future<bool> registrar({
    required String email,
    required String password,
    required String nombre,
    required String telefono,
    required String tipo,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _authService.registrarConEmailYContrasena(
        email: email,
        password: password,
        nombre: nombre,
        telefono: telefono,
        tipo: tipo,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> iniciarSesion({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _authService.iniciarSesionConEmailYContrasena(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> cerrarSesion() async {
    await _authService.cerrarSesion();
  }

  String _getErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No hay usuario registrado con este email.';
        case 'wrong-password':
          return 'Contraseña incorrecta.';
        case 'email-already-in-use':
          return 'Este email ya está en uso.';
        case 'weak-password':
          return 'La contraseña es demasiado débil.';
        default:
          return 'Error de autenticación: ${e.message}';
      }
    }
    return 'Error inesperado: $e';
  }
}