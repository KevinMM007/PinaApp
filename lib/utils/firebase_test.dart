// Archivo para hacer pruebas de Firebase
// Este archivo NO debe ser incluido en producción
// Solo para desarrollo y depuración

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTest {
  static Future<void> testFirebaseConnection() async {
    print('🔥 Iniciando prueba de conexión con Firebase...');

    try {
      // Probar conexión con Auth
      final auth = FirebaseAuth.instance;
      print('✅ Firebase Auth inicializado');
      print('Usuario actual: ${auth.currentUser?.email ?? "Ninguno"}');

      // Probar conexión con Firestore
      final firestore = FirebaseFirestore.instance;
      print('✅ Firestore inicializado');

      // Intentar leer la colección de usuarios
      final snapshot = await firestore.collection('usuarios').limit(1).get();
      print('✅ Conexión con Firestore exitosa');
      print('Documentos en usuarios: ${snapshot.docs.length}');
    } catch (e) {
      print('❌ Error en prueba de Firebase: $e');
    }
  }

  static Future<void> testCreateUser() async {
    print('🧪 Probando creación de usuario...');

    try {
      final email = 'test_${DateTime.now().millisecondsSinceEpoch}@pinaapp.com';
      const password = 'Test123!';

      // Crear usuario
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Usuario creado: ${credential.user?.email}');

      // Crear documento en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(credential.user!.uid)
          .set({
        'nombre': 'Usuario Test',
        'email': email,
        'tipo': 'productor',
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      print('✅ Documento creado en Firestore');

      // Eliminar usuario de prueba
      await credential.user!.delete();
      print('✅ Usuario de prueba eliminado');
    } catch (e) {
      print('❌ Error en prueba de creación: $e');
    }
  }
}
