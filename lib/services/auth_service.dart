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
        'perfilCompleto': false,
        'verificado': false,
        'calificacionPromedio': 0.0,
        'numeroTransacciones': 0,
        'configuracion': {
          'notificacionesEmail': true,
          'notificacionesPush': true,
          'mostrarTelefono': true,
          'mostrarUbicacion': true,
          'idioma': 'es',
          'tema': 'claro',
        },
      });

      // Enviar email de verificación
      await resultado.user!.sendEmailVerification();

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
      UserCredential resultado = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar última actividad solo si el documento existe
      if (resultado.user != null) {
        try {
          // Verificar si el documento existe antes de actualizar
          DocumentSnapshot doc = await _firestore
              .collection('usuarios')
              .doc(resultado.user!.uid)
              .get();
              
          if (doc.exists) {
            await _firestore.collection('usuarios').doc(resultado.user!.uid).update({
              'ultimaActividad': FieldValue.serverTimestamp(),
            });
          } else {
            print('⚠️ Documento de usuario no existe, se creará cuando se cargue el perfil');
          }
        } catch (e) {
          print('⚠️ Error actualizando última actividad: $e');
          // No fallar el login por esto
        }
      }

      return resultado;
    } catch (e) {
      rethrow;
    }
  }

  // Recuperación de contraseña
  Future<void> recuperarContrasena(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Reenviar email de verificación
  Future<void> reenviarEmailVerificacion() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      } else {
        throw FirebaseAuthException(
          code: 'user-already-verified',
          message: 'El usuario ya está verificado',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar perfil básico
  Future<void> actualizarPerfilBasico({
    required String uid,
    required Map<String, dynamic> datos,
  }) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({
        ...datos,
        'ultimaActividad': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar perfil específico por rol
  Future<void> actualizarPerfilEspecifico({
    required String uid,
    required String tipo,
    required Map<String, dynamic> perfilDatos,
  }) async {
    try {
      String camposPerfil = '';
      switch (tipo) {
        case 'productor':
          camposPerfil = 'perfilProductor';
          break;
        case 'comprador':
          camposPerfil = 'perfilComprador';
          break;
        case 'transportista':
          camposPerfil = 'perfilTransportista';
          break;
      }

      await _firestore.collection('usuarios').doc(uid).update({
        camposPerfil: perfilDatos,
        'perfilCompleto': _esPerfilCompleto(tipo, perfilDatos),
        'ultimaActividad': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Verificar si el perfil está completo
  bool _esPerfilCompleto(String tipo, Map<String, dynamic> perfil) {
    switch (tipo) {
      case 'productor':
        return perfil['nombreFinca']?.toString().isNotEmpty == true &&
               (perfil['hectareas'] ?? 0) > 0;
      case 'comprador':
        return perfil['nombreEmpresa']?.toString().isNotEmpty == true &&
               (perfil['volumenCompraMensual'] ?? 0) > 0;
      case 'transportista':
        return perfil['nombreEmpresa']?.toString().isNotEmpty == true &&
               (perfil['vehiculos'] as List?)?.isNotEmpty == true;
      default:
        return false;
    }
  }

  // Cambiar contraseña
  Future<void> cambiarContrasena({
    required String contrasenaActual,
    required String nuevaContrasena,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Usuario no encontrado',
        );
      }

      // Re-autenticar usuario
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: contrasenaActual,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Cambiar contraseña
      await user.updatePassword(nuevaContrasena);
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar configuración de usuario
  Future<void> actualizarConfiguracion({
    required String uid,
    required Map<String, dynamic> configuracion,
  }) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({
        'configuracion': configuracion,
        'ultimaActividad': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar foto de perfil
  Future<void> actualizarFotoPerfil({
    required String uid,
    required String urlFoto,
  }) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({
        'fotoPerfil': urlFoto,
        'ultimaActividad': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar ubicación
  Future<void> actualizarUbicacion({
    required String uid,
    required String ubicacion,
    required double latitud,
    required double longitud,
  }) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({
        'ubicacion': ubicacion,
        'coordenadas': {
          'latitud': latitud,
          'longitud': longitud,
        },
        'ultimaActividad': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Marcar usuario como verificado (solo admin)
  Future<void> verificarUsuario(String uid) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({
        'verificado': true,
        'fechaVerificacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Obtener datos completos del usuario
  Future<Map<String, dynamic>?> obtenerDatosUsuario(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar cuenta de usuario
  Future<void> eliminarCuenta(String contrasenaActual) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Usuario no encontrado',
        );
      }

      print('Iniciando proceso de eliminación de cuenta para: ${user.email}');
      
      // Re-autenticar usuario
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: contrasenaActual,
      );
      
      print('Re-autenticando usuario...');
      await user.reauthenticateWithCredential(credential);
      print('Re-autenticación exitosa');
      
      // Primero eliminar datos de Firestore
      print('Eliminando datos de Firestore...');
      try {
        await _firestore.collection('usuarios').doc(user.uid).delete();
        print('Datos de Firestore eliminados');
      } catch (firestoreError) {
        print('Error al eliminar datos de Firestore: $firestoreError');
        // Continuar con la eliminación de la cuenta aunque falle Firestore
      }
      
      // Luego eliminar cuenta de Authentication
      print('Eliminando cuenta de Authentication...');
      await user.delete();
      print('Cuenta eliminada exitosamente');
      
      // Cerrar sesión explícitamente
      await _auth.signOut();
    } catch (e) {
      print('Error al eliminar cuenta: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    try {
      // Actualizar última actividad antes de cerrar sesión
      if (_auth.currentUser != null) {
        try {
          await _firestore.collection('usuarios').doc(_auth.currentUser!.uid).update({
            'ultimaActividad': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('Error actualizando última actividad: $e');
          // Ignore error if update fails, continue with sign out
        }
      }
      
      // Cerrar sesión
      await _auth.signOut();
      print('Sesión cerrada exitosamente');
    } catch (e) {
      print('Error al cerrar sesión: $e');
      rethrow;
    }
  }
}
