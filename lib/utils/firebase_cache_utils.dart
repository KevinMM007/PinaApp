import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Utilidades para manejar el caché y estado de Firebase
class FirebaseCacheUtils {
  
  /// Limpia el caché de Firestore
  static Future<void> clearFirestoreCache() async {
    try {
      print('🧹 Limpiando caché de Firestore...');
      await FirebaseFirestore.instance.clearPersistence();
      print('✅ Caché de Firestore limpiado');
    } catch (e) {
      print('❌ Error limpiando caché: $e');
    }
  }
  
  /// Habilita la persistencia offline de Firestore
  static Future<void> enableOfflinePersistence() async {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      print('✅ Persistencia offline habilitada');
    } catch (e) {
      print('⚠️ Error habilitando persistencia: $e');
    }
  }
  
  /// Verifica la conexión con Firebase
  static Future<bool> checkFirebaseConnection() async {
    try {
      // Intentar una operación simple
      await FirebaseFirestore.instance
          .collection('_connection_test')
          .doc('test')
          .get(const GetOptions(source: Source.server));
      return true;
    } catch (e) {
      print('❌ Sin conexión con Firebase: $e');
      return false;
    }
  }
  
  /// Fuerza la recarga del usuario actual
  static Future<void> refreshCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        print('✅ Usuario recargado');
      }
    } catch (e) {
      print('❌ Error recargando usuario: $e');
    }
  }
  
  /// Obtiene información de depuración
  static Map<String, dynamic> getDebugInfo() {
    final user = FirebaseAuth.instance.currentUser;
    return {
      'authenticated': user != null,
      'userId': user?.uid,
      'email': user?.email,
      'emailVerified': user?.emailVerified,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
