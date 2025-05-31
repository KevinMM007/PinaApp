/// Configuración de Firebase para la aplicación PiñaApp
/// 
/// Este archivo contiene configuraciones importantes para Firebase
/// que pueden ser ajustadas según sea necesario.

class FirebaseConfig {
  /// Habilitar o deshabilitar la persistencia de Firestore
  /// 
  /// IMPORTANTE: Actualmente está deshabilitada debido a problemas
  /// de caché que ocurren al reinstalar la aplicación.
  /// 
  /// Cuando esté en `false`:
  /// - La app siempre leerá datos desde el servidor
  /// - No habrá problemas de caché corrupto
  /// - Usará más datos móviles
  /// - No funcionará offline
  /// 
  /// Cuando esté en `true`:
  /// - Los datos se almacenarán localmente
  /// - Funcionará offline
  /// - Puede causar problemas al reinstalar la app
  /// 
  /// TODO: Re-habilitar cuando se solucione el problema de caché
  static const bool enablePersistence = false;
  
  /// Tamaño del caché cuando la persistencia está habilitada
  /// 
  /// Usar Settings.CACHE_SIZE_UNLIMITED para caché ilimitado
  static const int cacheSize = 100 * 1024 * 1024; // 100MB
  
  /// Timeout para operaciones de Firestore (en segundos)
  static const int firestoreTimeout = 10;
  
  /// Timeout para la inicialización de la app (en segundos)
  static const int initTimeout = 15;
  
  /// Número máximo de reintentos para cargar el perfil
  static const int maxRetries = 3;
  
  /// Tiempo de espera entre reintentos (se multiplica por el número de intento)
  static const int retryWaitTime = 2;
}
