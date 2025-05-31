import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Utilidad para probar la conexión a Firebase rápidamente
///
/// Uso:
/// ```dart
/// await FirebaseQuickTest.ejecutarPrueba();
/// ```
class FirebaseQuickTest {
  static Future<void> ejecutarPrueba() async {
    print('\n🚀 INICIANDO PRUEBA RÁPIDA DE FIREBASE\n');

    try {
      // 1. Verificar inicialización de Firebase
      print('1️⃣ Verificando Firebase...');
      if (Firebase.apps.isEmpty) {
        print('   ❌ Firebase no está inicializado');
        return;
      }
      print('   ✅ Firebase inicializado correctamente');

      // 2. Verificar Auth
      print('\n2️⃣ Verificando Auth...');
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) {
        print('   ❌ No hay usuario autenticado');
        print('   ℹ️  Inicia sesión primero');
        return;
      }

      print('   ✅ Usuario: ${user.email}');
      print('   ✅ UID: ${user.uid}');
      print('   ✅ Email verificado: ${user.emailVerified}');

      // 3. Verificar Firestore
      print('\n3️⃣ Verificando Firestore...');
      final firestore = FirebaseFirestore.instance;

      // Intentar leer el documento del usuario
      try {
        final doc = await firestore
            .collection('usuarios')
            .doc(user.uid)
            .get(const GetOptions(source: Source.server));

        if (doc.exists) {
          print('   ✅ Documento encontrado en servidor');
          print('   ✅ Campos: ${doc.data()?.keys.join(', ')}');
        } else {
          print('   ❌ Documento no existe');
        }
      } catch (e) {
        print('   ❌ Error leyendo documento: $e');
      }

      // 4. Verificar permisos
      print('\n4️⃣ Verificando permisos...');
      try {
        // Intentar escribir un campo de prueba
        await firestore.collection('usuarios').doc(user.uid).update({
          '_test': FieldValue.serverTimestamp(),
        });
        print('   ✅ Permisos de escritura OK');

        // Limpiar campo de prueba
        await firestore.collection('usuarios').doc(user.uid).update({
          '_test': FieldValue.delete(),
        });
      } catch (e) {
        print('   ❌ Sin permisos de escritura: $e');
      }

      // 5. Verificar conectividad
      print('\n5️⃣ Verificando conectividad...');
      try {
        await firestore.collection('usuarios').doc('test').get();
        print('   ✅ Conexión a Firestore OK');
      } catch (e) {
        if (e.toString().contains('unavailable')) {
          print('   ❌ Sin conexión a internet');
        } else {
          print('   ⚠️  Error de conexión: $e');
        }
      }

      print('\n✅ PRUEBA COMPLETADA\n');
    } catch (e) {
      print('\n❌ ERROR GENERAL: $e\n');
    }
  }

  /// Crea un documento de prueba para el usuario actual
  static Future<bool> crearDocumentoPrueba() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set({
        'nombre': 'Usuario de Prueba',
        'email': user.email ?? '',
        'telefono': '+52 1234567890',
        'tipo': 'productor',
        'fotoPerfil': '',
        'ubicacion': 'Veracruz, México',
        'calificacionPromedio': 5.0,
        'numeroTransacciones': 0,
        'perfilCompleto': false,
        'verificado': false,
        'fechaRegistro': FieldValue.serverTimestamp(),
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

      print('✅ Documento de prueba creado');
      return true;
    } catch (e) {
      print('❌ Error creando documento de prueba: $e');
      return false;
    }
  }
}
