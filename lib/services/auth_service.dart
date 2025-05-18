import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Verificar si hay un usuario autenticado
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registro con email y contraseña
  Future<UserCredential> registrarConEmailYContrasena({
    required String email,
    required String password,
    required String nombre,
    required String telefono,
    required String tipo,
  }) async {
    try {
      // Crear usuario en Firebase Auth
      UserCredential resultado = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar información adicional en Firestore
      await _firestore.collection('usuarios').doc(resultado.user!.uid).set({
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'tipo': tipo,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      return resultado;
    } catch (e) {
      rethrow;
    }
  }

  // Iniciar sesión con email y contraseña
  Future<UserCredential> iniciarSesionConEmailYContrasena({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}