import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pina_app/config/firebase_config.dart';

/// Utilidad para manejar el caché y reinicio limpio de la aplicación
class CacheManager {
  static const String _lastClearKey = 'last_cache_clear';
  static const String _appVersionKey = 'app_version';
  static const String currentVersion = '1.0.0'; // Actualizar con cada release
  
  /// Verifica si necesita limpiar el caché basado en varios criterios
  static Future<bool> shouldClearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Verificar si la versión cambió
      final savedVersion = prefs.getString(_appVersionKey);
      if (savedVersion != currentVersion) {
        print('📱 Nueva versión detectada: $savedVersion -> $currentVersion');
        return true;
      }
      
      // Verificar si han pasado más de 7 días desde la última limpieza
      final lastClear = prefs.getInt(_lastClearKey) ?? 0;
      final daysSinceLastClear = 
          DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastClear)).inDays;
      
      if (daysSinceLastClear > 7) {
        print('🗓️ Han pasado $daysSinceLastClear días desde la última limpieza');
        return true;
      }
      
      return false;
    } catch (e) {
      print('⚠️ Error verificando si limpiar caché: $e');
      return false;
    }
  }
  
  /// Limpia el caché de Firestore y marca la fecha
  static Future<void> clearCacheIfNeeded() async {
    try {
      if (await shouldClearCache()) {
        print('🧹 Iniciando limpieza de caché...');
        
        // Verificar si hay un usuario autenticado
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          print('⚠️ Usuario autenticado detectado, saltando limpieza automática');
          return;
        }
        
        // Limpiar caché de Firestore
        await FirebaseFirestore.instance.terminate();
        await FirebaseFirestore.instance.clearPersistence();
        
        // Guardar fecha de limpieza y versión
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_lastClearKey, DateTime.now().millisecondsSinceEpoch);
        await prefs.setString(_appVersionKey, currentVersion);
        
        print('✅ Caché limpiado exitosamente');
      }
    } catch (e) {
      print('❌ Error limpiando caché: $e');
    }
  }
  
  /// Fuerza la limpieza del caché (usar con cuidado)
  static Future<bool> forceClearCache() async {
    try {
      print('🔨 Forzando limpieza de caché...');
      
      // Terminar Firestore
      await FirebaseFirestore.instance.terminate();
      
      // Limpiar persistencia
      await FirebaseFirestore.instance.clearPersistence();
      
      // Reinicializar Firestore
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
      );
      
      // Marcar como limpiado
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastClearKey, DateTime.now().millisecondsSinceEpoch);
      await prefs.setString(_appVersionKey, currentVersion);
      
      print('✅ Caché forzado limpiado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error forzando limpieza de caché: $e');
      return false;
    }
  }
  
  /// Limpia solo las preferencias locales
  static Future<void> clearLocalPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ Preferencias locales limpiadas');
    } catch (e) {
      print('❌ Error limpiando preferencias locales: $e');
    }
  }
  
  /// Obtiene información del estado del caché
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastClear = prefs.getInt(_lastClearKey) ?? 0;
      final savedVersion = prefs.getString(_appVersionKey) ?? 'unknown';
      
      return {
        'currentVersion': currentVersion,
        'savedVersion': savedVersion,
        'lastClearDate': DateTime.fromMillisecondsSinceEpoch(lastClear).toIso8601String(),
        'daysSinceLastClear': DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(lastClear)
        ).inDays,
        'persistenceEnabled': FirebaseConfig.enablePersistence,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}
