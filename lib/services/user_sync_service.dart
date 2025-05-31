import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Utilidad para limpiar usuarios huérfanos y sincronizar Auth con Firestore
class UserSyncService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Verifica y crea documentos faltantes para usuarios existentes en Auth
  static Future<Map<String, dynamic>> syncAuthWithFirestore() async {
    final results = {
      'checked': 0,
      'created': 0,
      'errors': 0,
      'details': <String>[]
    };
    
    try {
      print('\n🔄 INICIANDO SINCRONIZACIÓN AUTH ↔ FIRESTORE\n');
      
      // Esta función debe ejecutarse desde un contexto administrativo
      // Por ahora, solo verificaremos el usuario actual
      final currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        (results['details'] as List<String>).add('❌ No hay usuario autenticado');
        return results;
      }
      
      results['checked'] = 1;
      
      // Verificar si existe el documento
      final docRef = _firestore.collection('usuarios').doc(currentUser.uid);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        print('⚠️ Documento no encontrado para ${currentUser.email}');
        print('📝 Creando documento...');
        
        try {
          await docRef.set({
            'nombre': currentUser.displayName ?? currentUser.email?.split('@')[0] ?? 'Usuario',
            'email': currentUser.email ?? '',
            'telefono': '',
            'tipo': 'productor',
            'fechaRegistro': FieldValue.serverTimestamp(),
            'perfilCompleto': false,
            'verificado': false,
            'calificacionPromedio': 0.0,
            'numeroTransacciones': 0,
            'ubicacion': '',
            'fotoPerfil': currentUser.photoURL ?? '',
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
          
          results['created'] = 1;
          (results['details'] as List<String>).add('✅ Documento creado para ${currentUser.email}');
          print('✅ Documento creado exitosamente');
        } catch (e) {
          results['errors'] = 1;
          (results['details'] as List<String>).add('❌ Error creando documento: $e');
          print('❌ Error: $e');
        }
      } else {
        (results['details'] as List<String>).add('✅ Documento ya existe para ${currentUser.email}');
        print('✅ Documento ya existe');
      }
      
    } catch (e) {
      results['errors'] = 1;
      (results['details'] as List<String>).add('❌ Error general: $e');
      print('❌ Error general: $e');
    }
    
    print('\n📊 RESUMEN:');
    print('   Verificados: ${results['checked']}');
    print('   Creados: ${results['created']}');
    print('   Errores: ${results['errors']}');
    print('\n✅ SINCRONIZACIÓN COMPLETADA\n');
    
    return results;
  }
  
  /// Elimina usuarios de Authentication que no tienen documento en Firestore
  /// CUIDADO: Esta función es destructiva, usar solo en desarrollo
  static Future<Map<String, dynamic>> cleanOrphanedUsers() async {
    // Esta función requeriría Admin SDK
    // Por ahora solo retornamos información
    return {
      'message': 'Esta función requiere Firebase Admin SDK',
      'recommendation': 'Elimina manualmente los usuarios sin documentos desde Firebase Console'
    };
  }
  
  /// Verifica el estado de sincronización del usuario actual
  static Future<UserSyncStatus> checkCurrentUserSync() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return UserSyncStatus(
          hasAuth: false,
          hasDocument: false,
          isSync: false,
          message: 'No hay usuario autenticado',
        );
      }
      
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      
      return UserSyncStatus(
        hasAuth: true,
        hasDocument: doc.exists,
        isSync: doc.exists,
        message: doc.exists 
          ? 'Usuario sincronizado correctamente'
          : 'Usuario existe en Auth pero no en Firestore',
        authEmail: user.email,
        authUid: user.uid,
        documentData: doc.exists ? doc.data() : null,
      );
    } catch (e) {
      return UserSyncStatus(
        hasAuth: false,
        hasDocument: false,
        isSync: false,
        message: 'Error verificando sincronización: $e',
      );
    }
  }
}

/// Estado de sincronización de un usuario
class UserSyncStatus {
  final bool hasAuth;
  final bool hasDocument;
  final bool isSync;
  final String message;
  final String? authEmail;
  final String? authUid;
  final Map<String, dynamic>? documentData;
  
  UserSyncStatus({
    required this.hasAuth,
    required this.hasDocument,
    required this.isSync,
    required this.message,
    this.authEmail,
    this.authUid,
    this.documentData,
  });
  
  @override
  String toString() {
    return '''
UserSyncStatus:
  - Auth: ${hasAuth ? '✅' : '❌'} ${authEmail ?? 'N/A'}
  - Document: ${hasDocument ? '✅' : '❌'}
  - Synced: ${isSync ? '✅' : '❌'}
  - Message: $message
''';
  }
}

/// Widget para mostrar y reparar el estado de sincronización
class UserSyncWidget extends StatelessWidget {
  const UserSyncWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🔧 Herramienta de Sincronización',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final status = await UserSyncService.checkCurrentUserSync();
                
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Estado de Sincronización'),
                    content: Text(status.toString()),
                    actions: [
                      if (!status.isSync && status.hasAuth)
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            
                            // Mostrar progreso
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text('Sincronizando...'),
                                  ],
                                ),
                              ),
                            );
                            
                            final result = await UserSyncService.syncAuthWithFirestore();
                            
                            Navigator.pop(context);
                            
                            // Mostrar resultado
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Resultado'),
                                content: Text(
                                  (result['details'] as List).join('\n')
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Sincronizar'),
                        ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.sync),
              label: const Text('Verificar Sincronización'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Verifica si tu usuario existe tanto en Authentication como en Firestore',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
