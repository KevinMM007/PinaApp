import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pina_app/utils/firebase_debug_utils.dart';
import 'package:pina_app/utils/cache_manager.dart';
import 'package:pina_app/config/firebase_config.dart';

/// Servicio de diagnóstico y reparación para problemas comunes
class DiagnosticService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ejecuta un diagnóstico completo y devuelve el resultado
  static Future<DiagnosticResult> runCompleteDiagnostic() async {
    final result = DiagnosticResult();

    try {
      // 1. Verificar autenticación
      print('\n====== DIAGNÓSTICO COMPLETO ======');
      print('1️⃣ Verificando autenticación...');

      final user = _auth.currentUser;
      if (user == null) {
        result.addError('No hay usuario autenticado');
        return result;
      }

      result.addSuccess('Usuario autenticado: ${user.email}');
      result.userId = user.uid;
      result.userEmail = user.email;

      // 2. Verificar conexión a internet
      print('\n2️⃣ Verificando conexión a internet...');
      try {
        // Intentar una operación simple con timeout corto
        await _firestore
            .collection('_test')
            .doc('ping')
            .get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: 5));
        result.addSuccess('Conexión a internet OK');
      } catch (e) {
        result.addError('Sin conexión a internet o Firestore no disponible');
        result.hasNetworkIssues = true;
      }

      // 3. Verificar documento del usuario
      print('\n3️⃣ Verificando documento del usuario...');
      try {
        final docRef = _firestore.collection('usuarios').doc(user.uid);

        // Intentar desde servidor
        DocumentSnapshot doc;
        try {
          doc = await docRef.get(const GetOptions(source: Source.server));
          result.addSuccess('Documento obtenido desde servidor');
        } catch (e) {
          result.addWarning(
              'No se pudo obtener desde servidor, intentando caché');
          doc = await docRef.get();
        }

        if (doc.exists) {
          result.addSuccess('Documento existe en Firestore');
          result.documentExists = true;

          // Verificar campos
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            final requiredFields = ['nombre', 'email', 'tipo'];
            final missingFields = <String>[];

            for (final field in requiredFields) {
              if (!data.containsKey(field) ||
                  data[field] == null ||
                  data[field] == '') {
                missingFields.add(field);
              }
            }

            if (missingFields.isEmpty) {
              result.addSuccess('Todos los campos requeridos están presentes');
            } else {
              result
                  .addWarning('Campos faltantes: ${missingFields.join(', ')}');
              result.missingFields = missingFields;
            }
          }
        } else {
          result.addError('Documento no existe en Firestore');
          result.documentExists = false;
        }
      } catch (e) {
        result.addError('Error verificando documento: $e');
      }

      // 4. Verificar configuración de persistencia
      print('\n4️⃣ Verificando configuración de persistencia...');
      result.addInfo(
          'Persistencia habilitada: ${FirebaseConfig.enablePersistence}');

      // 5. Verificar información del caché
      print('\n5️⃣ Verificando estado del caché...');
      try {
        final cacheInfo = await CacheManager.getCacheInfo();
        result.addInfo('Info del caché: $cacheInfo');
        result.cacheInfo = cacheInfo;
      } catch (e) {
        result.addWarning('No se pudo obtener info del caché: $e');
      }
    } catch (e) {
      result.addError('Error general en diagnóstico: $e');
    }

    print('\n====== FIN DEL DIAGNÓSTICO ======\n');
    return result;
  }

  /// Intenta reparar problemas comunes automáticamente
  static Future<RepairResult> attemptAutoRepair() async {
    final result = RepairResult();

    try {
      final diagnostic = await runCompleteDiagnostic();

      // 1. Si no hay documento, intentar crearlo
      if (!diagnostic.documentExists && diagnostic.userId != null) {
        print('🔧 Intentando crear documento faltante...');
        try {
          final reparado = await FirebaseDebugUtils.repararDocumentoUsuario();
          if (reparado) {
            result.addSuccess('Documento creado exitosamente');
          } else {
            result.addError('No se pudo crear el documento');
          }
        } catch (e) {
          result.addError('Error creando documento: $e');
        }
      }

      // 2. Si hay campos faltantes, intentar repararlos
      if (diagnostic.missingFields.isNotEmpty) {
        print('🔧 Intentando reparar campos faltantes...');
        try {
          final reparado = await FirebaseDebugUtils.repararDocumentoUsuario();
          if (reparado) {
            result.addSuccess('Campos reparados exitosamente');
          } else {
            result.addError('No se pudo reparar los campos');
          }
        } catch (e) {
          result.addError('Error reparando campos: $e');
        }
      }

      // 3. Si hay problemas de red y la persistencia está habilitada, sugerir deshabilitarla
      if (diagnostic.hasNetworkIssues && FirebaseConfig.enablePersistence) {
        result.addWarning(
            'Se detectaron problemas de red. Considera desactivar la persistencia '
            'temporalmente en firebase_config.dart');
      }

      // 4. Limpiar caché si es necesario
      if (!FirebaseConfig.enablePersistence) {
        print('🔧 Intentando limpiar caché...');
        try {
          final limpiado = await CacheManager.forceClearCache();
          if (limpiado) {
            result.addSuccess('Caché limpiado exitosamente');
          } else {
            result.addWarning('No se pudo limpiar el caché completamente');
          }
        } catch (e) {
          result.addError('Error limpiando caché: $e');
        }
      }

      // 5. Sugerir acciones manuales si es necesario
      if (diagnostic.errors.isNotEmpty) {
        result.addInfo('Acciones recomendadas:\n'
            '1. Cierra sesión y vuelve a iniciar\n'
            '2. Verifica tu conexión a internet\n'
            '3. Si el problema persiste, contacta soporte');
      }
    } catch (e) {
      result.addError('Error en reparación automática: $e');
    }

    return result;
  }
}

/// Resultado del diagnóstico
class DiagnosticResult {
  final List<String> successes = [];
  final List<String> warnings = [];
  final List<String> errors = [];
  final List<String> info = [];

  String? userId;
  String? userEmail;
  bool documentExists = false;
  bool hasNetworkIssues = false;
  List<String> missingFields = [];
  Map<String, dynamic>? cacheInfo;

  void addSuccess(String message) {
    successes.add('✅ $message');
    print('✅ $message');
  }

  void addWarning(String message) {
    warnings.add('⚠️ $message');
    print('⚠️ $message');
  }

  void addError(String message) {
    errors.add('❌ $message');
    print('❌ $message');
  }

  void addInfo(String message) {
    info.add('ℹ️ $message');
    print('ℹ️ $message');
  }

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get isHealthy => errors.isEmpty && warnings.isEmpty;
}

/// Resultado de la reparación
class RepairResult {
  final List<String> successes = [];
  final List<String> warnings = [];
  final List<String> errors = [];
  final List<String> info = [];

  void addSuccess(String message) {
    successes.add('✅ $message');
    print('✅ $message');
  }

  void addWarning(String message) {
    warnings.add('⚠️ $message');
    print('⚠️ $message');
  }

  void addError(String message) {
    errors.add('❌ $message');
    print('❌ $message');
  }

  void addInfo(String message) {
    info.add('ℹ️ $message');
    print('ℹ️ $message');
  }

  bool get wasSuccessful => errors.isEmpty && successes.isNotEmpty;
}
