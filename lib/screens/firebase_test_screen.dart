import 'package:flutter/material.dart';
import 'package:pina_app/utils/firebase_debug_utils.dart';
import 'package:pina_app/utils/firebase_quick_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Pantalla de testing para verificar el funcionamiento de Firebase
/// 
/// Úsala temporalmente para depurar problemas:
/// En main.dart, cambia temporalmente:
/// home: const AuthWrapper(),
/// Por:
/// home: const FirebaseTestScreen(),
class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _status = 'Presiona un botón para empezar';
  bool _isLoading = false;

  Future<void> _runTest(String testName, Future<void> Function() test) async {
    setState(() {
      _isLoading = true;
      _status = 'Ejecutando $testName...';
    });

    try {
      await test();
      setState(() {
        _status = '$testName completado. Revisa la consola.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error en $testName: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing Firebase'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.bug_report,
                      size: 48,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pruebas disponibles:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _runTest(
                        'Prueba rápida',
                        FirebaseQuickTest.ejecutarPrueba,
                      ),
              icon: const Icon(Icons.speed),
              label: const Text('Prueba rápida de conexión'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _runTest(
                        'Diagnóstico completo',
                        FirebaseDebugUtils.verificarEstadoFirebase,
                      ),
              icon: const Icon(Icons.search),
              label: const Text('Diagnóstico completo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _runTest(
                        'Reparar documento',
                        FirebaseDebugUtils.repararDocumentoUsuario,
                      ),
              icon: const Icon(Icons.build),
              label: const Text('Reparar documento de usuario'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _runTest(
                        'Limpiar caché',
                        FirebaseDebugUtils.limpiarCacheYRecargar,
                      ),
              icon: const Icon(Icons.cleaning_services),
              label: const Text('Limpiar caché y recargar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        setState(() {
                          _status = 'No hay usuario autenticado';
                        });
                        return;
                      }
                      
                      await FirebaseAuth.instance.signOut();
                      setState(() {
                        _status = 'Sesión cerrada. Vuelve a iniciar sesión.';
                      });
                    },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                foregroundColor: Colors.red,
              ),
            ),
            const Spacer(),
            const Text(
              'Nota: Revisa la consola de depuración para ver los resultados detallados.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
