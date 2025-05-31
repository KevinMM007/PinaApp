import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseDebugUtils {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Verifica el estado de la conexión a Firebase y los datos del usuario
  static Future<void> verificarEstadoFirebase() async {
    print('========== VERIFICACIÓN DE FIREBASE ==========');

    try {
      // 1. Verificar usuario autenticado
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No hay usuario autenticado');
        return;
      }

      print('✅ Usuario autenticado: ${user.email}');
      print('   UID: ${user.uid}');
      print('   Email verificado: ${user.emailVerified}');

      // 2. Verificar documento en Firestore (primero desde caché, luego desde servidor)
      final docRef = _firestore.collection('usuarios').doc(user.uid);

      // Intentar desde caché
      print('\n📋 Verificando documento en caché...');
      try {
        final docCache =
            await docRef.get(const GetOptions(source: Source.cache));
        if (docCache.exists) {
          print('✅ Documento existe en caché');
          print('   Metadata: ${docCache.metadata}');
        } else {
          print('❌ Documento no existe en caché');
        }
      } catch (e) {
        print('❌ Error leyendo desde caché: $e');
      }

      // Intentar desde servidor
      print('\n🌐 Verificando documento en servidor...');
      DocumentSnapshot doc;
      try {
        doc = await docRef.get(const GetOptions(source: Source.server));
        if (doc.exists) {
          print('✅ Documento existe en servidor');
        } else {
          print('❌ Documento no existe en servidor');
          return;
        }
      } catch (e) {
        print('❌ Error leyendo desde servidor: $e');
        // Intentar sin especificar fuente
        doc = await docRef.get();
      }

      if (!doc.exists) {
        print('❌ Documento no existe en Firestore');
        return;
      }

      print('✅ Documento existe en Firestore');

      // 3. Verificar estructura del documento
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        print('❌ Documento está vacío');
        return;
      }

      print('📋 Campos en el documento:');
      data.forEach((key, value) {
        final valueType = value.runtimeType.toString();
        print('   - $key: $valueType');

        // Mostrar detalles de timestamps
        if (key.contains('fecha') ||
            key.contains('Fecha') ||
            key.contains('Activity')) {
          print('     Valor: $value');
          if (value != null &&
              value.runtimeType.toString().contains('Timestamp')) {
            try {
              final date = (value as dynamic).toDate();
              print('     Fecha parseada: $date');
            } catch (e) {
              print('     Error parseando fecha: $e');
            }
          }
        }
      });

      // 4. Verificar campos requeridos
      print('\n📋 Verificación de campos requeridos:');
      final camposRequeridos = ['nombre', 'email', 'tipo', 'telefono'];
      for (final campo in camposRequeridos) {
        final existe = data.containsKey(campo);
        final valor = data[campo];
        print(
            '   - $campo: ${existe ? '✅' : '❌'} ${existe ? '(valor: $valor)' : 'FALTA'}');
      }

      // 5. Verificar perfiles específicos
      print('\n📋 Perfiles específicos:');
      print(
          '   - perfilProductor: ${data.containsKey('perfilProductor') ? '✅' : '❌'}');
      print(
          '   - perfilComprador: ${data.containsKey('perfilComprador') ? '✅' : '❌'}');
      print(
          '   - perfilTransportista: ${data.containsKey('perfilTransportista') ? '✅' : '❌'}');

      // 6. Verificar configuración
      if (data.containsKey('configuracion')) {
        print('\n📋 Configuración:');
        final config = data['configuracion'] as Map<String, dynamic>?;
        if (config != null) {
          config.forEach((key, value) {
            print('   - $key: $value');
          });
        }
      }
    } catch (e) {
      print('❌ Error durante la verificación: $e');
      print('   Tipo de error: ${e.runtimeType}');
      if (e is FirebaseException) {
        print('   Código: ${e.code}');
        print('   Mensaje: ${e.message}');
      }
    }

    print('==============================================');
  }

  /// Intenta reparar el documento del usuario si hay problemas
  static Future<bool> repararDocumentoUsuario() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No hay usuario autenticado para reparar');
        return false;
      }

      print('🔧 Intentando reparar documento del usuario ${user.email}...');

      final docRef = _firestore.collection('usuarios').doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        print('📝 Creando documento nuevo...');
        await docRef.set({
          'nombre': user.displayName ?? 'Usuario',
          'email': user.email ?? '',
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
        });
        print('✅ Documento creado exitosamente');
        return true;
      }

      // Si existe, verificar campos faltantes
      final data = doc.data();
      if (data == null) {
        print('❌ Documento existe pero está vacío');
        return false;
      }

      final updates = <String, dynamic>{};

      // Campos requeridos
      if (!data.containsKey('nombre') ||
          data['nombre'] == null ||
          data['nombre'] == '') {
        updates['nombre'] = user.displayName ?? 'Usuario';
      }
      if (!data.containsKey('email') ||
          data['email'] == null ||
          data['email'] == '') {
        updates['email'] = user.email ?? '';
      }
      if (!data.containsKey('tipo') ||
          data['tipo'] == null ||
          data['tipo'] == '') {
        updates['tipo'] = 'productor';
      }
      if (!data.containsKey('telefono')) {
        updates['telefono'] = '';
      }
      if (!data.containsKey('configuracion')) {
        updates['configuracion'] = {
          'notificacionesEmail': true,
          'notificacionesPush': true,
          'mostrarTelefono': true,
          'mostrarUbicacion': true,
          'idioma': 'es',
          'tema': 'claro',
        };
      }

      // Campos numéricos
      if (!data.containsKey('calificacionPromedio')) {
        updates['calificacionPromedio'] = 0.0;
      }
      if (!data.containsKey('numeroTransacciones')) {
        updates['numeroTransacciones'] = 0;
      }

      // Campos booleanos
      if (!data.containsKey('perfilCompleto')) {
        updates['perfilCompleto'] = false;
      }
      if (!data.containsKey('verificado')) {
        updates['verificado'] = false;
      }

      if (updates.isNotEmpty) {
        print('📝 Actualizando ${updates.length} campos...');
        updates['ultimaActividad'] = FieldValue.serverTimestamp();
        await docRef.update(updates);
        print('✅ Documento reparado exitosamente');
        return true;
      } else {
        print('✅ Documento no necesita reparación');
        return true;
      }
    } catch (e) {
      print('❌ Error reparando documento: $e');
      return false;
    }
  }

  /// Limpia el caché de Firestore y recarga el perfil
  static Future<bool> limpiarCacheYRecargar() async {
    try {
      print('🧽 Limpiando caché de Firestore...');

      // Verificar si hay operaciones pendientes
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No hay usuario autenticado');
        return false;
      }

      try {
        // Intentar limpiar el caché
        await _firestore.terminate();
        await _firestore.clearPersistence();
        print('✅ Caché limpiado exitosamente');

        // Reinicializar Firestore
        _firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );

        print('🔄 Firestore reinicializado');
        return true;
      } catch (e) {
        print('❌ Error limpiando caché: $e');

        // Si no se puede limpiar el caché, intentar forzar lectura desde servidor
        print('🌐 Intentando forzar lectura desde servidor...');
        try {
          final docRef = _firestore.collection('usuarios').doc(user.uid);
          final doc = await docRef.get(const GetOptions(source: Source.server));

          if (doc.exists) {
            print('✅ Documento obtenido desde servidor');
            return true;
          } else {
            print('❌ Documento no existe en servidor');
            return false;
          }
        } catch (serverError) {
          print('❌ Error obteniendo desde servidor: $serverError');
          return false;
        }
      }
    } catch (e) {
      print('❌ Error general: $e');
      return false;
    }
  }
}
