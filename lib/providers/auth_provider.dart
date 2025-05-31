import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pina_app/models/usuario.dart';
import 'package:pina_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pina_app/utils/firebase_debug_utils.dart';
import 'package:pina_app/config/firebase_config.dart';

/// Proveedor de estado para la autenticación de usuarios
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Usuario? _userProfile;
  bool _isLoading = false;
  String _error = '';
  StreamSubscription<User?>? _authSubscription;
  bool _isInitialized = false;
  Timer? _retryTimer;
  int _retryCount = 0;
  static const int _maxRetries = FirebaseConfig.maxRetries;

  User? get user => _user;
  Usuario? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String get error => _error;
  bool get isEmailVerified => _user?.emailVerified ?? false;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    print('Inicializando listener de autenticación...');
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (User? user) async {
        print('🔄 Auth state changed: ${user?.email ?? "null"}');
        _user = user;
        _retryCount = 0; // Reset retry count on auth state change

        if (user != null) {
          print('✅ Usuario autenticado, cargando perfil...');
          // Cancelar cualquier retry timer existente
          _retryTimer?.cancel();

          // Esperar un momento para asegurar que Firestore esté listo
          await Future.delayed(const Duration(milliseconds: 500));

          // Intentar cargar el perfil con reintentos
          await _loadUserProfileWithRetry();
        } else {
          print('❌ Usuario no autenticado, limpiando estado...');
          _userProfile = null;
          _isLoading = false;
          _error = '';
          _retryTimer?.cancel();
        }

        _isInitialized = true;
        notifyListeners();
      },
      onError: (error) {
        print('❌ Error en auth listener: $error');
        _error = 'Error de autenticación';
        _isLoading = false;
        _isInitialized = true;
        notifyListeners();
      },
    );
  }

  Future<void> _loadUserProfileWithRetry() async {
    if (_user == null) return;

    // Intentar cargar el perfil con reintentos
    bool success = false;
    _retryCount = 0;

    while (!success && _retryCount < _maxRetries) {
      try {
        await _loadUserProfile();
        success = true;
      } catch (e) {
        _retryCount++;
        print('⚠️ Intento $_retryCount de $_maxRetries falló');

        if (_retryCount < _maxRetries) {
          // Ejecutar diagnóstico antes de reintentar
          if (_retryCount == 1) {
            print('🔍 Ejecutando diagnóstico de Firebase...');
            await FirebaseDebugUtils.verificarEstadoFirebase();

            // Intentar reparar el documento si es necesario
            print('🔧 Intentando reparar documento...');
            final reparado = await FirebaseDebugUtils.repararDocumentoUsuario();
            if (reparado) {
              print('✅ Documento reparado, reintentando...');
            }
          }

          // Esperar antes de reintentar (con backoff exponencial)
          final waitTime = _retryCount * FirebaseConfig.retryWaitTime;
          print('⏳ Esperando $waitTime segundos antes de reintentar...');
          await Future.delayed(Duration(seconds: waitTime));
        } else {
          print('❌ Se agotaron los reintentos');
          // Ejecutar diagnóstico final
          await FirebaseDebugUtils.verificarEstadoFirebase();

          _error =
              'Error al cargar el perfil. Por favor, cierra sesión e intenta nuevamente.';
          _isLoading = false;
          notifyListeners();
        }
      }
    }
  }

  Future<void> _loadUserProfile({bool forceServerFetch = false}) async {
    if (_user == null) return;

    try {
      print('📥 Cargando perfil para: ${_user!.email}');
      print('🌐 Forzar desde servidor: $forceServerFetch');
      _isLoading = true;
      _error = '';
      notifyListeners();

      // Primero verificar si el documento existe con timeout
      final docRef = _firestore.collection('usuarios').doc(_user!.uid);

      // Siempre obtener desde el servidor cuando la persistencia está deshabilitada
      DocumentSnapshot doc;
      try {
        // Si la persistencia está deshabilitada, SIEMPRE usar el servidor
        if (!FirebaseConfig.enablePersistence ||
            forceServerFetch ||
            _retryCount > 0) {
          print(
              '🌐 Obteniendo documento desde el servidor (persistencia: ${FirebaseConfig.enablePersistence})...');
          doc =
              await docRef.get(const GetOptions(source: Source.server)).timeout(
            const Duration(seconds: FirebaseConfig.firestoreTimeout),
            onTimeout: () {
              print('⚠️ Timeout al obtener desde servidor');
              throw TimeoutException('Timeout obteniendo documento');
            },
          );
        } else {
          // Solo usar caché si la persistencia está habilitada
          print('📋 Obteniendo documento (con caché)...');
          doc = await docRef.get().timeout(
            const Duration(seconds: FirebaseConfig.firestoreTimeout),
            onTimeout: () {
              print('⚠️ Timeout al obtener documento');
              throw TimeoutException('Timeout obteniendo documento');
            },
          );
        }
      } catch (e) {
        print('⚠️ Error obteniendo documento: $e');

        // Si es un error de conectividad o timeout, intentar desde el servidor
        if (e.toString().contains('unavailable') ||
            e.toString().contains('TimeoutException') ||
            e.toString().contains('Failed host lookup')) {
          print('🌐 Intentando forzar lectura desde servidor...');
          try {
            doc = await docRef
                .get(const GetOptions(source: Source.server))
                .timeout(const Duration(
                    seconds: FirebaseConfig.firestoreTimeout ~/ 2));
          } catch (serverError) {
            print('❌ Error crítico: No se puede conectar con Firestore');
            throw Exception(
                'No se puede conectar con el servidor. Verifica tu conexión a internet.');
          }
        } else {
          rethrow;
        }
      }

      if (!doc.exists) {
        print('⚠️ Documento no existe, creando perfil...');
        await _createUserProfile();

        // Esperar un momento para asegurar la propagación
        await Future.delayed(const Duration(seconds: 1));

        // Volver a obtener el documento después de crearlo, siempre desde el servidor
        print('🔄 Recargando documento recién creado...');
        doc = await docRef
            .get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: FirebaseConfig.firestoreTimeout));

        if (!doc.exists) {
          throw Exception('El documento no se creó correctamente');
        }
      }

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        print('📋 Datos del documento: ${data.keys.join(', ')}');

        // Verificar que los campos necesarios existan
        if (data['email'] == null || data['nombre'] == null) {
          print('⚠️ Documento incompleto, actualizando...');
          await _updateIncompleteProfile(doc.id, data);
          // Volver a cargar
          doc = await docRef.get();
        }

        try {
          _userProfile =
              Usuario.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          print('✅ Perfil cargado: ${_userProfile?.nombreCompleto}');
          print('✅ Tipo de usuario: ${_userProfile?.tipo}');
          _error = '';
        } catch (parseError) {
          print('❌ Error parseando perfil: $parseError');
          // Intentar crear un perfil mínimo si falla el parsing
          _userProfile = Usuario(
            id: doc.id,
            nombre: data['nombre'] ?? _user!.displayName ?? 'Usuario',
            email: data['email'] ?? _user!.email ?? '',
            telefono: data['telefono'] ?? '',
            tipo: data['tipo'] ?? 'productor',
            fechaRegistro: DateTime.now(),
          );
          print('✅ Perfil mínimo creado');
          _error = '';
        }
      } else {
        throw Exception('El documento del usuario no existe o está vacío');
      }
    } catch (e) {
      print('❌ Error al cargar perfil: $e');
      if (e.toString().contains('permission-denied')) {
        _error = 'Sin permisos para acceder al perfil. Verifica tu conexión.';
      } else if (e.toString().contains('unavailable')) {
        _error = 'Servicio no disponible. Verifica tu conexión a internet.';
      } else {
        _error = 'Error al cargar el perfil: ${e.toString()}';
      }
      rethrow; // Re-throw para que el retry lo maneje
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createUserProfile() async {
    if (_user == null) return;

    try {
      final userData = {
        'nombre': _user!.displayName ?? 'Usuario',
        'email': _user!.email ?? '',
        'telefono': '',
        'tipo': 'productor',
        'fechaRegistro': FieldValue.serverTimestamp(),
        'perfilCompleto': false,
        'verificado': false,
        'calificacionPromedio': 0.0,
        'numeroTransacciones': 0,
        'ubicacion': '',
        'fotoPerfil': '',
        'ultimaActividad': FieldValue.serverTimestamp(),
        'configuracion': {
          'notificacionesEmail': true,
          'notificacionesPush': true,
          'mostrarTelefono': true,
          'mostrarUbicacion': true,
          'idioma': 'es',
          'tema': 'claro',
        },
      };

      await _firestore.collection('usuarios').doc(_user!.uid).set(userData);
      print('✅ Perfil creado en Firestore');
    } catch (e) {
      print('❌ Error creando perfil: $e');
      rethrow;
    }
  }

  Future<void> _updateIncompleteProfile(
      String uid, Map<String, dynamic> existingData) async {
    try {
      final updates = <String, dynamic>{};

      // Agregar campos faltantes
      if (existingData['email'] == null) {
        updates['email'] = _user!.email ?? '';
      }
      if (existingData['nombre'] == null) {
        updates['nombre'] = _user!.displayName ?? 'Usuario';
      }
      if (existingData['tipo'] == null) {
        updates['tipo'] = 'productor';
      }
      if (existingData['configuracion'] == null) {
        updates['configuracion'] = {
          'notificacionesEmail': true,
          'notificacionesPush': true,
          'mostrarTelefono': true,
          'mostrarUbicacion': true,
          'idioma': 'es',
          'tema': 'claro',
        };
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('usuarios').doc(uid).update(updates);
        print('✅ Perfil actualizado con campos faltantes');
      }
    } catch (e) {
      print('❌ Error actualizando perfil incompleto: $e');
      rethrow;
    }
  }

  // =============== REGISTRO ===============

  Future<bool> registrar({
    required String email,
    required String password,
    required String nombre,
    required String telefono,
    required String tipo,
  }) async {
    try {
      print('📝 Iniciando registro para: $email');
      _isLoading = true;
      _error = '';
      notifyListeners();

      // Crear usuario en Firebase Auth
      UserCredential resultado =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (resultado.user != null) {
        print('✅ Usuario creado en Auth, creando perfil en Firestore...');

        // Crear documento en Firestore con reintentos
        int attempts = 0;
        bool profileCreated = false;

        while (!profileCreated && attempts < 3) {
          try {
            await _firestore
                .collection('usuarios')
                .doc(resultado.user!.uid)
                .set({
              'nombre': nombre,
              'email': email,
              'telefono': telefono,
              'tipo': tipo,
              'fechaRegistro': FieldValue.serverTimestamp(),
              'perfilCompleto': false,
              'verificado': false,
              'calificacionPromedio': 0.0,
              'numeroTransacciones': 0,
              'ubicacion': '',
              'fotoPerfil': '',
              'ultimaActividad': FieldValue.serverTimestamp(),
              'configuracion': {
                'notificacionesEmail': true,
                'notificacionesPush': true,
                'mostrarTelefono': true,
                'mostrarUbicacion': true,
                'idioma': 'es',
                'tema': 'claro',
              },
            });
            profileCreated = true;
            print('✅ Perfil creado en Firestore');
          } catch (e) {
            attempts++;
            print('⚠️ Error creando perfil, intento $attempts: $e');
            if (attempts < 3) {
              await Future.delayed(Duration(seconds: attempts));
            }
          }
        }

        if (!profileCreated) {
          // Si no se pudo crear el perfil, eliminar el usuario de Auth
          await resultado.user!.delete();
          throw Exception('No se pudo crear el perfil del usuario');
        }

        // Enviar email de verificación
        try {
          await resultado.user!.sendEmailVerification();
          print('✅ Email de verificación enviado');
        } catch (e) {
          print('⚠️ Error enviando email de verificación: $e');
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error en registro: $e');
      _isLoading = false;
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // =============== INICIO DE SESIÓN ===============

  Future<bool> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Iniciando sesión para: $email');
      _isLoading = true;
      _error = '';
      notifyListeners();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Inicio de sesión exitoso');

      // El listener se encargará de cargar el perfil
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error en inicio de sesión: $e');
      _isLoading = false;
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // =============== CERRAR SESIÓN ===============

  Future<void> cerrarSesion() async {
    try {
      print('🚪 Cerrando sesión...');

      // Cancelar cualquier retry timer
      _retryTimer?.cancel();

      // Limpiar estado local primero
      _userProfile = null;
      _error = '';
      _isLoading = false;
      _retryCount = 0;
      notifyListeners();

      // Cerrar sesión en Firebase
      await FirebaseAuth.instance.signOut();
      print('✅ Sesión cerrada exitosamente');
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
      _error = 'Error al cerrar sesión';
      notifyListeners();
    }
  }

  // =============== ELIMINAR CUENTA ===============

  Future<bool> eliminarCuenta(String contrasenaActual) async {
    try {
      print('🗑️ Iniciando eliminación de cuenta...');
      _isLoading = true;
      _error = '';
      notifyListeners();

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Re-autenticar
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: contrasenaActual,
      );

      await user.reauthenticateWithCredential(credential);
      print('✅ Re-autenticación exitosa');

      // Eliminar datos de Firestore
      try {
        await _firestore.collection('usuarios').doc(user.uid).delete();
        print('✅ Datos de Firestore eliminados');
      } catch (e) {
        print('⚠️ Error eliminando datos de Firestore: $e');
      }

      // Eliminar cuenta
      await user.delete();
      print('✅ Cuenta eliminada de Auth');

      // Limpiar estado local
      _user = null;
      _userProfile = null;
      _error = '';
      _isLoading = false;
      _retryTimer?.cancel();
      notifyListeners();

      return true;
    } catch (e) {
      print('❌ Error eliminando cuenta: $e');
      _isLoading = false;
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // =============== OTROS MÉTODOS ===============

  Future<bool> recuperarContrasena(String email) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _authService.recuperarContrasena(email);

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

  Future<bool> reenviarEmailVerificacion() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _authService.reenviarEmailVerificacion();

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

  Future<void> recargarUsuario() async {
    if (_user != null) {
      await _user!.reload();
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    }
  }

  Future<void> recargarPerfil({bool forceServerFetch = true}) async {
    print('🔄 Recargando perfil manualmente...');
    _error = '';
    _retryCount = 0;

    // Intentar cargar directamente con fuerza desde servidor
    try {
      await _loadUserProfile(forceServerFetch: forceServerFetch);
    } catch (e) {
      // Si falla, usar el sistema de reintentos
      await _loadUserProfileWithRetry();
    }
  }

  Future<bool> actualizarPerfilBasico({
    required String nombre,
    required String telefono,
    required String ubicacion,
    String? fotoPerfil,
  }) async {
    if (_user == null) return false;

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      Map<String, dynamic> datos = {
        'nombre': nombre,
        'telefono': telefono,
        'ubicacion': ubicacion,
        'ultimaActividad': FieldValue.serverTimestamp(),
      };

      if (fotoPerfil != null) {
        datos['fotoPerfil'] = fotoPerfil;
      }

      await _authService.actualizarPerfilBasico(
        uid: _user!.uid,
        datos: datos,
      );

      await _loadUserProfile();
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

  Future<bool> actualizarPerfilEspecifico(
      Map<String, dynamic> perfilDatos) async {
    if (_user == null || _userProfile == null) return false;

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _authService.actualizarPerfilEspecifico(
        uid: _user!.uid,
        tipo: _userProfile!.tipo,
        perfilDatos: perfilDatos,
      );

      await _loadUserProfile();
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

  Future<bool> actualizarConfiguracion(
      Map<String, dynamic> configuracion) async {
    if (_user == null) return false;

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _authService.actualizarConfiguracion(
        uid: _user!.uid,
        configuracion: configuracion,
      );

      await _loadUserProfile();
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

  Future<bool> cambiarContrasena({
    required String contrasenaActual,
    required String nuevaContrasena,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _authService.cambiarContrasena(
        contrasenaActual: contrasenaActual,
        nuevaContrasena: nuevaContrasena,
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

  Future<bool> actualizarFotoPerfil(String urlFoto) async {
    if (_user == null) return false;

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _authService.actualizarFotoPerfil(
        uid: _user!.uid,
        urlFoto: urlFoto,
      );

      await _loadUserProfile();
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

  Future<bool> actualizarUbicacion({
    required String ubicacion,
    required double latitud,
    required double longitud,
  }) async {
    if (_user == null) return false;

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _authService.actualizarUbicacion(
        uid: _user!.uid,
        ubicacion: ubicacion,
        latitud: latitud,
        longitud: longitud,
      );

      await _loadUserProfile();
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

  void clearError() {
    _error = '';
    notifyListeners();
  }

  T? getConfiguracion<T>(String clave, [T? valorPorDefecto]) {
    return _userProfile?.configuracion[clave] as T? ?? valorPorDefecto;
  }

  bool get esPerfilCompleto {
    return _userProfile?.tienePerfilCompleto ?? false;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }

  String _getErrorMessage(dynamic e) {
    print('🔍 Analizando error: ${e.runtimeType} - $e');

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
        case 'invalid-email':
          return 'El email no es válido.';
        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada.';
        case 'too-many-requests':
          return 'Demasiados intentos. Intenta más tarde.';
        case 'network-request-failed':
          return 'Error de conexión. Verifica tu internet.';
        case 'requires-recent-login':
          return 'Necesitas iniciar sesión nuevamente.';
        default:
          return 'Error: ${e.message}';
      }
    }

    // Manejo de errores de conectividad y timeout
    final errorString = e.toString().toLowerCase();
    if (errorString.contains('unavailable')) {
      return 'Servicio no disponible. Verifica tu conexión a internet.';
    } else if (errorString.contains('timeout')) {
      return 'Tiempo de espera agotado. Verifica tu conexión a internet.';
    } else if (errorString.contains('failed host lookup')) {
      return 'No se puede conectar al servidor. Verifica tu conexión a internet.';
    } else if (errorString.contains('no se puede conectar con el servidor')) {
      return e.toString().replaceAll('Exception: ', '');
    } else if (errorString.contains('permission-denied')) {
      return 'Sin permisos para acceder a los datos.';
    }

    return 'Error: ${e.toString()}';
  }
}
